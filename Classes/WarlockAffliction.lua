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


    spec:RegisterPack( "Affliction", 20210403.1, [[d4e0EcqiOOEeuPSjjvFcQyuGuNcu1QGkb1RuP0SeGBPsr2Lq)sfyysk1XGclta9mjLmnvkCnOsABQuuFtsr14ajQZjPiSoOinpqf3tqTpqLoiuewOkOhcsyIGe5IqLk2OKIO(iujGtcvQALQuntqsUPKIIDki(juj0qHkrlvsr6PqAQcsxvsrP2kujqFfQuPXkPWEPQ)QObRQdtzXG4XuzYkCzuBwL8zjA0QOtlA1skk51GYSjCBi2nPFl1WLKJdfrlh45enDKRlHTdL(Uk04bj15fO1dvcY8HQUVKIi7xP9y4d1JomI9HeyTdeJAFJAxRyGye4nhynHhLcwXE0kZbZkzpQAiShftCDjshLT6rRSGI2g(q9OYUa4yp6jrvsm9Gdkt6Sas01ihitKcHrzRoGDrhite3bEuifPGW9QhIhDye7djWAhig1(g1UwXaXiqC9gb6rLvSZhsG3mU6rpZXGvpep6GLopkM46sKokBDFCxdiAhS9oMOcKI9Rva7hyTdeJ9(EhkonTKLy6E)M2htmg8yF0kwi2hQAhS4E)M2htmg8yFOeJTla7xZyLPlU3VP9XeJbp2hcGnyUttvwSVOlt3(xnyFOeWsDF0Uqe3730(HEKny7xZyc(kD7xtTkQaW7l6Y0Tp17FSbW2pV2pyxGdG3hjLYul332NmbR0(PUpDA0(G(yCVFt7J7OgebVFn1qQmL2htCDjshLTk3hxIfxUpzcwP4E)M2p0JSbtUp17By7CSperFm1Y9HsgawPWa8(PUpsHGYBImqjt7F8GEFOeUyOY9lQI79BAFOO1bRsEFzJW7dLmaSsHb49XLaUAFNjeY9PEFapkC8(UgPQGmkBDFkr44E)M2hLP9LncVVZeIP5OS1PiL0(SsGKL7t9(scKoAFQ33W25yF3j7GLA5(IusY9PtJ2)yR4q7dH3hWM7KhX9(nTpUOkcUpkZJ9B1X7xb4BQQqiIE0kqFLc2JIB42(yIRlr6OS19XDnGODW274gUTpMOcKI9Rva7hyTdeJ9(Eh3WT9HIttlzjMU3XnCB)BAFmXyWJ9rRyHyFOQDWI7DCd32)M2htmg8yFOeJTla7xZyLPlU3XnCB)BAFmXyWJ9HaydM70uLf7l6Y0T)vd2hkbSu3hTleX9oUHB7Ft7h6r2GTFnJj4R0TFn1QOcaVVOlt3(uV)XgaB)8A)GDboaEFKuktTCFBFYeSs7N6(0Pr7d6JX9oUHB7Ft7J7OgebVFn1qQmL2htCDjshLTk3hxIfxUpzcwP4Eh3WT9VP9d9iBWK7t9(g2oh7dr0htTCFOKbGvkmaVFQ7JuiO8MiduY0(hpO3hkHlgQC)IQ4Eh3WT9VP9HIwhSk59LncVpuYaWkfgG3hxc4Q9DMqi3N69b8OWX77AKQcYOS19PeHJ7DCd32)M2hLP9LncVVZeIP5OS1PiL0(SsGKL7t9(scKoAFQ33W25yF3j7GLA5(IusY9PtJ2)yR4q7dH3hWM7KhX9oUHB7Ft7JlQIG7JY8y)wD8(va(MQkeI4EFVBokBvgRaSRrGyu4lwmhnsQgLTgqEfMsegU1UoMRykAIelxhZqkUUILGePtap7RP0CG8kDCSOAVBokBvgRaSRrGy0THpqwGG06SIP9U5OSvzScWUgbIr3g(GsqI0jGN91uAoqELooG8kmzcwPyjir6eWZ(AknhiVshhz1Gi4XE3Cu2QmwbyxJaXOBdFawdKgebhGAiC4rtYjGTrWaWAIcoS5OelphnfDnauurzRWT21nhLy55OPOv2Aq4w76MJsS8C0uSqLKbrWt76sKokBfU1Uo0yMmbRuuMvNTof5fhz1Gi4bE8MJsS8C0uuMvNTof5fd3AdFDOhnfRonLAKPm1YcHbskyKshSulXJhZKjyLIvNMsnYuMAzHWajfmYQbrWd437MJYwLXka7AeigDB4dkK8mjgja1q4WgUqYtdyY5vR0SVMv9rgS3nhLTkJva21iqm62WhizEm7RPRbGIkkBnarQ80ncJrTdiVclRyHysgOKjzuY8y2xtxdafvu260AgUHR1E3Cu2QmwbyxJaXOBdFWPvO0E3Cu2QmwbyxJaXOBdFqHkjdIGN21LiDu26EFVJB42(4oqn7kiESpJLbb3NseEF6K33Cud2pL7ByTuyqeCCVBokBvgwwXcXu0oy7DZrzRYBdFWGX2fGjIvMU9U5OSv5THpWzcX0Cu26uKska1q4WwZbijq6OWyeqEf2CuILNSYijlHBT2742(ychLTUViLKC)RgSpbsfgt7dHpnSzdI7Jsgj33a8(sdlp2)Qb7dHVAaVpAxi2VM20b4EKkwhPwUpuyKjjqxDYhGlpnLAK9rtTSqyGKcgW(nDYGJPK3V19DDlg9rDVBokBvEB4dCMqmnhLTofPKcqneombsfgttzLiPP7KDWcqsG0rHXiG8kmLimCWyVBokBvEB4dCMqmnhLTofPKcqneo8GfwqEmjqQWysU3nhLTkVn8botiMMJYwNIusbOgchwsgnjqQWysgGKaPJcJra5vyOhnfLDHycAksPdwQL4XpAkMivSosTC6mYKeORo55OPiLoyPwIh)OPy1PPuJmLPwwimqsbJu6GLAj81LDHykpnWaU1cp(rtrSPGNKLkfP0bl1s84jtWkfL9XjDYtjZd5E3Cu2Q82Wh4mHyAokBDksjfGAiC4HHyL8KaPcJjzascKokmgbKxHDnwwnLIAwEsZlJRdnMXAG0Gi4ibsfgttzLij84DDlg9rnk7cXe0ueWiwQs4gyTXJhASginicosGuHX0SvUURBXOpQrzxiMGMIagXsvchcKkmMIyeDDlg9rncyelvj84XdnwdKgebhjqQWyAsh76UUfJ(OgLDHycAkcyelvjCiqQWykgy01Ty0h1iGrSuLWd)E3Cu2Q82Wh4mHyAokBDksjfGAiC4HHyL8KaPcJjzascKokmgbKxHDnwwnLIyzLodcQdnMXAG0Gi4ibsfgttzLij84DDlg9rnMivSosTC6mYKeORo5iGrSuLWnWAJhp0ynqAqeCKaPcJPzRCDx3IrFuJjsfRJulNoJmjb6QtocyelvjCiqQWykIr01Ty0h1iGrSuLWJhp0ynqAqeCKaPcJPjDSR76wm6JAmrQyDKA50zKjjqxDYraJyPkHdbsfgtXaJUUfJ(OgbmILQeE437MJYwL3g(aNjetZrzRtrkPaudHdpmeRKNeivymjdqsG0rHXiG8km0UglRMsrLDGw0GbE8UglRMsrybbPP4X7ASSAkf1wz4RdnMXAG0Gi4ibsfgttzLij84DDlg9rnwDAk1itzQLfcdKuWiGrSuLWnWAJhp0ynqAqeCKaPcJPzRCDx3IrFuJvNMsnYuMAzHWajfmcyelvjCiqQWykIr01Ty0h1iGrSuLWJhp0ynqAqeCKaPcJPjDSR76wm6JAS60uQrMYullegiPGraJyPkHdbsfgtXaJUUfJ(OgbmILQeE437MJYwL3g(aNjetZrzRtrkPaudHdpmeRKNeivymjdqsG0rHXiG8kmMjtWkfRonLAKPm1YcHbskyKvdIGh1HgZynqAqeCKaPcJPPSsKeE8UUfJ(OgLfiiTohgawPWaCeWiwQs4gyTXJhASginicosGuHX0SvUURBXOpQrzbcsRZHbGvkmahbmILQeoeivymfXi66wm6JAeWiwQs4XJhASginicosGuHX0Ko21DDlg9rnklqqADomaSsHb4iGrSuLWHaPcJPyGrx3IrFuJagXsvcp87DCB)dla6(YUqSV80ad5(51(xz5jTFk33eiTK2VXYG9U5OSv5THpaXe8v6MaRIkaCa5vyiTuw)klpPjGrSuLWHHA2vq8KsegxyzxiMYtdmQpAkwOsYGi4PDDjshLTgP0bl1Y9oUTpU)AFxJLvtP9hnDaU80uQr2hn1YcHbsk4(PCFqHQPwgW(fsEFOKbGvkmaVp17ZqnX6yF6K33vaaSs7lzAVBokBvEB4dCMqmnhLTofPKcqneo8WaWkfgGNvaUkG8km0UglRMsrSSsNbb1hnftKkwhPwoDgzsc0vN8C0uKshSulR76wm6JAuwGG06CyayLcdWraJyPkHtG1HE0uS60uQrMYullegiPGraJyPkHBG4XJzYeSsXQttPgzktTSqyGKccp84XdTRXYQPuuZYtAEzC9rtrzxiMGMIu6GLAzDx3IrFuJYceKwNddaRuyaocyelvjCcSo0JMIvNMsnYuMAzHWajfmcyelvjCdepEmtMGvkwDAk1itzQLfcdKuq4HhpEOH21yz1ukQSd0IgmWJ31yz1ukcliinfpExJLvtPO2kdF9rtXQttPgzktTSqyGKcgP0bl1Y6JMIvNMsnYuMAzHWajfmcyelvjCce(9oUTFnLVaS8C)rtY9zdicUFETFzNA5(Ps9(2(Ytdm2xwX6i1Y9RonjV3nhLTkVn8botiMMJYwNIusbOgchE00ScWvbKxHH21yz1ukQz5jnVmUoMhnfLDHycAksPdwQL1DDlg9rnk7cXe0ueWiwQs4Cd4XJhAxJLvtPiwwPZGG6yE0umrQyDKA50zKjjqxDYZrtrkDWsTSURBXOpQXePI1rQLtNrMKaD1jhbmILQeo3aE84HgAxJLvtPOYoqlAWapExJLvtPiSGG0u84DnwwnLIARm81jtWkfRonLAKPm1YcHbskyDmpAkwDAk1itzQLfcdKuWiLoyPww31Ty0h1y1PPuJmLPwwimqsbJagXsvcNBa)Eh32h3FTpU80uQr2hn1YcHbsk4(PCFkDWsTmG9tA)uUV0U49PE)cjVpuYaW2hTle7DZrzRYBdFWWaWMYUqeqEfE0uS60uQrMYullegiPGrkDWsTCVBokBvEB4dgga2u2fIaYRWyMmbRuS60uQrMYullegiPG1HE0uu2fIjOPiLoyPwIh)OPyIuX6i1YPZitsGU6KNJMIu6GLAj87DCBF0GQBFC5PPuJSpAQLfcdKuW9pM05(4cYkDgeCqiz5jTFnzJ331yz1uA)rtbSFtNm4yk59lK8(TUVRBXOpQX9X9x7J7GufeWMyFCrWqn1X7dP46A)uUFQUgj1Ya2)SfJ9lukf7NeoY9bSncUp0yaL3xYUwhY9TlIb7xiz437MJYwL3g(GQttPgzktTSqyGKcgqEf21yz1ukQz5jnVmUoLimCX16UUfJ(OgLDHycAkcyelvjCWOo0eivymfzKQGa2eZgmutDC01Ty0h1iGrSuLWbJBoq84XmJjlYQkEezKQGa2eZgmutDm87DZrzRYBdFq1PPuJmLPwwimqsbdiVc7ASSAkfXYkDgeuNsegU4ADx3IrFuJjsfRJulNoJmjb6QtocyelvjCWOo0eivymfzKQGa2eZgmutDC01Ty0h1iGrSuLWbJBoq84XmJjlYQkEezKQGa2eZgmutDm87DZrzRYBdFq1PPuJmLPwwimqsbdiVcdTRXYQPuuzhOfnyGhVRXYQPuewqqAkE8UglRMsrTvg(6qtGuHXuKrQccytmBWqn1Xrx3IrFuJagXsvchmU5aXJhZmMSiRQ4rKrQccytmBWqn1XWV3nhLTkVn8bvNMsnYuMAzHWajfmG8kmKwkRFLLN0eWiwQs4GXnV3XT9X9x7JlpnLAK9rtTSqyGKcUFk3NshSuldy)KWrUpLi8(uVFHK3VPtgSpIvZQb7pAsU3nhLTkVn8botiMMJYwNIusbOgch21yz1ukG8k8OPy1PPuJmLPwwimqsbJu6GLAzDODnwwnLIAwEsZlJXJ31yz1ukILv6mia(9U5OSv5THpWkBnyaUGobpjduYKmmgbKxHhnfTYwdgbmILQeo3yVBokBvEB4doTcL2742(O9X9PtEFuMhY9BD)ATpzGsMK7Nx7N0(PuXH23vaaSsIG7N6(xIS8K2Vb736(0jVpzGsMI7J7M05(Oz1zR7dv5fVFs4i33eYEFimrmyFQ3VqY7JY8y)gld2hX0cticUVvvjcMA5(1AFOObGIkkBvg37MJYwL3g(ajZJzFnDnauurzRbKxHnhLy5jRmsYs4gyDYeSsrzFCsN8uY8qwhZJMIsMhZ(A6AaOOIYwJu6GLAzDmN68sKLN0E3Cu2Q82WhizEm7RPRbGIkkBnG8kS5OelpzLrswc3aRtMGvkkZQZwNI8IRJ5rtrjZJzFnDnauurzRrkDWsTSoMtDEjYYtQ(OPORbGIkkBncyelvjCUXE3Cu2Q82WhGnf8KSuPaYRWql7cXuEAGbCXapEZrjwEYkJKSeUbcFDx3IrFuJYceKwNddaRuyaocyelvjCXiW9U5OSv5THpOqLKbrWt76sKokBnG8kS5Oelphnflujzqe80UUePJYwdxB84P0bl1Y6JMIfQKmicEAxxI0rzRraJyPkHZn27MJYwL3g(aNjetZrzRtrkPaudHd7ASSAkfGKaPJcJra5vym7ASSAkfv2bArdg7DCBFmrvLi4(qrdafvu26(iMwycrW9BDFmUPa3NmqjtYa2Vb736(1A)JjDUpMaISffeVpu0aqrfLTU3nhLTkVn8bUgakQOS1aCbDcEsgOKjzymciVcBokXYtwzKKLW5g3e0KjyLIY(4Ko5PK5HepEYeSsrzwD26uKxm81hnfDnauurzRraJyPkHtG7DCBFmXfXG9PtE)UIvgeW(Ykwh7B7lpnWy)JNSUVr7JR736(1mMGVs3(1uRIka8(uVVHTZX(nwg4SQQul37MJYwL3g(aetWxPBcSkQaWbKxHLDHykpnWaU3OoLimCdeJ9oUTpU7jR7RnTVmO6sTCFC5PPuJSpAQLfcdKuW9PEFCbzLodcoiKS8K2VMSXbSpAbcsR7dLmaSsHb49ZR9nHy)rtY9naVVvvjsES3nhLTkVn8botiMMJYwNIusbOgchEyayLcdWZkaxfqEfgAxJLvtPiwwPZGG6yMmbRuS60uQrMYullegiPG1hnftKkwhPwoDgzsc0vN8C0uKshSulR76wm6JAuwGG06CyayLcdWraBJGWJhp0UglRMsrnlpP5LX1XmzcwPy1PPuJmLPwwimqsbRpAkk7cXe0uKshSulR76wm6JAuwGG06CyayLcdWraBJGWJhp0q7ASSAkfv2bArdg4X7ASSAkfHfeKMIhVRXYQPuuBLHVURBXOpQrzbcsRZHbGvkmahbSncc)Eh32VMTK3hkzay7J2fI9ZR9HsgawPWa8(hBfhAFi8(a2gb33kTudy)gSFETpDYaE)JPqSpeEFJ2xWMK2pW9rAaVpuYaWkfgG3VqYY9U5OSv5THpyyaytzxiciVcdPLY6UUfJ(OgLfiiTohgawPWaCeWiwQs4ELLN0eWiwQY6qJzYeSsXQttPgzktTSqyGKcIhVRBXOpQXQttPgzktTSqyGKcgbmILQeUxz5jnbmILQe(9U5OSv5THpyyaytzxiciVcJzYeSsXQttPgzktTSqyGKcw31Ty0h1OSabP15WaWkfgGJagXsvERRBXOpQrzbcsRZHbGvkmahhfaJYwHZvwEstaJyPk3742(qHrUZBYeI9tIr2VqAL8(xnyFtdsNPwUV20(Yk2Lxjp2Nfs(4jd49U5OSv5THpWzcX0Cu26uKska1q4WjXi7DCd32VMYxawEUp6Pn6J7J7GabyoEFi8vd49LvSosTCF5PbgY9BD)AgtWxPB)AQvrfaEVBokBvEB4dCMqmnhLTofPKcqneoSKdiVclySSaU4AnVo0dgsX1vuEAJ(4KrGamhhLK5GbhOd8MmhLTgLN2OpoH0ckM68sKLNe84Xpyifxxr5Pn6JtgbcWCCeWiwQs4ul43742(1SL8(1mMGVs3(1uRIka8(hpzDFeRMvd2F0KCFdW7xufW(ny)8AF6Kb8(htHyFi8(YSuZR0zkTpLi8(fkLI9PtEFLHAAFC5PPuJSpAQLfcdKuW9U5OSv5THpaXe8v6MaRIkaCa5v4rtrSPGNKLkfP0bl1s84hnftKkwhPwoDgzsc0vN8C0uKshSulXJF0uu2fIjOPiLoyPwU3nhLTkVn8biMGVs3eyvubGdiVctMGvkwDAk1itzQLfcdKuW6qpAkwDAk1itzQLfcdKuWiLoyPwIhVRBXOpQXQttPgzktTSqyGKcgbmILQeUbIR4XFLLN0eWiwQs446wm6JAS60uQrMYullegiPGraJyPkHFVBokBvEB4dqmbFLUjWQOcahqEfMmbRuu2hN0jpLmpK7DCBFOeWsDFOkV49t5(TkcUVTpucxIUFPL6(ht6CFCVYytYGi49Hsmsk59v2a7Jyq9(sYCWKX9X9x7FLLN0(PCFdsxq7t9(So2F07RnTpskL7lRyDKA5(0jVVKmhm5E3Cu2Q82WhmawQtrEXbKxHHuCDftLXMKbrWZbJKsokjZbdU3O24XdP46kMkJnjdIGNdgjLCSOQ(vwEstaJyPkHZn27MJYwL3g(aNjetZrzRtrkPaudHd7ASSAkT3nhLTkVn8bwzRbdWf0j4jzGsMKHXiG8kmGVaS80Gi49U5OSv5THpOqLKbrWt76sKokBnG8kS5Oelphnflujzqe80UUePJYwdxB84P0bl1Y6a(cWYtdIG37MJYwL3g(azwD26uKxCaUGobpjduYKmmgbKxHb8fGLNgebV3nhLTkVn8bUgakQOS1aCbDcEsgOKjzymciVcd4lalpnicUU5OelpzLrswcNBCtqtMGvkk7Jt6KNsMhs84jtWkfLz1zRtrEXWV3nhLTkVn8bdGL6u2fIasLyaOOIcJXE3Cu2Q82WhipTrFCcPf0EFVBokBvgTMdxDAk1itzQLfcdKuW9U5OSvz0A(2WhCAfkT3nhLTkJwZ3g(aNjetZrzRtrkPaudHdpmaSsHb4zfGRciVcdTRXYQPuelR0zqq9rtXePI1rQLtNrMKaD1jphnfP0bl1Y6UUfJ(OgLfiiTohgawPWaCeW2iyDOhnfRonLAKPm1YcHbskyeWiwQs4giE8yMmbRuS60uQrMYullegiPGWdpE8q7ASSAkf1S8KMxgxF0uu2fIjOPiLoyPww31Ty0h1OSabP15WaWkfgGJa2gbRd9OPy1PPuJmLPwwimqsbJagXsvc3aXJhZKjyLIvNMsnYuMAzHWajfeE4Rdn0UglRMsrLDGw0GbE8UglRMsrybbPP4X7ASSAkf1wz4RpAkwDAk1itzQLfcdKuWiLoyPwwF0uS60uQrMYullegiPGraJyPkHtGWV3nhLTkJwZ3g(ajZJzFnDnauurzRbKxHjtWkfL9XjDYtjZdzDNPtjZJ9U5OSvz0A(2WhizEm7RPRbGIkkBnG8kmMjtWkfL9XjDYtjZdzDmpAkkzEm7RPRbGIkkBnsPdwQL1XCQZlrwEs1hnfDnauurzRraFby5PbrW7DZrzRYO18THpWkBnyaUGobpjduYKmmgbKxHnhLy55OPOv2Aq4CJ6a(cWYtdIG37MJYwLrR5BdFGv2AWaCbDcEsgOKjzymciVcBokXYZrtrRS1GWn8nQd4lalpnicU(OPOv2AWiLoyPwU3nhLTkJwZ3g(GcvsgebpTRlr6OS1aYRWMJsS8C0uSqLKbrWt76sKokBnCTXJNshSulRd4lalpnicEVBokBvgTMVn8bfQKmicEAxxI0rzRb4c6e8KmqjtYWyeqEfgZu6GLAz9kSvKjyLIadPYuAAxxI0rzRYiRgebpQBokXYZrtXcvsgebpTRlr6OSv4uR9U5OSvz0A(2WhGnf8KSuPaYRWYUqmLNgyaxm27MJYwLrR5BdFGZeIP5OS1PiLuaQHWHDnwwnLcqsG0rHXiG8kmMDnwwnLIk7aTObJ9U5OSvz0A(2Wh4mHyAokBDksjfGAiC4HbGvkmapRaCva5vyODnwwnLIyzLodcQdTRBXOpQXePI1rQLtNrMKaD1jhbSncIh)OPyIuX6i1YPZitsGU6KNJMIu6GLAj81DDlg9rnklqqADomaSsHb4iGTrW6qpAkwDAk1itzQLfcdKuWiGrSuLWnq84XmzcwPy1PPuJmLPwwimqsbHh(6qdTRXYQPuuzhOfnyGhVRXYQPuewqqAkE8UglRMsrTvg(6UUfJ(OgLfiiTohgawPWaCeWiwQs4eyDOhnfRonLAKPm1YcHbskyeWiwQs4giE8yMmbRuS60uQrMYullegiPGWdp0UglRMsrnlpP5LX1H21Ty0h1OSletqtraBJG4XpAkk7cXe0uKshSulHVURBXOpQrzbcsRZHbGvkmahbmILQeobwh6rtXQttPgzktTSqyGKcgbmILQeUbIhpMjtWkfRonLAKPm1YcHbski8WV3nhLTkJwZ3g(GHbGnLDHiG8kSRBXOpQrzbcsRZHbGvkmahbmILQeUxz5jnbmILQSo0yMmbRuS60uQrMYullegiPG4X76wm6JAS60uQrMYullegiPGraJyPkH7vwEstaJyPkHFVBokBvgTMVn8bddaBk7cra5vyx3IrFuJYceKwNddaRuyaocyelv5TUUfJ(OgLfiiTohgawPWaCCuamkBfoxz5jnbmILQCVBokBvgTMVn8botiMMJYwNIusbOgchojgzVBokBvgTMVn8botiMMJYwNIusbOgchEWclipMeivymj37MJYwLrR5BdFGZeIP5OS1PiLuaQHWHhgIvYtcKkmMK7DZrzRYO18THpWzcX0Cu26uKska1q4WsYOjbsfgtYaYRWJMIvNMsnYuMAzHWajfmsPdwQL4XJzYeSsXQttPgzktTSqyGKcU3nhLTkJwZ3g(aetWxPBcSkQaWbKxHhnfXMcEswQuKshSul37MJYwLrR5BdFaIj4R0nbwfva4aYRWJMIYUqmbnfP0bl1Y6yMmbRuu2hN0jpLmpK7DZrzRYO18THpaXe8v6MaRIkaCa5vymtMGvkInf8KSuP9U5OSvz0A(2WhGyc(kDtGvrfaoG8kSSlet5PbgW9g7DZrzRYO18THpqMvNTof5fhGlOtWtYaLmjdJra5vyZrjwEoAkkZQZwNI8IHt4AvhWxawEAqeCDmpAkkZQZwNI8IJu6GLA5E3Cu2QmAnFB4dCMqmnhLTofPKcqneoSRXYQPuascKokmgbKxHDnwwnLIk7aTObJ9U5OSvz0A(2WhmawQtrEXbKxHHuCDftLXMKbrWZbJKsokjZbdUHX1AJhpKIRRyQm2KmicEoyKuYXIQ6xz5jnbmILQeo4kE8qkUUIPYytYGi45GrsjhLK5Gb3W1cxRpAkk7cXe0uKshSul37MJYwLrR5BdFWayPoLDHiGujgakQOWyS3nhLTkJwZ3g(a5Pn6JtiTG277DZrzRYORXYQPu4ePI1rQLtNrMKaD1jhqEfgZKjyLIvNMsnYuMAzHWajfSo0UUfJ(OgLfiiTohgawPWaCeWiwQs4GrTXJ31Ty0h1OSabP15WaWkfgGJagXsvcxCT21DDlg9rnklqqADomaSsHb4iGrSuLWnqCTUR1rrsrxdafvuQLtbZa437MJYwLrxJLvtPBdFqIuX6i1YPZitsGU6KdiVctMGvkwDAk1itzQLfcdKuW6JMIvNMsnYuMAzHWajfmsPdwQL7DZrzRYORXYQP0THpyWUeXOulNqAbfqEf21Ty0h1OSabP15WaWkfgGJagXsvcxCTo0dgsX1v80kukcyelvjCVbE8yMmbRu80kuc(9U5OSvz01yz1u62Whi7cXe0ua5vymtMGvkwDAk1itzQLfcdKuW6q76wm6JAuwGG06CyayLcdWraJyPkHdUIhVRBXOpQrzbcsRZHbGvkmahbmILQeU4ATXJ31Ty0h1OSabP15WaWkfgGJagXsvc3aX16UwhfjfDnauurPwofmdGFVBokBvgDnwwnLUn8bYUqmbnfqEfMmbRuS60uQrMYullegiPG1hnfRonLAKPm1YcHbskyKshSul37MJYwLrxJLvtPBdFG01fGulNusN8EFVBokBvghgIvYtcKkmMKHlK8mjgja1q4WYUqmZsnjgS3nhLTkJddXk5jbsfgtYBdFqHKNjXibOgchEayBCLaEILLswS3nhLTkJddXk5jbsfgtYBdFqHKNjXibOgchUueS6C2xttktKuyu26EFVBokBvghgawPWa8ScWvHXMcEswQ0E3Cu2QmomaSsHb4zfGRUn8bddaBk7cXE3Cu2QmomaSsHb4zfGRUn8bvnLTU3nhLTkJddaRuyaEwb4QBdFWvcyiIUh7DZrzRY4WaWkfgGNvaU62Whar09yEvacU3nhLTkJddaRuyaEwb4QBdFaegizaSul37MJYwLXHbGvkmapRaC1THpWzcX0Cu26uKska1q4WUglRMsbKxHXSRXYQPuuzhOfnyS3nhLTkJddaRuyaEwb4QBdFGSabP15WaWkfgG377DZrzRY4GfwqEmjqQWysgUqYZKyKaudHdZivbbSjMnyOM64aYRWq7ASSAkf1S8KMxgx31Ty0h1OSletqtraJyPkHtG1gE84H21yz1ukILv6miOURBXOpQXePI1rQLtNrMKaD1jhbmILQeobwB4XJhAxJLvtPOYoqlAWapExJLvtPiSGG0u84DnwwnLIARm87DZrzRY4GfwqEmjqQWysEB4dkK8mjgja1q4WYcfIO7X0qy6mOKciVcdTRXYQPuuZYtAEzCDx3IrFuJYUqmbnfbmILQeo3m84XdTRXYQPuelR0zqqDx3IrFuJjsfRJulNoJmjb6QtocyelvjCUz4XJhAxJLvtPOYoqlAWapExJLvtPiSGG0u84DnwwnLIARm87DZrzRY4GfwqEmjqQWysEB4dkK8mjgja1q4WYUqiyIsTCckGemG8km0UglRMsrnlpP5LX1DDlg9rnk7cXe0ueWiwQs4aLHhpEODnwwnLIyzLodcQ76wm6JAmrQyDKA50zKjjqxDYraJyPkHdugE84H21yz1ukQSd0IgmWJ31yz1ukcliinfpExJLvtPO2kd)EFVBokBvghnnRaCvyRS1GbKxHhnfTYwdgbmILQeoq56UUfJ(OgLfiiTohgawPWaCeWiwQs4oAkALTgmcyelv5E3Cu2QmoAAwb4QBdFGmRoBDkYloG8k8OPOmRoBDkYlocyelvjCGY1DDlg9rnklqqADomaSsHb4iGrSuLWD0uuMvNTof5fhbmILQCVBokBvghnnRaC1THpOqLKbrWt76sKokBnG8k8OPyHkjdIGN21LiDu2AeWiwQs4aLR76wm6JAuwGG06CyayLcdWraJyPkH7OPyHkjdIGN21LiDu2AeWiwQY9U5OSvzC00ScWv3g(axdafvu2Aa5v4rtrxdafvu2AeWiwQs4aLR76wm6JAuwGG06CyayLcdWraJyPkH7OPORbGIkkBncyelv5EFVBokBvgtIrcxi5zsmICVV3nhLTkJso8PvO0E3Cu2Qmk5BdFWayPoLDHiGujgakQOzPOHyIWyeqQedafv0mVcpyifxxr5Pn6JtgbcWCCusMdgCdxR9U5OSvzuY3g(a5Pn6JtiTG277DZrzRYOKmAsGuHXKmCHKNjXibOgchovPduqgebpXKfMsfiZbJnD8E3Cu2QmkjJMeivymjVn8bfsEMeJeGAiC4uLeOWrnqohj2u5jewi27MJYwLrjz0KaPcJj5THpOqYZKyKaudHd3yzWLOpMA500eXMoRK37MJYwLrjz0KaPcJj5THpOqYZKyKaudHdpmamKU15GDWMvfeGLowD8E3Cu2QmkjJMeivymjVn8bfsEMeJeGAiCyeZzqa8uEYmnrkKPBVBokBvgLKrtcKkmMK3g(GcjptIrcqneo8LWq4zFnHyej49U5OSvzusgnjqQWysEB4dkK8mjgja1q4WhnySYa58c06yVBokBvgLKrtcKkmMK3g(GcjptIrcqneomzqemn7R5GLvwc27MJYwLrjz0KaPcJj5THpOqYZKyKaudHdlt9QqmnzvcmLKti2OKN918IbTlPG7DZrzRYOKmAsGuHXK82Whui5zsmsaQHWHLPEviMLcBKg1a5eInk5zFnVyq7sk4E3Cu2QmkjJMeivymjVn8bqeDpMxfGG7DZrzRYOKmAsGuHXK82WhCLagIO7XE3Cu2QmkjJMeivymjVn8bqyGKbWsTCVV3nhLTkJeivymnLvIKMUt2blmwdKgebhGAiCyzf7stmzmzrwvXJaWAIcom0qdnJjlYQkEezKQGa2eZgmutD8wtIXKfzvfpIPkDGcYGi4jMSWuQazoySPJHFRjXyYISQIhrzxiemrPwobfqcc)wtIXKfzvfpIYcfIO7X0qy6mOKGFVBokBvgjqQWyAkRejnDNSd2THpaRbsdIGdqneombsfgtZw5aWAIcom0eivymfXiEAYzfODrtdwNaPcJPigXttoDDlg9rf(9U5OSvzKaPcJPPSsK00DYoy3g(aSginicoa1q4WeivymnPJDaynrbhgAcKkmMIbgpn5Sc0UOPbRtGuHXumW4PjNUUfJ(Oc)E3Cu2QmsGuHX0uwjsA6ozhSBdFawdKgebhGAiC4HHyL8KaPcJPaWAIcom0ygAcKkmMIyepn5Sc0UOPbRtGuHXueJ4PjNUUfJ(Ocp84XdnMHMaPcJPyGXttoRaTlAAW6eivymfdmEAYPRBXOpQWdpE8mMSiRQ4rSueS6C2xttktKuyu26E3Cu2QmsGuHX0uwjsA6ozhSBdFawdKgebhGAiCycKkmMMYkrsbG1efCyOXAG0Gi4ibsfgtZw56ynqAqeCCyiwjpjqQWycE84HgRbsdIGJeivymnPJDDSginicoomeRKNeivymbpE8qJ1aPbrWrcKkmMMTYBnjSginicokRyxAIjJjlYQkEapE8qJ1aPbrWrcKkmMM0XERjH1aPbrWrzf7stmzmzrwvXd49OyzGmB1hsG1oqmQ9nQDTI1gdp6rdOPwk9O4UyIAAi4(qWfat3F)qp59tKQgq7F1G9XHaPcJPPSsK00DYoy4SpGXKfjGh7lBeEFRGAeJ4X(UttlzzCVdvPY7hiMUpu0kwgq8yFCiqQWykIrSg4Sp17JdbsfgtrcJynWzFOdeQHpU3HQu59RfMUpu0kwgq8yFCiqQWykgySg4Sp17JdbsfgtrkWynWzFOdeQHpU3HQu59VbMUpu0kwgq8yFCiqQWykIrSg4Sp17JdbsfgtrcJynWzFOdeQHpU3HQu59VbMUpu0kwgq8yFCiqQWykgySg4Sp17JdbsfgtrkWynWzFOdeQHpU3374UyIAAi4(qWfat3F)qp59tKQgq7F1G9XX1yz1ucN9bmMSib8yFzJW7BfuJyep23DAAjlJ7DOkvEFmW09HIwXYaIh7JdzcwPynWzFQ3hhYeSsXAez1Gi4bo7dngqn8X9ouLkVpgy6(qrRyzaXJ9XX16OiPynWzFQ3hhxRJIKI1iYQbrWdC2hAmGA4J7DOkvE)aX09HIwXYaIh7JdzcwPynWzFQ3hhYeSsXAez1Gi4bo7dngqn8X9ouLkVFTW09HIwXYaIh7JdzcwPynWzFQ3hhYeSsXAez1Gi4bo7dngqn8X9ouLkV)nW09HIwXYaIh7JdzcwPynWzFQ3hhYeSsXAez1Gi4bo7dngqn8X9ouLkV)nW09HIwXYaIh7JJR1rrsXAGZ(uVpoUwhfjfRrKvdIGh4Sp0ya1Wh37qvQ8(4kMUpu0kwgq8yFCitWkfRbo7t9(4qMGvkwJiRgebpWzFOXaQHpU3374UyIAAi4(qWfat3F)qp59tKQgq7F1G9XzWxwHGWzFaJjlsap2x2i8(wb1igXJ9DNMwYY4EhQsL3)MX09HIwXYaIh7JdzcwPynWzFQ3hhYeSsXAez1Gi4bo7B0(4o4Iq1(qJbudFCVdvPY7xZX09HIwXYaIh7JdbsfgtrmI1aN9PEFCiqQWyksyeRbo7dngqn8X9ouLkVFnht3hkAfldiESpoeivymfdmwdC2N69XHaPcJPifySg4Sp0ya1Wh37qvQ8(qzmDFOOvSmG4X(4qGuHXueJynWzFQ3hhcKkmMIegXAGZ(qJbudFCVdvPY7dLX09HIwXYaIh7JdbsfgtXaJ1aN9PEFCiqQWyksbgRbo7dngqn8X9ouLkVFnbMUpu0kwgq8yFCiqQWykIrSg4Sp17JdbsfgtrcJynWzFOXaQHpU3HQu59RjW09HIwXYaIh7JdbsfgtXaJ1aN9PEFCiqQWyksbgRbo7dngqn8X9ouLkVpg1gt3hkAfldiESpoeivymfXiwdC2N69XHaPcJPiHrSg4Sp0ya1Wh37qvQ8(yuBmDFOOvSmG4X(4qGuHXumWynWzFQ3hhcKkmMIuGXAGZ(qJbudFCVdvPY7JrGy6(qrRyzaXJ9XHmbRuSg4Sp17JdzcwPynISAqe8aN9HoqOg(4EhQsL3hJAHP7dfTILbep2hhYeSsXAGZ(uVpoKjyLI1iYQbrWdC2hAmGA4J7DOkvEFmWvmDFOOvSmG4X(4qMGvkwdC2N69XHmbRuSgrwnicEGZ(qJbudFCVdvPY7JXnJP7dfTILbep2hhcKkmMIgex01Ty0hvC2N69XX1Ty0h1ObXHZ(qJbudFCVdvPY7Jrnht3hkAfldiESpoeivymfniUORBXOpQ4Sp17JJRBXOpQrdIdN9HgdOg(4EhQsL3hdOmMUpu0kwgq8yFCiqQWykAqCrx3IrFuXzFQ3hhx3IrFuJgeho7dngqn8X9ouLkVFG1ct3hkAfldiESpoKjyLI1aN9PEFCitWkfRrKvdIGh4Sp0ya1Wh37qvQ8(bEdmDFOOvSmG4X(4qMGvkwdC2N69XHmbRuSgrwnicEGZ(qJbudFCVdvPY7hiugt3hkAfldiESpoKjyLI1aN9PEFCitWkfRrKvdIGh4Sp0bc1Wh37qvQ8(1Q2y6(qrRyzaXJ9XHmbRuSg4Sp17JdzcwPynISAqe8aN9HoqOg(4EhQsL3VwyGP7dfTILbep2hhYeSsXAGZ(uVpoKjyLI1iYQbrWdC2hAmGA4J7DOkvE)AfiMUpu0kwgq8yFCitWkfRbo7t9(4qMGvkwJiRgebpWzFOXaQHpU3HQu59R1nJP7dfTILbep2hhYeSsXAGZ(uVpoKjyLI1iYQbrWdC2hAmGA4J7DOkvE)AvZX09HIwXYaIh7JdzcwPynWzFQ3hhYeSsXAez1Gi4bo7B0(4o4Iq1(qJbudFCVdvPY7FJAHP7dfTILbep2hhYeSsXAGZ(uVpoKjyLI1iYQbrWdC2h6aHA4J799oUlMOMgcUpeCbW093p0tE)ePQb0(xnyFCSMXzFaJjlsap2x2i8(wb1igXJ9DNMwYY4EhQsL3Vwy6(qrRyzaXJ9XHmbRuSg4Sp17JdzcwPynISAqe8aN9HoqOg(4EhQsL3)gy6(qrRyzaXJ9XHmbRuSg4Sp17JdzcwPynISAqe8aN9HgdOg(4EhQsL3hxX09HIwXYaIh7JdzcwPynWzFQ3hhYeSsXAez1Gi4bo7dngqn8X9ouLkVpgbIP7dfTILbep2hhYeSsXAGZ(uVpoKjyLI1iYQbrWdC2h6Ab1Wh37qvQ8(yulmDFOOvSmG4X(4qMGvkwdC2N69XHmbRuSgrwnicEGZ(qJbudFCVdvPY7Jbugt3hkAfldiESpoKjyLI1aN9PEFCitWkfRrKvdIGh4SVr7J7Glcv7dngqn8X9ouLkVFG1gt3hkAfldiESpoKjyLI1aN9PEFCitWkfRrKvdIGh4SVr7J7Glcv7dngqn8X9ouLkVFGyGP7dfTILbep2hhYeSsXAGZ(uVpoKjyLI1iYQbrWdC23O9XDWfHQ9HgdOg(4EFVJ7rQAaXJ9XiW9nhLTUViLKmU39OIussFOE0HbGvkmapRaCLpuFiy4d1JAokB1JInf8KSujpkRgebp8h6jFib6d1JAokB1JomaSPSleEuwnicE4p0t(qQLpupQ5OSvpAvtzREuwnicE4p0t(qUHpupQ5OSvp6vcyiIUhEuwnicE4p0t(qWvFOEuZrzREuiIUhZRcqqpkRgebp8h6jFi3SpupQ5OSvpkegizaSul9OSAqe8WFON8HuZ9H6rz1Gi4H)qpQdKedsZJI59DnwwnLIk7aTObdpQ5OSvpQZeIP5OS1PiLKhvKsAQgc7rDnwwnL8KpeOSpupQ5OSvpQSabP15WaWkfgG9OSAqe8WFON8KhLaPcJPPSsK00DYoy(q9HGHpupkRgebp8h6r7kpQKjpQ5OSvpkwdKgeb7rXAIc2Jc9(qVp07ZyYISQIhrgPkiGnXSbd1uh7rXAGPAiShvwXU0etgtwKvv8Wt(qc0hQhLvdIGh(d9ODLhvYKh1Cu2QhfRbsdIG9Oynrb7rHEFcKkmMIegXttoRaTlAAW9RVpbsfgtrcJ4PjNUUfJ(OUp8EuSgyQgc7rjqQWyA2k7jFi1YhQhLvdIGh(d9ODLhvYKh1Cu2QhfRbsdIG9Oynrb7rHEFcKkmMIuGXttoRaTlAAW9RVpbsfgtrkW4PjNUUfJ(OUp8EuSgyQgc7rjqQWyAshBp5d5g(q9OSAqe8WFOhTR8OsM8OMJYw9OynqAqeShfRjkypk07J59HEFcKkmMIegXttoRaTlAAW9RVpbsfgtrcJ4PjNUUfJ(OUp87d)(4XVp07J59HEFcKkmMIuGXttoRaTlAAW9RVpbsfgtrkW4PjNUUfJ(OUp87d)(4XVpJjlYQkEelfbRoN910KYejfgLT6rXAGPAiShDyiwjpjqQWyYt(qWvFOEuwnicE4p0J2vEujtEuZrzREuSginic2JI1efShf69XAG0Gi4ibsfgtZw59RVpwdKgebhhgIvYtcKkmM2h(9XJFFO3hRbsdIGJeivymnPJ9(13hRbsdIGJddXk5jbsfgt7d)(4XVp07J1aPbrWrcKkmMMTYEuSgyQgc7rjqQWyAkRej5jp5rhgIvYtcKkmMK(q9HGHpupkRgebp8h6rvdH9OYUqmZsnjg4rnhLT6rLDHyMLAsmWt(qc0hQhLvdIGh(d9OQHWE0bGTXvc4jwwkzHh1Cu2QhDayBCLaEILLsw4jFi1YhQhLvdIGh(d9OQHWE0srWQZzFnnPmrsHrzREuZrzRE0srWQZzFnnPmrsHrzREYtE0blSG8ysGuHXK0hQpem8H6rz1Gi4H)qpQ5OSvpkJufeWMy2GHAQJ9Ooqsminpk077ASSAkf1S8KMxgVF99DDlg9rnk7cXe0ueWiwQY9HZ(bw79HFF843h69DnwwnLIyzLodc2V((UUfJ(OgtKkwhPwoDgzsc0vNCeWiwQY9HZ(bw79HFF843h69DnwwnLIk7aTObJ9XJFFxJLvtPiSGG009XJFFxJLvtPO2kVp8Eu1qypkJufeWMy2GHAQJ9KpKa9H6rz1Gi4H)qpQ5OSvpQSqHi6EmneModkjpQdKedsZJc9(UglRMsrnlpP5LX7xFFx3IrFuJYUqmbnfbmILQCF4S)nVp87Jh)(qVVRXYQPuelR0zqW(1331Ty0h1yIuX6i1YPZitsGU6KJagXsvUpC2)M3h(9XJFFO331yz1ukQSd0Igm2hp(9DnwwnLIWccst3hp(9DnwwnLIAR8(W7rvdH9OYcfIO7X0qy6mOK8KpKA5d1JYQbrWd)HEuZrzREuzxiemrPwobfqc6rDGKyqAEuO331yz1ukQz5jnVmE)6776wm6JAu2fIjOPiGrSuL7dN9HY7d)(4XVp077ASSAkfXYkDgeSF99DDlg9rnMivSosTC6mYKeORo5iGrSuL7dN9HY7d)(4XVp077ASSAkfv2bArdg7Jh)(UglRMsrybbPP7Jh)(UglRMsrTvEF49OQHWEuzxiemrPwobfqc6jp5rDnwwnL8H6dbdFOEuwnicE4p0J6ajXG08OyEFYeSsXQttPgzktTSqyGKcgz1Gi4X(13h69DDlg9rnklqqADomaSsHb4iGrSuL7dN9XO27Jh)(UUfJ(OgLfiiTohgawPWaCeWiwQY9H7(4AT3V((UUfJ(OgLfiiTohgawPWaCeWiwQY9H7(bIR7xFFxRJIKIUgakQOulNcMbrwnicESp8EuZrzRE0ePI1rQLtNrMKaD1j7jFib6d1JYQbrWd)HEuhijgKMhLmbRuS60uQrMYullegiPGrwnicESF99hnfRonLAKPm1YcHbskyKshSul9OMJYw9OjsfRJulNoJmjb6Qt2t(qQLpupkRgebp8h6rDGKyqAEux3IrFuJYceKwNddaRuyaocyelv5(WDFCD)67d9(dgsX1v80kukcyelv5(WD)BSpE87J59jtWkfpTcLISAqe8yF49OMJYw9Od2LigLA5eslip5d5g(q9OSAqe8WFOh1bsIbP5rX8(KjyLIvNMsnYuMAzHWajfmYQbrWJ9RVp0776wm6JAuwGG06CyayLcdWraJyPk3ho7JR7Jh)(UUfJ(OgLfiiTohgawPWaCeWiwQY9H7(4AT3hp(9DDlg9rnklqqADomaSsHb4iGrSuL7d39dex3V((UwhfjfDnauurPwofmdISAqe8yF49OMJYw9OYUqmbn5jFi4QpupkRgebp8h6rDGKyqAEuYeSsXQttPgzktTSqyGKcgz1Gi4X(13F0uS60uQrMYullegiPGrkDWsT0JAokB1Jk7cXe0KN8HCZ(q9OMJYw9OsxxasTCsjDYEuwnicE4p0tEYJoAAwb4kFO(qWWhQhLvdIGh(d9Ooqsminp6OPOv2AWiGrSuL7dN9HY7xFFx3IrFuJYceKwNddaRuyaocyelv5(WD)rtrRS1GraJyPk9OMJYw9OwzRb9KpKa9H6rz1Gi4H)qpQdKedsZJoAkkZQZwNI8IJagXsvUpC2hkVF99DDlg9rnklqqADomaSsHb4iGrSuL7d39hnfLz1zRtrEXraJyPk9OMJYw9OYS6S1PiVyp5dPw(q9OSAqe8WFOh1bsIbP5rhnflujzqe80UUePJYwJagXsvUpC2hkVF99DDlg9rnklqqADomaSsHb4iGrSuL7d39hnflujzqe80UUePJYwJagXsv6rnhLT6rlujzqe80UUePJYw9KpKB4d1JYQbrWd)HEuhijgKMhD0u01aqrfLTgbmILQCF4SpuE)6776wm6JAuwGG06CyayLcdWraJyPk3hU7pAk6AaOOIYwJagXsv6rnhLT6rDnauurzREYtE0bFzfcYhQpem8H6rnhLT6rLvSqmfTdMhLvdIGh(d9KpKa9H6rnhLT6rhm2UamrSY05rz1Gi4H)qp5dPw(q9OSAqe8WFOh1bsIbP5rnhLy5jRmsYY9H7(1YJkjq6iFiy4rnhLT6rDMqmnhLTofPK8OIust1qypQ1SN8HCdFOEuwnicE4p0JoyPdKvu2Qhft4OS19fPKK7F1G9jqQWyAFi8PHnBqCFuYi5(gG3xAy5X(xnyFi8vd49r7cX(10Moa3JuX6i1Y9HcJmjb6Qt(aC5PPuJSpAQLfcdKuWa2VPtgCmL8(TUVRBXOpQEuZrzREuNjetZrzRtrkjpQKaPJ8HGHh1bsIbP5rPeH3ho7JHhvKsAQgc7rjqQWyAkRejnDNSdMN8HGR(q9OSAqe8WFOh1Cu2Qh1zcX0Cu26uKsYJksjnvdH9Odwyb5XKaPcJjPN8HCZ(q9OSAqe8WFOh1bsIbP5rHE)rtrzxiMGMIu6GLA5(4XV)OPyIuX6i1YPZitsGU6KNJMIu6GLA5(4XV)OPy1PPuJmLPwwimqsbJu6GLA5(WVF99LDHykpnWyF4UFT2hp(9hnfXMcEswQuKshSul3hp(9jtWkfL9XjDYtjZdzKvdIGhEujbsh5dbdpQ5OSvpQZeIP5OS1PiLKhvKsAQgc7rLKrtcKkmMKEYhsn3hQhLvdIGh(d9OoqsminpQRXYQPuuZYtAEz8(13h69X8(ynqAqeCKaPcJPPSsK0(4XVVRBXOpQrzxiMGMIagXsvUpC3pWAVpE87d9(ynqAqeCKaPcJPzR8(1331Ty0h1OSletqtraJyPk3ho7tGuHXuKWi66wm6JAeWiwQY9HFF843h69XAG0Gi4ibsfgtt6yVF99DDlg9rnk7cXe0ueWiwQY9HZ(eivymfPaJUUfJ(OgbmILQCF43hEpQKaPJ8HGHh1Cu2Qh1zcX0Cu26uKsYJksjnvdH9OddXk5jbsfgtsp5dbk7d1JYQbrWd)HEuhijgKMh11yz1ukILv6miy)67d9(yEFSginicosGuHX0uwjsAF84331Ty0h1yIuX6i1YPZitsGU6KJagXsvUpC3pWAVpE87d9(ynqAqeCKaPcJPzR8(1331Ty0h1yIuX6i1YPZitsGU6KJagXsvUpC2NaPcJPiHr01Ty0h1iGrSuL7d)(4XVp07J1aPbrWrcKkmMM0XE)6776wm6JAmrQyDKA50zKjjqxDYraJyPk3ho7tGuHXuKcm66wm6JAeWiwQY9HFF49OscKoYhcgEuZrzREuNjetZrzRtrkjpQiL0une2JomeRKNeivymj9KpKAcFOEuwnicE4p0J6ajXG08OqVVRXYQPuuzhOfnySpE877ASSAkfHfeKMUpE877ASSAkf1w59HF)67d9(yEFSginicosGuHX0uwjsAF84331Ty0h1y1PPuJmLPwwimqsbJagXsvUpC3pWAVpE87d9(ynqAqeCKaPcJPzR8(1331Ty0h1y1PPuJmLPwwimqsbJagXsvUpC2NaPcJPiHr01Ty0h1iGrSuL7d)(4XVp07J1aPbrWrcKkmMM0XE)6776wm6JAS60uQrMYullegiPGraJyPk3ho7tGuHXuKcm66wm6JAeWiwQY9HFF49OscKoYhcgEuZrzREuNjetZrzRtrkjpQiL0une2JomeRKNeivymj9KpemQTpupkRgebp8h6rDGKyqAEumVpzcwPy1PPuJmLPwwimqsbJSAqe8y)67d9(yEFSginicosGuHX0uwjsAF84331Ty0h1OSabP15WaWkfgGJagXsvUpC3pWAVpE87d9(ynqAqeCKaPcJPzR8(1331Ty0h1OSabP15WaWkfgGJagXsvUpC2NaPcJPiHr01Ty0h1iGrSuL7d)(4XVp07J1aPbrWrcKkmMM0XE)6776wm6JAuwGG06CyayLcdWraJyPk3ho7tGuHXuKcm66wm6JAeWiwQY9HFF49OscKoYhcgEuZrzREuNjetZrzRtrkjpQiL0une2JomeRKNeivymj9KpemWWhQhLvdIGh(d9OMJYw9OiMGVs3eyvubG9Odw6azfLT6rpSaO7l7cX(YtdmK7Nx7FLLN0(PCFtG0sA)gld8OoqsminpkKwk3V((xz5jnbmILQCF4Spd1SRG4jLi8(4cVVSlet5Pbg7xF)rtXcvsgebpTRlr6OS1iLoyPw6jFiyeOpupkRgebp8h6rhS0bYkkB1JI7V231yz1uA)rthGlpnLAK9rtTSqyGKcUFk3huOAQLbSFHK3hkzayLcdW7t9(mutSo2No59DfaaR0(sM8OMJYw9OotiMMJYwNIusEuhijgKMhf69DnwwnLIyzLodc2V((JMIjsfRJulNoJmjb6QtEoAksPdwQL7xFFx3IrFuJYceKwNddaRuyaocyelv5(Wz)a3V((qV)OPy1PPuJmLPwwimqsbJagXsvUpC3pW9XJFFmVpzcwPy1PPuJmLPwwimqsbJSAqe8yF43h(9XJFFO331yz1ukQz5jnVmE)67pAkk7cXe0uKshSul3V((UUfJ(OgLfiiTohgawPWaCeWiwQY9HZ(bUF99HE)rtXQttPgzktTSqyGKcgbmILQCF4UFG7Jh)(yEFYeSsXQttPgzktTSqyGKcgz1Gi4X(WVp87Jh)(qVp077ASSAkfv2bArdg7Jh)(UglRMsrybbPP7Jh)(UglRMsrTvEF43V((JMIvNMsnYuMAzHWajfmsPdwQL7xF)rtXQttPgzktTSqyGKcgbmILQCF4SFG7dVhvKsAQgc7rhgawPWa8ScWvEYhcg1YhQhLvdIGh(d9Odw6azfLT6rRP8fGLN7pAsUpBarW9ZR9l7ul3pvQ332xEAGX(YkwhPwUF1PjzpQ5OSvpQZeIP5OS1PiLKh1bsIbP5rHEFxJLvtPOMLN08Y49RVpM3F0uu2fIjOPiLoyPwUF99DDlg9rnk7cXe0ueWiwQY9HZ(3yF43hp(9HEFxJLvtPiwwPZGG9RVpM3F0umrQyDKA50zKjjqxDYZrtrkDWsTC)6776wm6JAmrQyDKA50zKjjqxDYraJyPk3ho7FJ9HFF843h69HEFxJLvtPOYoqlAWyF84331yz1ukcliinDF84331yz1ukQTY7d)(13NmbRuS60uQrMYullegiPGrwnicESF99X8(JMIvNMsnYuMAzHWajfmsPdwQL7xFFx3IrFuJvNMsnYuMAzHWajfmcyelv5(Wz)BSp8EurkPPAiShD00ScWvEYhcg3WhQhLvdIGh(d9OMJYw9OddaBk7cHhDWshiROSvpkU)AFC5PPuJSpAQLfcdKuW9t5(u6GLAza7N0(PCFPDX7t9(fsEFOKbGTpAxi8Ooqsminp6OPy1PPuJmLPwwimqsbJu6GLAPN8HGbU6d1JYQbrWd)HEuhijgKMhfZ7tMGvkwDAk1itzQLfcdKuWiRgebp2V((qV)OPOSletqtrkDWsTCF843F0umrQyDKA50zKjjqxDYZrtrkDWsTCF49OMJYw9OddaBk7cHN8HGXn7d1JYQbrWd)HEuZrzRE0QttPgzktTSqyGKc6rhS0bYkkB1JIguD7JlpnLAK9rtTSqyGKcU)XKo3hxqwPZGGdcjlpP9RjB8(UglRMs7pAkG9B6KbhtjVFHK3V19DDlg9rnUpU)AFChKQGa2e7JlcgQPoEFifxx7NY9t11iPwgW(NTySFHsPy)KWrUpGTrW9HgdO8(s216qUVDrmy)cjdVh1bsIbP5rDnwwnLIAwEsZlJ3V((uIW7d39X19RVVRBXOpQrzxiMGMIagXsvUpC2hJ9RVp0776wm6JAKrQccytmBWqn1XraJyPk3ho7JXnh4(4XVpM3NXKfzvfpImsvqaBIzdgQPoEF49KpemQ5(q9OSAqe8WFOh1bsIbP5rDnwwnLIyzLodc2V((uIW7d39X19RVVRBXOpQXePI1rQLtNrMKaD1jhbmILQCF4Spg7xFFO331Ty0h1iJufeWMy2GHAQJJagXsvUpC2hJBoW9XJFFmVpJjlYQkEezKQGa2eZgmutD8(W7rnhLT6rRonLAKPm1YcHbskON8HGbu2hQhLvdIGh(d9Ooqsminpk077ASSAkfv2bArdg7Jh)(UglRMsrybbPP7Jh)(UglRMsrTvEF43V((qVVRBXOpQrgPkiGnXSbd1uhhbmILQCF4Spg3CG7Jh)(yEFgtwKvv8iYivbbSjMnyOM649H3JAokB1JwDAk1itzQLfcdKuqp5dbJAcFOEuwnicE4p0J6ajXG08OqAPC)67FLLN0eWiwQY9HZ(yCZEuZrzRE0QttPgzktTSqyGKc6jFibwBFOEuwnicE4p0JoyPdKvu2Qhf3FTpU80uQr2hn1YcHbsk4(PCFkDWsTmG9tch5(uIW7t9(fsE)MozW(iwnRgS)OjPh1Cu2Qh1zcX0Cu26uKsYJ6ajXG08OJMIvNMsnYuMAzHWajfmsPdwQL7xFFO331yz1ukQz5jnVmEF84331yz1ukILv6miyF49OIust1qypQRXYQPKN8Heig(q9OSAqe8WFOh1Cu2Qh1kBnOh1bsIbP5rhnfTYwdgbmILQCF4S)n8OUGobpjduYK0hcgEYhsGb6d1JAokB1JEAfk5rz1Gi4H)qp5djWA5d1JYQbrWd)HEuZrzREujZJzFnDnauurzRE0blDGSIYw9OO9X9PtEFuMhY9BD)ATpzGsMK7Nx7N0(PuXH23vaaSsIG7N6(xIS8K2Vb736(0jVpzGsMI7J7M05(Oz1zR7dv5fVFs4i33eYEFimrmyFQ3VqY7JY8y)gld2hX0cticUVvvjcMA5(1AFOObGIkkBvg9OoqsminpQ5OelpzLrswUpC3pW9RVpzcwPOSpoPtEkzEiJSAqe8y)67J59hnfLmpM9101aqrfLTgP0bl1Y9RVpM3p15Lilpjp5djWB4d1JYQbrWd)HEuhijgKMh1CuILNSYijl3hU7h4(13NmbRuuMvNTof5fhz1Gi4X(13hZ7pAkkzEm7RPRbGIkkBnsPdwQL7xFFmVFQZlrwEs7xF)rtrxdafvu2AeWiwQY9HZ(3WJAokB1JkzEm7RPRbGIkkB1t(qcex9H6rz1Gi4H)qpQdKedsZJc9(YUqmLNgySpC3hJ9XJFFZrjwEYkJKSCF4UFG7d)(1331Ty0h1OSabP15WaWkfgGJagXsvUpC3hJa9OMJYw9OytbpjlvYt(qc8M9H6rz1Gi4H)qpQdKedsZJAokXYZrtXcvsgebpTRlr6OS19dVFT3hp(9P0bl1Y9RV)OPyHkjdIGN21LiDu2AeWiwQY9HZ(3WJAokB1JwOsYGi4PDDjshLT6jFibwZ9H6rz1Gi4H)qpQdKedsZJI59DnwwnLIk7aTObdpQKaPJ8HGHh1Cu2Qh1zcX0Cu26uKsYJksjnvdH9OUglRMsEYhsGqzFOEuwnicE4p0JAokB1J6AaOOIYw9OUGobpjduYK0hcgEuhijgKMh1CuILNSYijl3ho7FJ9VP9HEFYeSsrzFCsN8uY8qgz1Gi4X(4XVpzcwPOmRoBDkYloYQbrWJ9HF)67pAk6AaOOIYwJagXsvUpC2pqp6GLoqwrzREumrvLi4(qrdafvu26(iMwycrW9BDFmUPa3NmqjtYa2Vb736(1A)JjDUpMaISffeVpu0aqrfLT6jFibwt4d1JYQbrWd)HEuZrzREuetWxPBcSkQaWE0blDGSIYw9OyIlIb7tN8(DfRmiG9LvSo232xEAGX(hpzDFJ2hx3V19RzmbFLU9RPwfva49PEFdBNJ9BSmWzvvPw6rDGKyqAEuzxiMYtdm2hU7FJ9RVpLi8(WD)aXWt(qQvT9H6rz1Gi4H)qp6GLoqwrzREuC3tw3xBAFzq1LA5(4YttPgzF0ullegiPG7t9(4cYkDgeCqiz5jTFnzJdyF0ceKw3hkzayLcdW7Nx7BcX(JMK7BaEFRQsK8WJAokB1J6mHyAokBDksj5rDGKyqAEuO331yz1ukILv6miy)67J59jtWkfRonLAKPm1YcHbskyKvdIGh7xF)rtXePI1rQLtNrMKaD1jphnfP0bl1Y9RVVRBXOpQrzbcsRZHbGvkmahbSncUp87Jh)(qVVRXYQPuuZYtAEz8(13hZ7tMGvkwDAk1itzQLfcdKuWiRgebp2V((JMIYUqmbnfP0bl1Y9RVVRBXOpQrzbcsRZHbGvkmahbSncUp87Jh)(qVp077ASSAkfv2bArdg7Jh)(UglRMsrybbPP7Jh)(UglRMsrTvEF43V((UUfJ(OgLfiiTohgawPWaCeW2i4(W7rfPKMQHWE0HbGvkmapRaCLN8Hulm8H6rz1Gi4H)qpQ5OSvp6WaWMYUq4rhS0bYkkB1JwZwY7dLmaS9r7cX(51(qjdaRuyaE)JTIdTpeEFaBJG7BLwQbSFd2pV2NozaV)Xui2hcVVr7lyts7h4(inG3hkzayLcdW7xizPh1bsIbP5rH0s5(1331Ty0h1OSabP15WaWkfgGJagXsvUpC3)klpPjGrSuL7xFFO3hZ7tMGvkwDAk1itzQLfcdKuWiRgebp2hp(9DDlg9rnwDAk1itzQLfcdKuWiGrSuL7d39VYYtAcyelv5(W7jFi1kqFOEuwnicE4p0J6ajXG08OyEFYeSsXQttPgzktTSqyGKcgz1Gi4X(1331Ty0h1OSabP15WaWkfgGJagXsvU)T776wm6JAuwGG06CyayLcdWXrbWOS19HZ(xz5jnbmILQ0JAokB1JomaSPSleEYhsTQLpupkRgebp8h6rhS0bYkkB1Jcfg5oVjti2pjgz)cPvY7F1G9nniDMA5(At7lRyxEL8yFwi5JNmG9OMJYw9OotiMMJYwNIusEurkPPAiShnjgXt(qQ1n8H6rz1Gi4H)qpQdKedsZJkySSyF4UpUwZ3V((qV)GHuCDfLN2OpozeiaZXrjzoy7dN9HE)a3)M23Cu2AuEAJ(4eslOyQZlrwEs7d)(4XV)GHuCDfLN2OpozeiaZXraJyPk3ho7xR9H3JAokB1J6mHyAokBDksj5rfPKMQHWEuj7jFi1cx9H6rz1Gi4H)qpQ5OSvpkIj4R0nbwfvayp6GLoqwrzRE0A2sE)AgtWxPB)AQvrfaE)JNSUpIvZQb7pAsUVb49lQcy)gSFETpDYaE)JPqSpeEFzwQ5v6mL2NseE)cLsX(0jVVYqnTpU80uQr2hn1YcHbskOh1bsIbP5rhnfXMcEswQuKshSul3hp(9hnftKkwhPwoDgzsc0vN8C0uKshSul3hp(9hnfLDHycAksPdwQLEYhsTUzFOEuwnicE4p0J6ajXG08OKjyLIvNMsnYuMAzHWajfmYQbrWJ9RVp07pAkwDAk1itzQLfcdKuWiLoyPwUpE8776wm6JAS60uQrMYullegiPGraJyPk3hU7hiUUpE87FLLN0eWiwQY9HZ(UUfJ(OgRonLAKPm1YcHbskyeWiwQY9H3JAokB1JIyc(kDtGvrfa2t(qQvn3hQhLvdIGh(d9OoqsminpkzcwPOSpoPtEkzEiJSAqe8WJAokB1JIyc(kDtGvrfa2t(qQfu2hQhLvdIGh(d9OMJYw9OdGL6uKxShDWshiROSvpkucyPUpuLx8(PC)wfb332hkHlr3V0sD)JjDUpUxzSjzqe8(qjgjL8(kBG9rmOEFjzoyY4(4(R9VYYtA)uUVbPlO9PEFwh7p691M2hjLY9LvSosTCF6K3xsMdM0J6ajXG08OqkUUIPYytYGi45GrsjhLK5GTpC3)g1EF843hsX1vmvgBsgebphmsk5yr1(13)klpPjGrSuL7dN9VHN8HuRAcFOEuwnicE4p0JAokB1J6mHyAokBDksj5rfPKMQHWEuxJLvtjp5d5g12hQhLvdIGh(d9OMJYw9OwzRb9OoqsminpkGVaS80GiypQlOtWtYaLmj9HGHN8HCdm8H6rz1Gi4H)qpQdKedsZJAokXYZrtXcvsgebpTRlr6OS19dVFT3hp(9P0bl1Y9RVpGVaS80GiypQ5OSvpAHkjdIGN21LiDu2QN8HCJa9H6rz1Gi4H)qpQ5OSvpQmRoBDkYl2J6ajXG08Oa(cWYtdIG9OUGobpjduYK0hcgEYhYnQLpupkRgebp8h6rnhLT6rDnauurzREuhijgKMhfWxawEAqe8(133CuILNSYijl3ho7FJ9VP9HEFYeSsrzFCsN8uY8qgz1Gi4X(4XVpzcwPOmRoBDkYloYQbrWJ9H3J6c6e8KmqjtsFiy4jFi34g(q9OPsmauurEum8OMJYw9OdGL6u2fcpkRgebp8h6jFi3ax9H6rnhLT6rLN2OpoH0cYJYQbrWd)HEYtE0ka7Aeig5d1hcg(q9OSAqe8WFOh1bsIbP5rPeH3hU7x79RVpM3VIPOjsS8(13hZ7dP46kwcsKob8SVMsZbYR0XXIkpQ5OSvp6flMJgjvJYw9KpKa9H6rnhLT6rLfiiToVyXzHsmWJYQbrWd)HEYhsT8H6rz1Gi4H)qpQdKedsZJsMGvkwcsKob8SVMsZbYR0XrwnicE4rnhLT6rlbjsNaE2xtP5a5v6yp5d5g(q9OSAqe8WFOhTR8OsM8OMJYw9OynqAqeShfRjkypQ5OelphnfDnauurzR7d39R9(133CuILNJMIwzRb3hU7x79RVV5Oelphnflujzqe80UUePJYw3hU7x79RVp07J59jtWkfLz1zRtrEXrwnicESpE87BokXYZrtrzwD26uKx8(WD)AVp87xFFO3F0uS60uQrMYullegiPGrkDWsTCF843hZ7tMGvkwDAk1itzQLfcdKuWiRgebp2hEpkwdmvdH9OJMKtaBJGEYhcU6d1JYQbrWd)HEu1qypQHlK80aMCE1kn7RzvFKbEuZrzREudxi5Pbm58QvA2xZQ(id8KpKB2hQhLvdIGh(d9OMJYw9OsMhZ(A6AaOOIYw9OoqsminpQSIfIjzGsMKrjZJzFnDnauurzRtR59HB49RLhvKkpDdpkg12t(qQ5(q9OMJYw9ONwHsEuwnicE4p0t(qGY(q9OMJYw9OfQKmicEAxxI0rzREuwnicE4p0tEYJAn7d1hcg(q9OMJYw9OvNMsnYuMAzHWajf0JYQbrWd)HEYhsG(q9OMJYw9ONwHsEuwnicE4p0t(qQLpupkRgebp8h6rDGKyqAEuO331yz1ukILv6miy)67pAkMivSosTC6mYKeORo55OPiLoyPwUF99DDlg9rnklqqADomaSsHb4iGTrW9RVp07pAkwDAk1itzQLfcdKuWiGrSuL7d39dCF843hZ7tMGvkwDAk1itzQLfcdKuWiRgebp2h(9HFF843h69DnwwnLIAwEsZlJ3V((JMIYUqmbnfP0bl1Y9RVVRBXOpQrzbcsRZHbGvkmahbSncUF99HE)rtXQttPgzktTSqyGKcgbmILQCF4UFG7Jh)(yEFYeSsXQttPgzktTSqyGKcgz1Gi4X(WVp87xFFO3h69DnwwnLIk7aTObJ9XJFFxJLvtPiSGG009XJFFxJLvtPO2kVp87xF)rtXQttPgzktTSqyGKcgP0bl1Y9RV)OPy1PPuJmLPwwimqsbJagXsvUpC2pW9H3JAokB1J6mHyAokBDksj5rfPKMQHWE0HbGvkmapRaCLN8HCdFOEuwnicE4p0J6ajXG08OKjyLIY(4Ko5PK5HmYQbrWJ9RVVZ0PK5Hh1Cu2QhvY8y2xtxdafvu2QN8HGR(q9OSAqe8WFOh1bsIbP5rX8(KjyLIY(4Ko5PK5HmYQbrWJ9RVpM3F0uuY8y2xtxdafvu2AKshSul3V((yE)uNxIS8K2V((JMIUgakQOS1iGVaS80GiypQ5OSvpQK5XSVMUgakQOSvp5d5M9H6rz1Gi4H)qpQ5OSvpQv2AqpQdKedsZJAokXYZrtrRS1G7dN9VX(13hWxawEAqeSh1f0j4jzGsMK(qWWt(qQ5(q9OSAqe8WFOh1Cu2Qh1kBnOh1bsIbP5rnhLy55OPOv2AW9HB49VX(13hWxawEAqe8(13F0u0kBnyKshSul9OUGobpjduYK0hcgEYhcu2hQhLvdIGh(d9OoqsminpQ5Oelphnflujzqe80UUePJYw3p8(1EF843NshSul3V((a(cWYtdIG9OMJYw9OfQKmicEAxxI0rzREYhsnHpupkRgebp8h6rnhLT6rlujzqe80UUePJYw9OoqsminpkM3NshSul3V((vyRitWkfbgsLP00UUePJYwLrwnicESF99nhLy55OPyHkjdIGN21LiDu26(Wz)A5rDbDcEsgOKjPpem8KpemQTpupkRgebp8h6rDGKyqAEuzxiMYtdm2hU7JHh1Cu2QhfBk4jzPsEYhcgy4d1JYQbrWd)HEuhijgKMhfZ77ASSAkfv2bArdgEujbsh5dbdpQ5OSvpQZeIP5OS1PiLKhvKsAQgc7rDnwwnL8Kpemc0hQhLvdIGh(d9Ooqsminpk077ASSAkfXYkDgeSF99HEFx3IrFuJjsfRJulNoJmjb6QtocyBeCF843F0umrQyDKA50zKjjqxDYZrtrkDWsTCF43V((UUfJ(OgLfiiTohgawPWaCeW2i4(13h69hnfRonLAKPm1YcHbskyeWiwQY9H7(bUpE87J59jtWkfRonLAKPm1YcHbskyKvdIGh7d)(WVF99HEFO331yz1ukQSd0Igm2hp(9DnwwnLIWccst3hp(9DnwwnLIAR8(WVF99DDlg9rnklqqADomaSsHb4iGrSuL7dN9dC)67d9(JMIvNMsnYuMAzHWajfmcyelv5(WD)a3hp(9X8(KjyLIvNMsnYuMAzHWajfmYQbrWJ9HFF43h69DnwwnLIAwEsZlJ3V((qVVRBXOpQrzxiMGMIa2gb3hp(9hnfLDHycAksPdwQL7d)(1331Ty0h1OSabP15WaWkfgGJagXsvUpC2pW9RVp07pAkwDAk1itzQLfcdKuWiGrSuL7d39dCF843hZ7tMGvkwDAk1itzQLfcdKuWiRgebp2h(9H3JAokB1J6mHyAokBDksj5rfPKMQHWE0HbGvkmapRaCLN8HGrT8H6rz1Gi4H)qpQdKedsZJ66wm6JAuwGG06CyayLcdWraJyPk3hU7FLLN0eWiwQY9RVp07J59jtWkfRonLAKPm1YcHbskyKvdIGh7Jh)(UUfJ(OgRonLAKPm1YcHbskyeWiwQY9H7(xz5jnbmILQCF49OMJYw9OddaBk7cHN8HGXn8H6rz1Gi4H)qpQdKedsZJ66wm6JAuwGG06CyayLcdWraJyPk3)29DDlg9rnklqqADomaSsHb44Oayu26(Wz)RS8KMagXsv6rnhLT6rhga2u2fcp5dbdC1hQhLvdIGh(d9OMJYw9OotiMMJYwNIusEurkPPAiShnjgXt(qW4M9H6rz1Gi4H)qpQ5OSvpQZeIP5OS1PiLKhvKsAQgc7rhSWcYJjbsfgtsp5dbJAUpupkRgebp8h6rnhLT6rDMqmnhLTofPK8OIust1qyp6WqSsEsGuHXK0t(qWak7d1JYQbrWd)HEuhijgKMhD0uS60uQrMYullegiPGrkDWsTCF843hZ7tMGvkwDAk1itzQLfcdKuWiRgebp8OMJYw9OotiMMJYwNIusEurkPPAiShvsgnjqQWys6jFiyut4d1JYQbrWd)HEuhijgKMhD0ueBk4jzPsrkDWsT0JAokB1JIyc(kDtGvrfa2t(qcS2(q9OSAqe8WFOh1bsIbP5rhnfLDHycAksPdwQL7xFFmVpzcwPOSpoPtEkzEiJSAqe8WJAokB1JIyc(kDtGvrfa2t(qcedFOEuwnicE4p0J6ajXG08OyEFYeSsrSPGNKLkfz1Gi4Hh1Cu2QhfXe8v6MaRIkaSN8HeyG(q9OSAqe8WFOh1bsIbP5rLDHykpnWyF4U)n8OMJYw9OiMGVs3eyvubG9KpKaRLpupkRgebp8h6rnhLT6rLz1zRtrEXEuhijgKMh1CuILNJMIYS6S1PiV49Ht49R1(13hWxawEAqe8(13hZ7pAkkZQZwNI8IJu6GLAPh1f0j4jzGsMK(qWWt(qc8g(q9OSAqe8WFOh1bsIbP5rDnwwnLIk7aTObdpQKaPJ8HGHh1Cu2Qh1zcX0Cu26uKsYJksjnvdH9OUglRMsEYhsG4QpupkRgebp8h6rDGKyqAEuifxxXuzSjzqe8CWiPKJsYCW2hUH3hxR9(4XVpKIRRyQm2KmicEoyKuYXIQ9RV)vwEstaJyPk3ho7JR7Jh)(qkUUIPYytYGi45GrsjhLK5GTpCdVFTW19RV)OPOSletqtrkDWsT0JAokB1JoawQtrEXEYhsG3SpupAQedafvKhfdpQ5OSvp6ayPoLDHWJYQbrWd)HEYhsG1CFOEuZrzREu5Pn6JtiTG8OSAqe8WFON8KhnjgXhQpem8H6rnhLT6rlK8mjgr6rz1Gi4H)qp5jpQK9H6dbdFOEuZrzRE0tRqjpkRgebp8h6jFib6d1JYQbrWd)HE0ujgakQOzE5rhmKIRRO80g9XjJabyookjZbdUHRLh1Cu2QhDaSuNYUq4rtLyaOOIMLIgIj8Oy4jFi1YhQh1Cu2QhvEAJ(4eslipkRgebp8h6jp5rLKrtcKkmMK(q9HGHpupkRgebp8h6rvdH9OPkDGcYGi4jMSWuQazoySPJ9OMJYw9OPkDGcYGi4jMSWuQazoySPJ9KpKa9H6rz1Gi4H)qpQAiShnvjbkCudKZrInvEcHfcpQ5OSvpAQscu4OgiNJeBQ8ecleEYhsT8H6rz1Gi4H)qpQAiShTXYGlrFm1YPPjInDwj7rnhLT6rBSm4s0htTCAAIytNvYEYhYn8H6rz1Gi4H)qpQAiShDyayiDRZb7GnRkialDS6ypQ5OSvp6WaWq6wNd2bBwvqaw6y1XEYhcU6d1JYQbrWd)HEu1qypkI5miaEkpzMMifY05rnhLT6rrmNbbWt5jZ0ePqMop5d5M9H6rz1Gi4H)qpQAiSh9syi8SVMqmIeSh1Cu2Qh9syi8SVMqmIeSN8HuZ9H6rz1Gi4H)qpQAiSh9ObJvgiNxGwhEuZrzRE0JgmwzGCEbAD4jFiqzFOEuwnicE4p0JQgc7rjdIGPzFnhSSYsGh1Cu2QhLmicMM91CWYklbEYhsnHpupkRgebp8h6rvdH9OYuVkettwLatj5eInk5zFnVyq7skOh1Cu2QhvM6vHyAYQeykjNqSrjp7R5fdAxsb9KpemQTpupkRgebp8h6rvdH9OYuVkeZsHnsJAGCcXgL8SVMxmODjf0JAokB1Jkt9Qqmlf2inQbYjeBuYZ(AEXG2Luqp5dbdm8H6rnhLT6rHi6EmVkab9OSAqe8WFON8HGrG(q9OMJYw9OxjGHi6E4rz1Gi4H)qp5dbJA5d1JAokB1JcHbsgal1spkRgebp8h6jp5jpQvqNnWJIMiqHN8K3d]] )


end