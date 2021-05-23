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


    spec:RegisterPack( "Affliction", 20210523, [[d8eTGcqiOuwKGuQEeuQSjjvFckzuaQtbuTkOOk1RuP0SeGBPsb7sOFPcmmvk6yqHLjGEMKsMMKsDnGsTnGI8narzCaICoar16GIY8aKUNGAFqroiqrTqvqpeqyIQuOlcLQ0gfKQYhfKQQtkifRuLQzcu4MqPk2PG4NqrvnuOuvlvqQ8uinvjfxvqQsBvqQIVkiLmwbj7LQ(RIgSQomLfdWJPYKv4YeBwL8zjA0QOtlA1qrv8AGmBuUne7M0VLA4sYXHIklh0Zr10rUUe2ou57QqJhOKZlqRhkQsMpu19fKsz)kThdFnE0HrIpKaVzGyCtWoWAfVjqoyxBWgi5rPGvIhTYCGSsXJQgI4rbZxxS0rzRE0kliRTHVgpkVlGoXJEsufhZo4GYKolaeDnYb8ePGzu2QdAx0b8eXDGhfqrYOqJ6b4rhgj(qc8MbIXnb7aRv8Ma5GDTbBWKhLxjoFibcMaBp6zogI6b4rhc35rbZxxS0rzR7hAzqw7aT3XESG7hyTcy)aVzGyS337aXPPLchZ273W(G5Xqg7Jwjm2(Gr7af373W(G5Xqg7FJcUUaUp2JvMU4E)g2hmpgYyFaqXa5onvf2(SUmD7F1W9VrOL6(ODblU3VH9R5OyG2h7XyYv62p0zvubu2N1LPBFQ3)ydbTFETFWUalOSpsY5PwUVTpzmrP9tDF60O9H9X4E)g2h7vnamz)qNHuzkTpy(6ILokBLVp2hh2FFYyIsX9(nSFnhfdeFFQ33W15yFaS(yQL7FJgeujZGY(PUpsbJYBGmyPq7F8GE)BeZVg((fvX9(nSpq06quUSpVrK9VrdcQKzqzFSpuQ23zmgFFQ3hkJcNSVRrQkiJYw3NsejU3VH9rfAFEJi77mgBAokBDYsoTVOemf((uVpNGPJ2N69nCDo23DkoqPwUpl5eFF60O9p2kw0(aK9HI5oLrCVFd7J5RSG7JkYy)wDY(vq5gQkyS4E)g2hmpW8uWP9dTdOaQ7de3iFFaYvdL9fDSFFT)vwEsH23N1LPBFQ33QQyb3VvwW9PEFanNV)vwEs89bwBAFcA8Z9Rmhio4rpAfSVsM4rXoSBFW81flDu26(HwgK1oq7DSd72h7XcUFG1kG9d8MbIXEFVJDy3(aXPPLchZ27yh2T)nSpyEmKX(OvcJTpy0oqX9o2HD7Fd7dMhdzS)nk46c4(ypwz6I7DSd72)g2hmpgYyFaqXa5onvf2(SUmD7F1W9VrOL6(ODblU3XoSB)By)AokgO9XEmMCLU9dDwfvaL9zDz62N69p2qq7Nx7hSlWck7JKCEQL7B7tgtuA)u3NonAFyFmU3XoSB)ByFSx1aWK9dDgsLP0(G5Rlw6OSv((yFCy)9jJjkf37yh2T)nSFnhfdeFFQ33W15yFaS(yQL7FJgeujZGY(PUpsbJYBGmyPq7F8GE)BeZVg((fvX9o2HD7Fd7deToeLl7ZBez)B0GGkzgu2h7dLQ9DgJX3N69HYOWj77AKQcYOS19PerI7DSd72)g2hvO95nISVZySP5OS1jl50(IsWu47t9(CcMoAFQ33W15yF3P4aLA5(SKt89PtJ2)yRyr7dq2hkM7ugX9o2HD7Fd7J5RSG7JkYy)wDY(vq5gQkyS4Eh7WU9VH9bZdmpfCA)q7akG6(aXnY3hGC1qzFrh73x7FLLNuO99zDz62N69TQkwW9BLfCFQ3hqZ57FLLNeFFG1M2NGg)C)kZbIdECVV3nhLTYJvqX1iamk8LWMJgjvJYwdiVctjIGPBwhBvcfnwItQJnafxxXsyI0juM91KBoyELojwuT3nhLTYJvqX1iam62WhWlqqADwj0E3Cu2kpwbfxJaWOBdFqjmr6ekZ(AYnhmVsNeqEfMmMOuSeMiDcLzFn5MdMxPtIIAayYyVBokBLhRGIRray0THpaNbtdatcqnej8Oj(ek2iya4mwHe2CuItMJMIUgclQOSvmDZ6MJsCYC0u0kBniMUzDZrjozoAkwOCYaWKPDDXshLTIPBwhySrgtukYZQZwNS8sIIAayYapEZrjozoAkYZQZwNS8sW0nbVoWJMIvNMsnYKNAzbZGjfmsPduQL4XJnYyIsXQttPgzYtTSGzWKcgf1aWKb47DZrzR8yfuCncaJUn8bfCzMKGeGAisydZl(Pbn(8QvA2xZQ(Oa37MJYw5XkO4AeagDB4d4ImM9101qyrfLTgalvz6gHX4MbKxH5vcJnjdwkepYfzm7RPRHWIkkBDATGPW1AVBokBLhRGIRray0THp40kuAVBokBLhRGIRray0THpOq5KbGjt76ILokBDVV3XoSBFSxWsCfKm2xWjWG7tjISpDk7BoQH7N89nCwYmamjU3nhLTYdZRegBYAhO9U5OSv(THpyi46c4eXkt3E3Cu2k)2Wh4mgBAokBDYsofGAisyRLa4emDuymciVcBokXjtrfKu4yQw7DSBFWSJYw3NLCIV)vd3NGPcsO9biNgUSHX9rjJ47BqzFUHtg7F1W9bixnu2hTly7h6A6GqdsLOJul3himY4eSRoLdW(NMsnY(OPwwWmysbdy)Mof4XKl736(UUzJ(OU3nhLTYVn8boJXMMJYwNSKtbOgIeMGPcsOjVIL00DkoqbWjy6OWyeqEfMsebOyS3nhLTYVn8boJXMMJYwNSKtbOgIeEimlOmMemvqcX37MJYw53g(aNXytZrzRtwYPaudrcZjJMemvqcXdGtW0rHXiG8kmWJMI8UGnHnfP0bk1s84hnftKkrhPwoDgzCc2vNYC0uKshOulXJF0uS60uQrM8ullygmPGrkDGsTe868UGn5NgCGPAHh)OPiUKjtYsLIu6aLAjE8KXeLI8(4KoLjxKbFVBokBLFB4dCgJnnhLTozjNcqnej8WqSszsWubjepaobthfgJaYRWUgNOMsrnlpP5Lj1bgB4myAaysKGPcsOjVILeE8UUzJ(Og5DbBcBkcfelvoMc8M4XdmodMgaMejyQGeA2Qu31nB0h1iVlytytrOGyPYbkbtfKqrmIUUzJ(OgHcILkhC84bgNbtdatIemvqcnPJDDx3SrFuJ8UGnHnfHcILkhOemvqcfdm66Mn6JAekiwQCWbFVBokBLFB4dCgJnnhLTozjNcqnej8WqSszsWubjepaobthfgJaYRWUgNOMsrCIsNbH1bgB4myAaysKGPcsOjVILeE8UUzJ(OgtKkrhPwoDgzCc2vNsekiwQCmf4nXJhyCgmnamjsWubj0SvPURB2OpQXePs0rQLtNrgNGD1PeHcILkhOemvqcfXi66Mn6JAekiwQCWXJhyCgmnamjsWubj0Ko21DDZg9rnMivIosTC6mY4eSRoLiuqSu5aLGPcsOyGrx3SrFuJqbXsLdo47DZrzR8BdFGZySP5OS1jl5uaQHiHhgIvktcMkiH4bWjy6OWyeqEfgyxJtutPOkoyZA4apExJtutPiOGW0u84DnornLIARc41bgB4myAaysKGPcsOjVILeE8UUzJ(OgRonLAKjp1YcMbtkyekiwQCmf4nXJhyCgmnamjsWubj0SvPURB2OpQXQttPgzYtTSGzWKcgHcILkhOemvqcfXi66Mn6JAekiwQCWXJhyCgmnamjsWubj0Ko21DDZg9rnwDAk1itEQLfmdMuWiuqSu5aLGPcsOyGrx3SrFuJqbXsLdo47DZrzR8BdFGZySP5OS1jl5uaQHiHhgIvktcMkiH4bWjy6OWyeqEfgBKXeLIvNMsnYKNAzbZGjfmkQbGjJ6aJnCgmnamjsWubj0KxXscpEx3SrFuJ8ceKwNddcQKzqjcfelvoMc8M4XdmodMgaMejyQGeA2Qu31nB0h1iVabP15WGGkzguIqbXsLducMkiHIyeDDZg9rncfelvo44XdmodMgaMejyQGeAsh76UUzJ(Og5fiiTohgeujZGsekiwQCGsWubjumWORB2OpQrOGyPYbh89o2T)HfqDFExW2NFAWbF)8A)RS8K2p57BmKMt734e4E3Cu2k)2WhGym5kDtOvrfqjG8kmGMZRFLLN0ekiwQCGkGL4kizsjIG5nVlyt(Pbh1hnfluozayY0UUyPJYwJu6aLA5Eh72p0CTVRXjQP0(JMoa7FAk1i7JMAzbZGjfC)KVpSq1uldy)cUS)nAqqLmdk7t9(cyrIo2NoL9DfqOO0(CH27MJYw53g(aNXytZrzRtwYPaudrcpmiOsMbLzfuQciVcdSRXjQPueNO0zqy9rtXePs0rQLtNrgNGD1PmhnfP0bk1Y6UUzJ(Og5fiiTohgeujZGsekiwQCGgyDGhnfRonLAKjp1YcMbtkyekiwQCmfiE8yJmMOuS60uQrM8ullygmPGGdoE8a7ACIAkf1S8KMxMuF0uK3fSjSPiLoqPww31nB0h1iVabP15WGGkzguIqbXsLd0aRd8OPy1PPuJm5PwwWmysbJqbXsLJPaXJhBKXeLIvNMsnYKNAzbZGjfeCWXJhyGDnornLIQ4GnRHd84DnornLIGccttXJ314e1ukQTkGxF0uS60uQrM8ullygmPGrkDGsTS(OPy1PPuJm5PwwWmysbJqbXsLd0abFVJD7h6KlOWp3F0eFFXGSG7Nx7x2PwUFQuVVTp)0GJ95vIosTC)QtJl7DZrzR8BdFGZySP5OS1jl5uaQHiHhnnRGsva5vyGDnornLIAwEsZltQJTrtrExWMWMIu6aLAzDx3SrFuJ8UGnHnfHcILkhO1gC84b214e1ukItu6miSo2gnftKkrhPwoDgzCc2vNYC0uKshOulR76Mn6JAmrQeDKA50zKXjyxDkrOGyPYbATbhpEGb214e1ukQId2SgoWJ314e1ukckimnfpExJtutPO2QaEDYyIsXQttPgzYtTSGzWKcwhBJMIvNMsnYKNAzbZGjfmsPduQL1DDZg9rnwDAk1itEQLfmdMuWiuqSu5aT2GV3XU9dnx7J9pnLAK9rtTSGzWKcUFY3NshOuldy)K2p57ZTlzFQ3VGl7FJge0(ODbBVBokBLFB4dgge0K3fSaYRWJMIvNMsnYKNAzbZGjfmsPduQL7DZrzR8BdFWWGGM8UGfqEfgBKXeLIvNMsnYKNAzbZGjfSoWJMI8UGnHnfP0bk1s84hnftKkrhPwoDgzCc2vNYC0uKshOulbFVJD7JguD7J9pnLAK9rtTSGzWKcU)XKo3p0JO0zq4bHKLN0(H(mzFxJtutP9hnfW(nDkWJjx2VGl736(UUzJ(Og3p0CTp2lsvqOyS9X8Hd1uNSpGIRR9t((P6AKuldy)ZMn2VqPKTFsyX3hk2i4(aJbqAFU4ADW33UibUFbxaFVBokBLFB4dQonLAKjp1YcMbtkya5vyxJtutPOMLN08YK6uIiycSR76Mn6JAK3fSjSPiuqSu5afJ6atWubjuuqQccfJnB4qn1jrx3SrFuJqbXsLdumatbIhp2emxrwvjJOGufekgB2WHAQtaFVBokBLFB4dQonLAKjp1YcMbtkya5vyxJtutPiorPZGW6uIiycSR76Mn6JAmrQeDKA50zKXjyxDkrOGyPYbkg1bMGPcsOOGufekgB2WHAQtIUUzJ(OgHcILkhOyaMcepESjyUISQsgrbPkium2SHd1uNa(E3Cu2k)2WhuDAk1itEQLfmdMuWaYRWa7ACIAkfvXbBwdh4X7ACIAkfbfeMMIhVRXjQPuuBvaVoWemvqcffKQGqXyZgoutDs01nB0h1iuqSu5afdWuG4XJnbZvKvvYikivbHIXMnCOM6eW37MJYw53g(GQttPgzYtTSGzWKcgqEfgqZ51VYYtAcfelvoqXamT3XU9dnx7J9pnLAK9rtTSGzWKcUFY3NshOuldy)KWIVpLiY(uVFbx2VPtbUpIH5PH7pAIV3nhLTYVn8boJXMMJYwNSKtbOgIe214e1ukG8k8OPy1PPuJm5PwwWmysbJu6aLAzDGDnornLIAwEsZltWJ314e1ukItu6mie89U5OSv(THpWkBnyaUGoMmjdwkepmgbKxHhnfTYwdgHcILkhO1EVBokBLFB4doTcL27y3(O9X9PtzFurg89BD)ATpzWsH47Nx7N0(jxXI23vaHIsSG7N6(xSS8K2VH736(0PSpzWsHI7hAL05(Oz1zR7dg5LSFsyX33y8EFacrcCFQ3VGl7JkYy)gNa3hX0cJXcUVvvXcMA5(1AFGOHWIkkBLh37MJYw53g(aUiJzFnDnewurzRbKxHnhL4KPOcskCmfyDYyIsrEFCsNYKlYGxhBJMICrgZ(A6AiSOIYwJu6aLAzDSL68ILLN0E3Cu2k)2WhWfzm7RPRHWIkkBnG8kS5OeNmfvqsHJPaRtgtukYZQZwNS8sQJTrtrUiJzFnDnewurzRrkDGsTSo2sDEXYYtQ(OPORHWIkkBncfelvoqR9E3Cu2k)2WhGlzYKSuPaYRWaZ7c2KFAWbMWapEZrjozkQGKchtbcEDx3SrFuJ8ceKwNddcQKzqjcfelvoMWiW9U5OSv(THpOq5KbGjt76ILokBnG8kS5OeNmhnfluozayY0UUyPJYwdFt84P0bk1Y6JMIfkNmamzAxxS0rzRrOGyPYbAT37MJYw53g(aEwD26KLxsaUGoMmjdwkepmgbKxHhnf5z1zRtwEjrOGyPYbAT37MJYw53g(aNXytZrzRtwYPaudrc7ACIAkfaNGPJcJra5vyS5ACIAkfvXbBwdh7DSBFWCvfl4(ardHfvu26(iMwymwW9BDFmUHa3NmyPq8a2VH736(1A)JjDUpygaVzfKSpq0qyrfLTU3nhLTYVn8bUgclQOS1aCbDmzsgSuiEymciVcBokXjtrfKu4aT23aWKXeLI8(4KoLjxKbhpEYyIsrEwD26KLxc41hnfDnewurzRrOGyPYbAG7DSBFW8fjW9Ptz)UsubgW(8krh7B7Zpn4y)JNIUVr7d2736(ypgtUs3(HoRIkGY(uVVHRZX(nob6SQQul37MJYw53g(aeJjxPBcTkQakbKxH5DbBYpn4at1UoLicMceJ9o2TFO1PO7RnTppO6sTCFS)PPuJSpAQLfmdMuW9PE)qpIsNbHheswEs7h6ZKa2hTabP19VrdcQKzqz)8AFJX2F0eFFdk7BvvSug7DZrzR8BdFGZySP5OS1jl5uaQHiHhgeujZGYSckvbKxHb214e1ukItu6miSo2iJjkfRonLAKjp1YcMbtky9rtXePs0rQLtNrgNGD1PmhnfP0bk1Y6UUzJ(Og5fiiTohgeujZGsek2ii44XdSRXjQPuuZYtAEzsDSrgtukwDAk1itEQLfmdMuW6JMI8UGnHnfP0bk1Y6UUzJ(Og5fiiTohgeujZGsek2ii44XdmWUgNOMsrvCWM1WbE8UgNOMsrqbHPP4X7ACIAkf1wfWR76Mn6JAKxGG06CyqqLmdkrOyJGGV3XU9d9YL9VrdcAF0UGTFET)nAqqLmdk7FSvSO9bi7dfBeCFR0snG9B4(51(0PaL9pMm2(aK9nAFMyCA)a3hPHY(3ObbvYmOSFbx47DZrzR8BdFWWGGM8UGfqEfgqZ51DDZg9rnYlqqADomiOsMbLiuqSu5y6klpPjuqSu51bgBKXeLIvNMsnYKNAzbZGjfepEx3SrFuJvNMsnYKNAzbZGjfmcfelvoMUYYtAcfelvo47DZrzR8BdFWWGGM8UGfqEfgqZ51XgzmrPy1PPuJm5PwwWmysbR76Mn6JAKxGG06CyqqLmdkrOGyPYV11nB0h1iVabP15WGGkzguIJcOrzRa9klpPjuqSu57DSBFGWi35nym2(jji7xWTsz)RgUVPbPZul3xBAFEL4YRug7lmUC8uGYE3Cu2k)2Wh4mgBAokBDYsofGAis4KeK9o2HD7h6KlOWp3h90g9X9XEraanNSpa5QHY(8krhPwUp)0Gd((TUp2JXKR0TFOZQOcOS3nhLTYVn8boJXMMJYwNSKtbOgIeMlbKxHzcoHHjWgiRoWdbqX1vKFAJ(4uqaanNe5K5abuGd8gmhLTg5N2Opob0mkM68ILLNe44Xpeafxxr(Pn6Jtbba0CsekiwQCGwlW37y3(HE5Y(ypgtUs3(HoRIkGY(hpfDFedZtd3F0eFFdk7xufW(nC)8AF6uGY(htgBFaY(8SuZR0zkTpLiY(fkLS9PtzFvalAFS)PPuJSpAQLfmdMuW9U5OSv(THpaXyYv6MqRIkGsa5v4rtrCjtMKLkfP0bk1s84hnftKkrhPwoDgzCc2vNYC0uKshOulXJF0uK3fSjSPiLoqPwU3nhLTYVn8bigtUs3eAvubuciVctgtukwDAk1itEQLfmdMuW6apAkwDAk1itEQLfmdMuWiLoqPwIhVRB2OpQXQttPgzYtTSGzWKcgjyHmHcILkhtbc24XdO586xz5jnHcILkhOUUzJ(OgRonLAKjp1YcMbtkyekiwQCW37MJYw53g(aeJjxPBcTkQakbKxHjJjkf59XjDktUid(Eh72)gHwQ7dg5LSFY3VvwW9T9VrSp6(LwQ7FmPZ9dnQGljdat2)gfKKl7RIb3hXaR95K5aXJ7hAU2)klpP9t((gGUG2N69fDS)O3xBAFKKZ3Nxj6i1Y9PtzFozoq89U5OSv(THpyaTuNS8sciVcdO46kMQGljdatMdbj5sKtMdeMQ9nXJhqX1vmvbxsgaMmhcsYLyrvDanNx)klpPjuqSu5aT27DZrzR8BdFGZySP5OS1jl5uaQHiHDnornL27MJYw53g(aRS1Gb4c6yYKmyPq8WyeqEfgkxqHFAayYE3Cu2k)2WhuOCYaWKPDDXshLTgqEf2CuItMJMIfkNmamzAxxS0rzRHVjE8u6aLAzDOCbf(PbGj7DZrzR8BdFapRoBDYYljaxqhtMKblfIhgJaYRWq5ck8tdat27MJYw53g(axdHfvu2AaUGoMmjdwkepmgbKxHHYfu4NgaMu3CuItMIkiPWbATVbGjJjkf59XjDktUidoE8KXeLI8S6S1jlVeW37MJYw53g(Gb0sDY7cwaPscewurHXyVBokBLFB4d4N2Opob0mAVV3nhLTYJwlHRonLAKjp1YcMbtk4E3Cu2kpATCB4doTcL27MJYw5rRLBdFGZySP5OS1jl5uaQHiHhgeujZGYSckvbKxHb214e1ukItu6miS(OPyIuj6i1YPZiJtWU6uMJMIu6aLAzDx3SrFuJ8ceKwNddcQKzqjcfBeSoWJMIvNMsnYKNAzbZGjfmcfelvoMcepESrgtukwDAk1itEQLfmdMuqWbhpEGDnornLIAwEsZltQpAkY7c2e2uKshOulR76Mn6JAKxGG06CyqqLmdkrOyJG1bE0uS60uQrM8ullygmPGrOGyPYXuG4XJnYyIsXQttPgzYtTSGzWKcco41bgyxJtutPOkoyZA4apExJtutPiOGW0u84DnornLIARc41hnfRonLAKjp1YcMbtkyKshOulRpAkwDAk1itEQLfmdMuWiuqSu5anqW37MJYw5rRLBdFaxKXSVMUgclQOS1aYRWKXeLI8(4KoLjxKbVUZ0jxKXE3Cu2kpATCB4d4ImM9101qyrfLTgqEfgBKXeLI8(4KoLjxKbVo2gnf5ImM9101qyrfLTgP0bk1Y6yl15fllpP6JMIUgclQOS1iuUGc)0aWK9U5OSvE0A52WhyLTgmaxqhtMKblfIhgJaYRWMJsCYC0u0kBniqRDDOCbf(PbGj7DZrzR8O1YTHpWkBnyaUGoMmjdwkepmgbKxHnhL4K5OPOv2AqmfU21HYfu4NgaMuF0u0kBnyKshOul37MJYw5rRLBdFqHYjdatM21flDu2Aa5vyZrjozoAkwOCYaWKPDDXshLTg(M4XtPduQL1HYfu4NgaMS3nhLTYJwl3g(GcLtgaMmTRlw6OS1aCbDmzsgSuiEymciVcJnkDGsTSEfUkYyIsrOHuzknTRlw6OSvEuudatg1nhL4K5OPyHYjdatM21flDu2kqR1E3Cu2kpATCB4dWLmzswQua5vyExWM8tdoWeg7DZrzR8O1YTHpWzm20Cu26KLCka1qKWUgNOMsbWjy6OWyeqEfgBUgNOMsrvCWM1WXE3Cu2kpATCB4dCgJnnhLTozjNcqnej8WGGkzguMvqPkG8kmWUgNOMsrCIsNbH1b21nB0h1yIuj6i1YPZiJtWU6uIqXgbXJF0umrQeDKA50zKXjyxDkZrtrkDGsTe86UUzJ(Og5fiiTohgeujZGsek2iyDGhnfRonLAKjp1YcMbtkyekiwQCmfiE8yJmMOuS60uQrM8ullygmPGGdEDGb214e1ukQId2SgoWJ314e1ukckimnfpExJtutPO2QaEDx3SrFuJ8ceKwNddcQKzqjcfelvoqdSoWJMIvNMsnYKNAzbZGjfmcfelvoMcepESrgtukwDAk1itEQLfmdMuqWbhyxJtutPOMLN08YK6a76Mn6JAK3fSjSPiuSrq84hnf5DbBcBksPduQLGx31nB0h1iVabP15WGGkzguIqbXsLd0aRd8OPy1PPuJm5PwwWmysbJqbXsLJPaXJhBKXeLIvNMsnYKNAzbZGjfeCW37MJYw5rRLBdFWWGGM8UGfqEfgqZ51DDZg9rnYlqqADomiOsMbLiuqSu5y6klpPjuqSu51bgBKXeLIvNMsnYKNAzbZGjfepEx3SrFuJvNMsnYKNAzbZGjfmcfelvoMUYYtAcfelvo47DZrzR8O1YTHpyyqqtExWciVcdO586UUzJ(Og5fiiTohgeujZGsekiwQ8BDDZg9rnYlqqADomiOsMbL4OaAu2kqVYYtAcfelv(E3Cu2kpATCB4dCgJnnhLTozjNcqnejCscYE3Cu2kpATCB4dCgJnnhLTozjNcqnej8qywqzmjyQGeIV3nhLTYJwl3g(aNXytZrzRtwYPaudrcpmeRuMemvqcX37MJYw5rRLBdFGZySP5OS1jl5uaQHiH5KrtcMkiH4bKxHhnfRonLAKjp1YcMbtkyKshOulXJhBKXeLIvNMsnYKNAzbZGjfCVBokBLhTwUn8bigtUs3eAvubuciVcpAkIlzYKSuPiLoqPwU3nhLTYJwl3g(aeJjxPBcTkQakbKxHhnf5DbBcBksPduQL1XgzmrPiVpoPtzYfzW37MJYw5rRLBdFaIXKR0nHwfvaLaYRWyJmMOuexYKjzPs7DZrzR8O1YTHpaXyYv6MqRIkGsa5vyExWM8tdoWuT37MJYw5rRLBdFapRoBDYYljaxqhtMKblfIhgJaYRWMJsCYC0uKNvNToz5La0W1QouUGc)0aWK6yB0uKNvNToz5LeP0bk1Y9U5OSvE0A52Wh4mgBAokBDYsofGAisyxJtutPa4emDuymciVc7ACIAkfvXbBwdh7DZrzR8O1YTHpyaTuNS8sciVcdO46kMQGljdatMdbj5sKtMdeMcd23epEanNxhqX1vmvbxsgaMmhcsYLyrv9RS8KMqbXsLduWgpEafxxXufCjzayYCiijxICYCGWu4Ab21hnf5DbBcBksPduQL7DZrzR8O1YTHpyaTuN8UGfqQKaHfvuym27MJYw5rRLBdFa)0g9XjGMr799U5OSvE014e1ukCIuj6i1YPZiJtWU6uciVcJnYyIsXQttPgzYtTSGzWKcwhyx3SrFuJ8ceKwNddcQKzqjcfelvoqX4M4X76Mn6JAKxGG06CyqqLmdkrOGyPYXeyFZ6UUzJ(Og5fiiTohgeujZGsekiwQCmfiyx316OiPORHWIkk1Yjtei47DZrzR8ORXjQP0THpirQeDKA50zKXjyxDkbKxHjJjkfRonLAKjp1YcMbtky9rtXQttPgzYtTSGzWKcgP0bk1Y9U5OSvE014e1u62WhmexIyuQLtanJciVc76Mn6JAKxGG06CyqqLmdkrOGyPYXeyxh4HaO46kEAfkfHcILkht1gpESrgtukEAfkb(E3Cu2kp6ACIAkDB4d4DbBcBkG8km2iJjkfRonLAKjp1YcMbtkyDGDDZg9rnYlqqADomiOsMbLiuqSu5afSXJ31nB0h1iVabP15WGGkzguIqbXsLJjW(M4X76Mn6JAKxGG06CyqqLmdkrOGyPYXuGGDDxRJIKIUgclQOulNmrGGV3nhLTYJUgNOMs3g(aExWMWMciVctgtukwDAk1itEQLfmdMuW6JMIvNMsnYKNAzbZGjfmsPduQL7DZrzR8ORXjQP0THpG76cyQLtkPtzVV3nhLTYJddXkLjbtfKq8WfCzMKGeGAisyExWMzPMKa37MJYw5XHHyLYKGPcsi(THpOGlZKeKaudrcpGInUsOmXjCUW27MJYw5XHHyLYKGPcsi(THpOGlZKeKaudrcxYcwDo7RPX5jsYmkBDVV3nhLTYJddcQKzqzwbLQW4sMmjlvAVBokBLhhgeujZGYSckv3g(GHbbn5DbBVBokBLhhgeujZGYSckv3g(GQMYw37MJYw5XHbbvYmOmRGs1THp4kHcaw3J9U5OSvECyqqLmdkZkOuDB4daW6EmVkGb37MJYw5XHbbvYmOmRGs1THpaGa5ceuQL7DZrzR84WGGkzguMvqP62Wh4mgBAokBDYsofGAisyxJtutPaYRWyZ14e1ukQId2Sgo27MJYw5XHbbvYmOmRGs1THpGxGG06CyqqLmdk799U5OSvECimlOmMemvqcXdxWLzscsaQHiHfKQGqXyZgoutDsa5vyGDnornLIAwEsZltQ76Mn6JAK3fSjSPiuqSu5anWBcoE8a7ACIAkfXjkDgew31nB0h1yIuj6i1YPZiJtWU6uIqbXsLd0aVj44XdSRXjQPuufhSznCGhVRXjQPueuqyAkE8UgNOMsrTvb89U5OSvECimlOmMemvqcXVn8bfCzMKGeGAisyEHcG19yAicDgKtbKxHb214e1ukQz5jnVmPURB2OpQrExWMWMIqbXsLduWe44XdSRXjQPueNO0zqyDx3SrFuJjsLOJulNoJmob7QtjcfelvoqbtGJhpWUgNOMsrvCWM1WbE8UgNOMsrqbHPP4X7ACIAkf1wfW37MJYw5XHWSGYysWubje)2WhuWLzscsaQHiH5DbJjeLA5ewaiya5vyGDnornLIAwEsZltQ76Mn6JAK3fSjSPiuqSu5afiboE8a7ACIAkfXjkDgew31nB0h1yIuj6i1YPZiJtWU6uIqbXsLduGe44XdSRXjQPuufhSznCGhVRXjQPueuqyAkE8UgNOMsrTvb89(E3Cu2kpoAAwbLQWwzRbdiVcpAkALTgmcfelvoqbs1DDZg9rnYlqqADomiOsMbLiuqSu5yA0u0kBnyekiwQ89U5OSvEC00Sckv3g(aEwD26KLxsa5v4rtrEwD26KLxsekiwQCGcKQ76Mn6JAKxGG06CyqqLmdkrOGyPYX0OPipRoBDYYljcfelv(E3Cu2kpoAAwbLQBdFqHYjdatM21flDu2Aa5v4rtXcLtgaMmTRlw6OS1iuqSu5afiv31nB0h1iVabP15WGGkzguIqbXsLJPrtXcLtgaMmTRlw6OS1iuqSu57DZrzR84OPzfuQUn8bUgclQOS1aYRWJMIUgclQOS1iuqSu5afiv31nB0h1iVabP15WGGkzguIqbXsLJPrtrxdHfvu2AekiwQ89(E3Cu2kpMKGeUGlZKee(EFVBokBLh5s4tRqP9U5OSvEKl3g(Gb0sDY7cwaPscewurZswdWyHXiGujbclQOzEfEiakUUI8tB0hNccaO5KiNmhimfUw7DZrzR8ixUn8b8tB0hNaAgT337MJYw5roz0KGPcsiE4cUmtsqcqnejCQChSGmamzI5kmLkqMdbx6K9U5OSvEKtgnjyQGeIFB4dk4Ymjbja1qKWPYjyHJAiFosCPktacJT3nhLTYJCYOjbtfKq8BdFqbxMjjibOgIeUXjWlwFm1YPPjInDwPS3nhLTYJCYOjbtfKq8BdFqbxMjjibOgIeEyqqiDRZH4anRkiOWDI6K9U5OSvEKtgnjyQGeIFB4dk4Ymjbja1qKWiMZaaLj)ueAIuWt3E3Cu2kpYjJMemvqcXVn8bfCzMKGeGAis4lMHiZ(AcWiIj7DZrzR8iNmAsWubje)2WhuWLzscsaQHiHpAGevG85fS1XE3Cu2kpYjJMemvqcXVn8bfCzMKGeGAisyYaWeA2xZHWRSeU3nhLTYJCYOjbtfKq8BdFqbxMjjibOgIeMN6vbBA8QeAkXNaSrPm7R5LaBxsb37MJYw5roz0KGPcsi(THpOGlZKeKaudrcZt9QGnlz2inQH8jaBukZ(AEjW2LuW9U5OSvEKtgnjyQGeIFB4daW6EmVkGb37MJYw5roz0KGPcsi(THp4kHcaw3J9U5OSvEKtgnjyQGeIFB4daiqUabLA5EFVBokBLhjyQGeAYRyjnDNIduyCgmnamja1qKW8kXLgBkyUISQsgbGZyfsyGbgybZvKvvYikivbHIXMnCOM6Kn0MG5kYQkzetL7GfKbGjtmxHPubYCi4sNa(gAtWCfzvLmI8UGXeIsTCclaee8n0MG5kYQkze5fkaw3JPHi0zqob(E3Cu2kpsWubj0KxXsA6ofhOBdFaodMgaMeGAisycMkiHMTkbGZyfsyGjyQGekIr804Zky7IMgSobtfKqrmINgF66Mn6Jk47DZrzR8ibtfKqtEflPP7uCGUn8b4myAaysaQHiHjyQGeAsh7aWzScjmWemvqcfdmEA8zfSDrtdwNGPcsOyGXtJpDDZg9rf89U5OSvEKGPcsOjVIL00Dkoq3g(aCgmnamja1qKWddXkLjbtfKqbGZyfsyGXgWemvqcfXiEA8zfSDrtdwNGPcsOigXtJpDDZg9rfCWXJhySbmbtfKqXaJNgFwbBx00G1jyQGekgy804tx3SrFubhC84fmxrwvjJyjly15SVMgNNijZOS19U5OSvEKGPcsOjVIL00Dkoq3g(aCgmnamja1qKWemvqcn5vSKcaNXkKWaJZGPbGjrcMkiHMTk1XzW0aWK4WqSszsWubje44XdmodMgaMejyQGeAsh764myAaysCyiwPmjyQGecC84bgNbtdatIemvqcnBv2qB4myAaysKxjU0ytbZvKvvYaC84bgNbtdatIemvqcnPJ9gAdNbtdatI8kXLgBkyUISQsgG7rXjqE2QpKaVzGyCZAFZA7rpAqn1sUhn0cmh6cj0esOFmB)9R5u2prQAiT)vd3hlcMkiHM8kwst3P4aH1(qbZvKqzSpVrK9TcQrmsg77onTu4X9oyKQSFGy2(arR4eijJ9XIGPcsOigXqH1(uVpwemvqcfjmIHcR9boqWc84Ehmsv2Vwy2(arR4eijJ9XIGPcsOyGXqH1(uVpwemvqcfPaJHcR9boqWc84Ehmsv2V2y2(arR4eijJ9XIGPcsOigXqH1(uVpwemvqcfjmIHcR9boqWc84Ehmsv2V2y2(arR4eijJ9XIGPcsOyGXqH1(uVpwemvqcfPaJHcR9boqWc84EFVhAbMdDHeAcj0pMT)(1Ck7NivnK2)QH7JLRXjQPew7dfmxrcLX(8gr23kOgXizSV700sHh37GrQY(yGz7deTItGKm2hlYyIsXqH1(uVpwKXeLIHkkQbGjdS2hymalWJ7DWivzFmWS9bIwXjqsg7JLR1rrsXqH1(uVpwUwhfjfdvuudatgyTpWyawGh37GrQY(bIz7deTItGKm2hlYyIsXqH1(uVpwKXeLIHkkQbGjdS2hymalWJ7DWivz)AHz7deTItGKm2hlYyIsXqH1(uVpwKXeLIHkkQbGjdS2hymalWJ7DWivz)AJz7deTItGKm2hlYyIsXqH1(uVpwKXeLIHkkQbGjdS2hymalWJ7DWivz)AJz7deTItGKm2hlxRJIKIHcR9PEFSCTokskgQOOgaMmWAFGXaSapU3bJuL9bBmBFGOvCcKKX(yrgtukgkS2N69XImMOumurrnamzG1(aJbybECVV3dTaZHUqcnHe6hZ2F)AoL9tKQgs7F1W9XAixwbJWAFOG5ksOm2N3iY(wb1igjJ9DNMwk84Ehmsv2hmHz7deTItGKm2hlYyIsXqH1(uVpwKXeLIHkkQbGjdS23O9XEX8bJ9bgdWc84Ehmsv2hidZ2hiAfNajzSpwemvqcfXigkS2N69XIGPcsOiHrmuyTpWyawGh37GrQY(azy2(arR4eijJ9XIGPcsOyGXqH1(uVpwemvqcfPaJHcR9bgdWc84Ehmsv2hiHz7deTItGKm2hlcMkiHIyedfw7t9(yrWubjuKWigkS2hymalWJ7DWivzFGeMTpq0kobsYyFSiyQGekgymuyTp17JfbtfKqrkWyOWAFGXaSapU3bJuL9bYXS9bIwXjqsg7JfbtfKqrmIHcR9PEFSiyQGeksyedfw7dmgGf4X9oyKQSpqoMTpq0kobsYyFSiyQGekgymuyTp17JfbtfKqrkWyOWAFGXaSapU3bJuL9X4My2(arR4eijJ9XIGPcsOigXqH1(uVpwemvqcfjmIHcR9bgdWc84Ehmsv2hJBIz7deTItGKm2hlcMkiHIbgdfw7t9(yrWubjuKcmgkS2hymalWJ7DWivzFmceZ2hiAfNajzSpwKXeLIHcR9PEFSiJjkfdvuudatgyTpWbcwGh37GrQY(yulmBFGOvCcKKX(yrgtukgkS2N69XImMOumurrnamzG1(aJbybECVdgPk7JbyJz7deTItGKm2hlYyIsXqH1(uVpwKXeLIHkkQbGjdS2hymalWJ7DWivzFmaty2(arR4eijJ9XIGPcsOObWfDDZg9rfR9PEFSCDZg9rnAaCyTpWyawGh37GrQY(yaKHz7deTItGKm2hlcMkiHIgax01nB0hvS2N69XY1nB0h1ObWH1(aJbybECVdgPk7JbqcZ2hiAfNajzSpwemvqcfnaUORB2OpQyTp17JLRB2OpQrdGdR9bgdWc84Ehmsv2pWAHz7deTItGKm2hlYyIsXqH1(uVpwKXeLIHkkQbGjdS2hymalWJ7DWivz)aRnMTpq0kobsYyFSiJjkfdfw7t9(yrgtukgQOOgaMmWAFGXaSapU3bJuL9deihZ2hiAfNajzSpwKXeLIHcR9PEFSiJjkfdvuudatgyTpWbcwGh37GrQY(1cdmBFGOvCcKKX(yrgtukgkS2N69XImMOumurrnamzG1(ahiybECVdgPk7xRaXS9bIwXjqsg7JfzmrPyOWAFQ3hlYyIsXqff1aWKbw7dmgGf4X9oyKQSFTQfMTpq0kobsYyFSiJjkfdfw7t9(yrgtukgQOOgaMmWAFGXaSapU3bJuL9RfqgMTpq0kobsYyFSiJjkfdfw7t9(yrgtukgQOOgaMmWAFGXaSapU3bJuL9RfqcZ2hiAfNajzSpwKXeLIHcR9PEFSiJjkfdvuudatgyTVr7J9I5dg7dmgGf4X9oyKQSFTRnMTpq0kobsYyFSiJjkfdfw7t9(yrgtukgQOOgaMmWAFGdeSapU337HwG5qxiHMqc9Jz7VFnNY(jsvdP9VA4(yzTG1(qbZvKqzSpVrK9TcQrmsg77onTu4X9oyKQSFTWS9bIwXjqsg7JfzmrPyOWAFQ3hlYyIsXqff1aWKbw7dCGGf4X9oyKQSFTXS9bIwXjqsg7JfzmrPyOWAFQ3hlYyIsXqff1aWKbw7dmgGf4X9oyKQSpyJz7deTItGKm2hlYyIsXqH1(uVpwKXeLIHkkQbGjdS2hymalWJ7DWivzFmceZ2hiAfNajzSpwKXeLIHcR9PEFSiJjkfdvuudatgyTpW1cSapU3bJuL9XOwy2(arR4eijJ9XImMOumuyTp17JfzmrPyOIIAayYaR9bgdWc84Ehmsv2hdGeMTpq0kobsYyFSiJjkfdfw7t9(yrgtukgQOOgaMmWAFJ2h7fZhm2hymalWJ7DWivz)aVjMTpq0kobsYyFSiJjkfdfw7t9(yrgtukgQOOgaMmWAFJ2h7fZhm2hymalWJ7DWivz)aXaZ2hiAfNajzSpwKXeLIHcR9PEFSiJjkfdvuudatgyTVr7J9I5dg7dmgGf4X9(Ep0Gu1qsg7JrG7BokBDFwYjECV7rzjN4(A8OddcQKzqzwbLkFn(qWWxJh1Cu2QhfxYKjzPsEurnamz4p0t(qc0xJh1Cu2QhDyqqtExW8OIAayYWFON8HulFnEuZrzRE0QMYw9OIAayYWFON8HuBFnEuZrzRE0RekayDp8OIAayYWFON8Ha2(A8OMJYw9OayDpMxfWGEurnamz4p0t(qat(A8OMJYw9OaeixGGsT0JkQbGjd)HEYhcqMVgpQOgaMm8h6rDWKeyAEuSTVRXjQPuufhSznC4rnhLT6rDgJnnhLTozjN8OSKtt1qepQRXjQPKN8HaK814rnhLT6r5fiiTohgeujZGIhvudatg(d9KN8Oemvqcn5vSKMUtXbYxJpem814rf1aWKH)qpAx5r5c5rnhLT6rXzW0aWepkoJviEuG3h49bEFbZvKvvYikivbHIXMnCOM6epkodovdr8O8kXLgBkyUISQsgEYhsG(A8OIAayYWFOhTR8OCH8OMJYw9O4myAayIhfNXkepkW7tWubjuKWiEA8zfSDrtdUF99jyQGeksyepn(01nB0h19b3JIZGt1qepkbtfKqZwfp5dPw(A8OIAayYWFOhTR8OCH8OMJYw9O4myAayIhfNXkepkW7tWubjuKcmEA8zfSDrtdUF99jyQGeksbgpn(01nB0h19b3JIZGt1qepkbtfKqt6y7jFi12xJhvudatg(d9ODLhLlKh1Cu2QhfNbtdat8O4mwH4rbEFSTpW7tWubjuKWiEA8zfSDrtdUF99jyQGeksyepn(01nB0h19bFFW3hp(9bEFSTpW7tWubjuKcmEA8zfSDrtdUF99jyQGeksbgpn(01nB0h19bFFW3hp(9fmxrwvjJyjly15SVMgNNijZOSvpkodovdr8OddXkLjbtfKqEYhcy7RXJkQbGjd)HE0UYJYfYJAokB1JIZGPbGjEuCgRq8OaVpodMgaMejyQGeA2QSF99XzW0aWK4WqSszsWubj0(GVpE87d8(4myAaysKGPcsOjDS3V((4myAaysCyiwPmjyQGeAFW3hp(9bEFCgmnamjsWubj0SvXJIZGt1qepkbtfKqtEfljp5jp6WqSszsWubje3xJpem814rf1aWKH)qpQAiIhL3fSzwQjjqpQ5OSvpkVlyZSutsGEYhsG(A8OIAayYWFOhvneXJoGInUsOmXjCUW8OMJYw9OdOyJRektCcNlmp5dPw(A8OIAayYWFOhvneXJwYcwDo7RPX5jsYmkB1JAokB1JwYcwDo7RPX5jsYmkB1tEYJoeMfugtcMkiH4(A8HGHVgpQOgaMm8h6rnhLT6rfKQGqXyZgoutDIh1btsGP5rbEFxJtutPOMLN08YK9RVVRB2OpQrExWMWMIqbXsLVpq3pWBUp47Jh)(aVVRXjQPueNO0zq4(1331nB0h1yIuj6i1YPZiJtWU6uIqbXsLVpq3pWBUp47Jh)(aVVRXjQPuufhSznCSpE877ACIAkfbfeMMUpE877ACIAkf1wL9b3JQgI4rfKQGqXyZgoutDIN8HeOVgpQOgaMm8h6rnhLT6r5fkaw3JPHi0zqo5rDWKeyAEuG3314e1ukQz5jnVmz)6776Mn6JAK3fSjSPiuqSu57d09bt7d((4XVpW77ACIAkfXjkDgeUF99DDZg9rnMivIosTC6mY4eSRoLiuqSu57d09bt7d((4XVpW77ACIAkfvXbBwdh7Jh)(UgNOMsrqbHPP7Jh)(UgNOMsrTvzFW9OQHiEuEHcG19yAicDgKtEYhsT814rf1aWKH)qpQ5OSvpkVlymHOulNWcab9OoyscmnpkW77ACIAkf1S8KMxMSF99DDZg9rnY7c2e2uekiwQ89b6(aP9bFF843h49DnornLI4eLodc3V((UUzJ(OgtKkrhPwoDgzCc2vNsekiwQ89b6(aP9bFF843h49DnornLIQ4GnRHJ9XJFFxJtutPiOGW009XJFFxJtutPO2QSp4Eu1qepkVlymHOulNWcab9KN8OUgNOMs(A8HGHVgpQOgaMm8h6rDWKeyAEuSTpzmrPy1PPuJm5PwwWmysbJIAayYy)67d8(UUzJ(Og5fiiTohgeujZGsekiwQ89b6(yCZ9XJFFx3SrFuJ8ceKwNddcQKzqjcfelv((yAFW(M7xFFx3SrFuJ8ceKwNddcQKzqjcfelv((yA)ab79RVVR1rrsrxdHfvuQLtMiWOOgaMm2hCpQ5OSvpAIuj6i1YPZiJtWU6u8KpKa914rf1aWKH)qpQdMKatZJsgtukwDAk1itEQLfmdMuWOOgaMm2V((JMIvNMsnYKNAzbZGjfmsPduQLEuZrzRE0ePs0rQLtNrgNGD1P4jFi1YxJhvudatg(d9OoyscmnpQRB2OpQrEbcsRZHbbvYmOeHcILkFFmTpyVF99bE)HaO46kEAfkfHcILkFFmTFT3hp(9X2(KXeLINwHsrrnamzSp4EuZrzRE0H4seJsTCcOzKN8HuBFnEurnamz4p0J6GjjW08OyBFYyIsXQttPgzYtTSGzWKcgf1aWKX(13h49DDZg9rnYlqqADomiOsMbLiuqSu57d09b79XJFFx3SrFuJ8ceKwNddcQKzqjcfelv((yAFW(M7Jh)(UUzJ(Og5fiiTohgeujZGsekiwQ89X0(bc27xFFxRJIKIUgclQOulNmrGrrnamzSp4EuZrzREuExWMWM8KpeW2xJhvudatg(d9OoyscmnpkzmrPy1PPuJm5PwwWmysbJIAayYy)67pAkwDAk1itEQLfmdMuWiLoqPw6rnhLT6r5DbBcBYt(qat(A8OMJYw9OCxxatTCsjDkEurnamz4p0tEYJoAAwbLkFn(qWWxJhvudatg(d9Ooyscmnp6OPOv2AWiuqSu57d09bs7xFFx3SrFuJ8ceKwNddcQKzqjcfelv((yA)rtrRS1GrOGyPY9OMJYw9OwzRb9KpKa914rf1aWKH)qpQdMKatZJoAkYZQZwNS8sIqbXsLVpq3hiTF99DDZg9rnYlqqADomiOsMbLiuqSu57JP9hnf5z1zRtwEjrOGyPY9OMJYw9O8S6S1jlVep5dPw(A8OIAayYWFOh1btsGP5rhnfluozayY0UUyPJYwJqbXsLVpq3hiTF99DDZg9rnYlqqADomiOsMbLiuqSu57JP9hnfluozayY0UUyPJYwJqbXsL7rnhLT6rluozayY0UUyPJYw9KpKA7RXJkQbGjd)HEuhmjbMMhD0u01qyrfLTgHcILkFFGUpqA)6776Mn6JAKxGG06CyqqLmdkrOGyPY3ht7pAk6AiSOIYwJqbXsL7rnhLT6rDnewurzREYtE0HCzfmYxJpem814rnhLT6r5vcJnzTdKhvudatg(d9KpKa914rnhLT6rhcUUaorSY05rf1aWKH)qp5dPw(A8OIAayYWFOh1btsGP5rnhL4KPOcsk89X0(1YJYjy6iFiy4rnhLT6rDgJnnhLTozjN8OSKtt1qepQ1IN8HuBFnEurnamz4p0JoeUdMvu2Qhfm7OS19zjN47F1W9jyQGeAFaYPHlByCFuYi((gu2NB4KX(xnCFaYvdL9r7c2(HUMoi0Guj6i1Y9bcJmob7Qt5aS)PPuJSpAQLfmdMuWa2VPtbEm5Y(TUVRB2OpQEuZrzREuNXytZrzRtwYjpkNGPJ8HGHh1btsGP5rPer2hO7JHhLLCAQgI4rjyQGeAYRyjnDNIdKN8Ha2(A8OIAayYWFOh1Cu2Qh1zm20Cu26KLCYJYsonvdr8OdHzbLXKGPcsiUN8HaM814rf1aWKH)qpQdMKatZJc8(JMI8UGnHnfP0bk1Y9XJF)rtXePs0rQLtNrgNGD1PmhnfP0bk1Y9XJF)rtXQttPgzYtTSGzWKcgP0bk1Y9bF)67Z7c2KFAWX(yA)ATpE87pAkIlzYKSuPiLoqPwUpE87tgtukY7Jt6uMCrg8OOgaMm8OCcMoYhcgEuZrzREuNXytZrzRtwYjpkl50uneXJYjJMemvqcX9KpeGmFnEurnamz4p0J6GjjW08OUgNOMsrnlpP5Lj7xFFG3hB7JZGPbGjrcMkiHM8kws7Jh)(UUzJ(Og5DbBcBkcfelv((yA)aV5(4XVpW7JZGPbGjrcMkiHMTk7xFFx3SrFuJ8UGnHnfHcILkFFGUpbtfKqrcJORB2OpQrOGyPY3h89XJFFG3hNbtdatIemvqcnPJ9(1331nB0h1iVlytytrOGyPY3hO7tWubjuKcm66Mn6JAekiwQ89bFFW9OCcMoYhcgEuZrzREuNXytZrzRtwYjpkl50uneXJomeRuMemvqcX9KpeGKVgpQOgaMm8h6rDWKeyAEuxJtutPiorPZGW9RVpW7JT9XzW0aWKibtfKqtEflP9XJFFx3SrFuJjsLOJulNoJmob7Qtjcfelv((yA)aV5(4XVpW7JZGPbGjrcMkiHMTk7xFFx3SrFuJjsLOJulNoJmob7Qtjcfelv((aDFcMkiHIegrx3SrFuJqbXsLVp47Jh)(aVpodMgaMejyQGeAsh79RVVRB2OpQXePs0rQLtNrgNGD1PeHcILkFFGUpbtfKqrkWORB2OpQrOGyPY3h89b3JYjy6iFiy4rnhLT6rDgJnnhLTozjN8OSKtt1qep6WqSszsWubje3t(qaY914rf1aWKH)qpQdMKatZJc8(UgNOMsrvCWM1WX(4XVVRXjQPueuqyA6(4XVVRXjQPuuBv2h89RVpW7JT9XzW0aWKibtfKqtEflP9XJFFx3SrFuJvNMsnYKNAzbZGjfmcfelv((yA)aV5(4XVpW7JZGPbGjrcMkiHMTk7xFFx3SrFuJvNMsnYKNAzbZGjfmcfelv((aDFcMkiHIegrx3SrFuJqbXsLVp47Jh)(aVpodMgaMejyQGeAsh79RVVRB2OpQXQttPgzYtTSGzWKcgHcILkFFGUpbtfKqrkWORB2OpQrOGyPY3h89b3JYjy6iFiy4rnhLT6rDgJnnhLTozjN8OSKtt1qep6WqSszsWubje3t(qW4M(A8OIAayYWFOh1btsGP5rX2(KXeLIvNMsnYKNAzbZGjfmkQbGjJ9RVpW7JT9XzW0aWKibtfKqtEflP9XJFFx3SrFuJ8ceKwNddcQKzqjcfelv((yA)aV5(4XVpW7JZGPbGjrcMkiHMTk7xFFx3SrFuJ8ceKwNddcQKzqjcfelv((aDFcMkiHIegrx3SrFuJqbXsLVp47Jh)(aVpodMgaMejyQGeAsh79RVVRB2OpQrEbcsRZHbbvYmOeHcILkFFGUpbtfKqrkWORB2OpQrOGyPY3h89b3JYjy6iFiy4rnhLT6rDgJnnhLTozjN8OSKtt1qep6WqSszsWubje3t(qWadFnEurnamz4p0JAokB1JIym5kDtOvrfqXJoeUdMvu2Qh9WcOUpVly7Zpn4GVFET)vwEs7N89ngsZP9BCc0J6GjjW08OaAoF)67FLLN0ekiwQ89b6(cyjUcsMuIi7J59(8UGn5NgCSF99hnfluozayY0UUyPJYwJu6aLAPN8HGrG(A8OIAayYWFOhDiChmROSvpAO5AFxJtutP9hnDa2)0uQr2hn1YcMbtk4(jFFyHQPwgW(fCz)B0GGkzgu2N69fWIeDSpDk77kGqrP95c5rnhLT6rDgJnnhLTozjN8OoyscmnpkW77ACIAkfXjkDgeUF99hnftKkrhPwoDgzCc2vNYC0uKshOul3V((UUzJ(Og5fiiTohgeujZGsekiwQ89b6(bUF99bE)rtXQttPgzYtTSGzWKcgHcILkFFmTFG7Jh)(yBFYyIsXQttPgzYtTSGzWKcgf1aWKX(GVp47Jh)(aVVRXjQPuuZYtAEzY(13F0uK3fSjSPiLoqPwUF99DDZg9rnYlqqADomiOsMbLiuqSu57d09dC)67d8(JMIvNMsnYKNAzbZGjfmcfelv((yA)a3hp(9X2(KXeLIvNMsnYKNAzbZGjfmkQbGjJ9bFFW3hp(9bEFG3314e1ukQId2Sgo2hp(9DnornLIGcctt3hp(9DnornLIARY(GVF99hnfRonLAKjp1YcMbtkyKshOul3V((JMIvNMsnYKNAzbZGjfmcfelv((aD)a3hCpkl50uneXJomiOsMbLzfuQ8KpemQLVgpQOgaMm8h6rhc3bZkkB1Jg6KlOWp3F0eFFXGSG7Nx7x2PwUFQuVVTp)0GJ95vIosTC)QtJlEuZrzREuNXytZrzRtwYjpQdMKatZJc8(UgNOMsrnlpP5Lj7xFFST)OPiVlytytrkDGsTC)6776Mn6JAK3fSjSPiuqSu57d09R9(GVpE87d8(UgNOMsrCIsNbH7xFFST)OPyIuj6i1YPZiJtWU6uMJMIu6aLA5(1331nB0h1yIuj6i1YPZiJtWU6uIqbXsLVpq3V27d((4XVpW7d8(UgNOMsrvCWM1WX(4XVVRXjQPueuqyA6(4XVVRXjQPuuBv2h89RVpzmrPy1PPuJm5PwwWmysbJIAayYy)67JT9hnfRonLAKjp1YcMbtkyKshOul3V((UUzJ(OgRonLAKjp1YcMbtkyekiwQ89b6(1EFW9OSKtt1qep6OPzfuQ8KpemQTVgpQOgaMm8h6rnhLT6rhge0K3fmp6q4oywrzRE0qZ1(y)ttPgzF0ullygmPG7N89P0bk1Ya2pP9t((C7s2N69l4Y(3ObbTpAxW8Ooyscmnp6OPy1PPuJm5PwwWmysbJu6aLAPN8HGby7RXJkQbGjd)HEuhmjbMMhfB7tgtukwDAk1itEQLfmdMuWOOgaMm2V((aV)OPiVlytytrkDGsTCF843F0umrQeDKA50zKXjyxDkZrtrkDGsTCFW9OMJYw9OddcAY7cMN8HGbyYxJhvudatg(d9OMJYw9OvNMsnYKNAzbZGjf0JoeUdMvu2QhfnO62h7FAk1i7JMAzbZGjfC)JjDUFOhrPZGWdcjlpP9d9zY(UgNOMs7pAkG9B6uGhtUSFbx2V19DDZg9rnUFO5AFSxKQGqXy7J5dhQPozFafxx7N89t11iPwgW(NnBSFHsjB)KWIVpuSrW9bgdG0(CX16GVVDrcC)cUaUh1btsGP5rDnornLIAwEsZlt2V((uIi7JP9b79RVVRB2OpQrExWMWMIqbXsLVpq3hJ9RVpW776Mn6JAuqQccfJnB4qn1jrOGyPY3hO7JbykW9XJFFSTVG5kYQkzefKQGqXyZgoutDY(G7jFiyaK5RXJkQbGjd)HEuhmjbMMh114e1ukItu6miC)67tjISpM2hS3V((UUzJ(OgtKkrhPwoDgzCc2vNsekiwQ89b6(ySF99bEFx3SrFuJcsvqOySzdhQPojcfelv((aDFmatbUpE87JT9fmxrwvjJOGufekgB2WHAQt2hCpQ5OSvpA1PPuJm5PwwWmysb9Kpemas(A8OIAayYWFOh1btsGP5rbEFxJtutPOkoyZA4yF843314e1ukckimnDF843314e1ukQTk7d((13h49DDZg9rnkivbHIXMnCOM6KiuqSu57d09Xamf4(4XVp22xWCfzvLmIcsvqOySzdhQPozFW9OMJYw9OvNMsnYKNAzbZGjf0t(qWai3xJhvudatg(d9OoyscmnpkGMZ3V((xz5jnHcILkFFGUpgGjpQ5OSvpA1PPuJm5PwwWmysb9KpKaVPVgpQOgaMm8h6rhc3bZkkB1JgAU2h7FAk1i7JMAzbZGjfC)KVpLoqPwgW(jHfFFkrK9PE)cUSFtNcCFedZtd3F0e3JAokB1J6mgBAokBDYso5rDWKeyAE0rtXQttPgzYtTSGzWKcgP0bk1Y9RVpW77ACIAkf1S8KMxMSpE877ACIAkfXjkDgeUp4EuwYPPAiIh114e1uYt(qcedFnEurnamz4p0JAokB1JALTg0J6GjjW08OJMIwzRbJqbXsLVpq3V2EuxqhtMKblfI7dbdp5djWa914rnhLT6rpTcL8OIAayYWFON8HeyT814rf1aWKH)qpQ5OSvpkxKXSVMUgclQOSvp6q4oywrzREu0(4(0PSpQid((TUFT2NmyPq89ZR9tA)KRyr77kGqrjwW9tD)lwwEs73W9BDF6u2NmyPqX9dTs6CF0S6S19bJ8s2pjS47BmEVpaHibUp17xWL9rfzSFJtG7JyAHXyb33QQybtTC)ATpq0qyrfLTYJEuhmjbMMh1CuItMIkiPW3ht7h4(13NmMOuK3hN0Pm5Im4rrnamzSF99X2(JMICrgZ(A6AiSOIYwJu6aLA5(13hB7N68ILLNKN8HeyT914rf1aWKH)qpQdMKatZJAokXjtrfKu47JP9dC)67tgtukYZQZwNS8sIIAayYy)67JT9hnf5ImM9101qyrfLTgP0bk1Y9RVp22p15fllpP9RV)OPORHWIkkBncfelv((aD)A7rnhLT6r5ImM9101qyrfLT6jFibc2(A8OIAayYWFOh1btsGP5rbEFExWM8tdo2ht7JX(4XVV5OeNmfvqsHVpM2pW9bF)6776Mn6JAKxGG06CyqqLmdkrOGyPY3ht7JrGEuZrzREuCjtMKLk5jFibcM814rf1aWKH)qpQdMKatZJAokXjZrtXcLtgaMmTRlw6OS19dV)n3hp(9P0bk1Y9RV)OPyHYjdatM21flDu2AekiwQ89b6(12JAokB1JwOCYaWKPDDXshLT6jFibcK5RXJkQbGjd)HEuZrzREuEwD26KLxIh1btsGP5rhnf5z1zRtwEjrOGyPY3hO7xBpQlOJjtYGLcX9HGHN8HeiqYxJhvudatg(d9Ooyscmnpk22314e1ukQId2Sgo8OCcMoYhcgEuZrzREuNXytZrzRtwYjpkl50uneXJ6ACIAk5jFibcK7RXJkQbGjd)HEuZrzREuxdHfvu2Qh1f0XKjzWsH4(qWWJ6GjjW08OMJsCYuubjf((aD)AV)nSpW7tgtukY7Jt6uMCrg8OOgaMm2hp(9jJjkf5z1zRtwEjrrnamzSp47xF)rtrxdHfvu2AekiwQ89b6(b6rhc3bZkkB1JcMRQyb3hiAiSOIYw3hX0cJXcUFR7JXne4(KblfIhW(nC)w3Vw7FmPZ9bZa4nRGK9bIgclQOSvp5dPw30xJhvudatg(d9OMJYw9OigtUs3eAvubu8OdH7GzfLT6rbZxKa3NoL97krfya7ZReDSVTp)0GJ9pEk6(gTpyVFR7J9ym5kD7h6SkQak7t9(gUoh734eOZQQsT0J6GjjW08O8UGn5NgCSpM2V27xFFkrK9X0(bIHN8Hulm814rf1aWKH)qp6q4oywrzRE0qRtr3xBAFEq1LA5(y)ttPgzF0ullygmPG7t9(HEeLodcpiKS8K2p0NjbSpAbcsR7FJgeujZGY(51(gJT)Oj((gu23QQyPm8OMJYw9OoJXMMJYwNSKtEuhmjbMMhf49DnornLI4eLodc3V((yBFYyIsXQttPgzYtTSGzWKcgf1aWKX(13F0umrQeDKA50zKXjyxDkZrtrkDGsTC)6776Mn6JAKxGG06CyqqLmdkrOyJG7d((4XVpW77ACIAkf1S8KMxMSF99X2(KXeLIvNMsnYKNAzbZGjfmkQbGjJ9RV)OPiVlytytrkDGsTC)6776Mn6JAKxGG06CyqqLmdkrOyJG7d((4XVpW7d8(UgNOMsrvCWM1WX(4XVVRXjQPueuqyA6(4XVVRXjQPuuBv2h89RVVRB2OpQrEbcsRZHbbvYmOeHIncUp4EuwYPPAiIhDyqqLmdkZkOu5jFi1kqFnEurnamz4p0JAokB1JomiOjVlyE0HWDWSIYw9OHE5Y(3ObbTpAxW2pV2)gniOsMbL9p2kw0(aK9HIncUVvAPgW(nC)8AF6uGY(htgBFaY(gTptmoTFG7J0qz)B0GGkzgu2VGlCpQdMKatZJcO589RVVRB2OpQrEbcsRZHbbvYmOeHcILkFFmT)vwEstOGyPY3V((aVp22NmMOuS60uQrM8ullygmPGrrnamzSpE8776Mn6JAS60uQrM8ullygmPGrOGyPY3ht7FLLN0ekiwQ89b3t(qQvT814rf1aWKH)qpQdMKatZJcO589RVp22NmMOuS60uQrM8ullygmPGrrnamzSF99DDZg9rnYlqqADomiOsMbLiuqSu57F7(UUzJ(Og5fiiTohgeujZGsCuankBDFGU)vwEstOGyPY9OMJYw9OddcAY7cMN8HuRA7RXJkQbGjd)HE0HWDWSIYw9OaHrUZBWyS9tsq2VGBLY(xnCFtdsNPwUV20(8kXLxPm2xyC54PafpQ5OSvpQZySP5OS1jl5KhLLCAQgI4rtsq8KpKAb2(A8OIAayYWFOh1btsGP5rzcoHTpM2hSbY2V((aV)qauCDf5N2OpofeaqZjrozoq7d09bE)a3)g23Cu2AKFAJ(4eqZOyQZlwwEs7d((4XV)qauCDf5N2OpofeaqZjrOGyPY3hO7xR9b3JAokB1J6mgBAokBDYso5rzjNMQHiEuU4jFi1cm5RXJkQbGjd)HEuZrzREueJjxPBcTkQakE0HWDWSIYw9OHE5Y(ypgtUs3(HoRIkGY(hpfDFedZtd3F0eFFdk7xufW(nC)8AF6uGY(htgBFaY(8SuZR0zkTpLiY(fkLS9PtzFvalAFS)PPuJSpAQLfmdMuqpQdMKatZJoAkIlzYKSuPiLoqPwUpE87pAkMivIosTC6mY4eSRoL5OPiLoqPwUpE87pAkY7c2e2uKshOul9KpKAbK5RXJkQbGjd)HEuhmjbMMhLmMOuS60uQrM8ullygmPGrrnamzSF99bE)rtXQttPgzYtTSGzWKcgP0bk1Y9XJFFx3SrFuJvNMsnYKNAzbZGjfmsWczcfelv((yA)ab79XJFFanNVF99VYYtAcfelv((aDFx3SrFuJvNMsnYKNAzbZGjfmcfelv((G7rnhLT6rrmMCLUj0QOcO4jFi1ci5RXJkQbGjd)HEuhmjbMMhLmMOuK3hN0Pm5Im4rrnamz4rnhLT6rrmMCLUj0QOcO4jFi1ci3xJhvudatg(d9OMJYw9OdOL6KLxIhDiChmROSvp6ncTu3hmYlz)KVFRSG7B7FJyF09lTu3)ysN7hAubxsgaMS)nkijx2xfdUpIbw7ZjZbIh3p0CT)vwEs7N89naDbTp17l6y)rVV20(ijNVpVs0rQL7tNY(CYCG4EuhmjbMMhfqX1vmvbxsgaMmhcsYLiNmhO9X0(1(M7Jh)(akUUIPk4sYaWK5qqsUelQ2V((aAoF)67FLLN0ekiwQ89b6(12t(qQ9n914rf1aWKH)qpQ5OSvpQZySP5OS1jl5KhLLCAQgI4rDnornL8KpKAJHVgpQOgaMm8h6rnhLT6rTYwd6rDWKeyAEuOCbf(PbGjEuxqhtMKblfI7dbdp5dP2b6RXJkQbGjd)HEuhmjbMMh1CuItMJMIfkNmamzAxxS0rzR7hE)BUpE87tPduQL7xFFOCbf(PbGjEuZrzRE0cLtgaMmTRlw6OSvp5dP21YxJhvudatg(d9OMJYw9O8S6S1jlVepQdMKatZJcLlOWpnamXJ6c6yYKmyPqCFiy4jFi1U2(A8OIAayYWFOh1Cu2Qh11qyrfLT6rDWKeyAEuOCbf(PbGj7xFFZrjozkQGKcFFGUFT3)g2h49jJjkf59XjDktUidEuudatg7Jh)(KXeLI8S6S1jlVKOOgaMm2hCpQlOJjtYGLcX9HGHN8HuBW2xJhnvsGWIkYJIHh1Cu2QhDaTuN8UG5rf1aWKH)qp5dP2GjFnEuZrzREu(Pn6JtanJ8OIAayYWFON8KhTckUgbGr(A8HGHVgpQOgaMm8h6rDWKeyAEukrK9X0(3C)67JT9RekASeNSF99X2(akUUILWePtOm7Rj3CW8kDsSOYJAokB1JEjS5Ors1OSvp5djqFnEuZrzREuEbcsRZlHDwOKa9OIAayYWFON8HulFnEurnamz4p0J6GjjW08OKXeLILWePtOm7Rj3CW8kDsuudatgEuZrzRE0syI0juM91KBoyELoXt(qQTVgpQOgaMm8h6r7kpkxipQ5OSvpkodMgaM4rXzScXJAokXjZrtrxdHfvu26(yA)BUF99nhL4K5OPOv2AW9X0(3C)67BokXjZrtXcLtgaMmTRlw6OS19X0(3C)67d8(yBFYyIsrEwD26KLxsuudatg7Jh)(MJsCYC0uKNvNToz5LSpM2)M7d((13h49hnfRonLAKjp1YcMbtkyKshOul3hp(9X2(KXeLIvNMsnYKNAzbZGjfmkQbGjJ9b3JIZGt1qep6Oj(ek2iON8Ha2(A8OIAayYWFOhvneXJAyEXpnOXNxTsZ(Aw1hfOh1Cu2Qh1W8IFAqJpVALM91SQpkqp5dbm5RXJkQbGjd)HEuZrzREuUiJzFnDnewurzREuhmjbMMhLxjm2KmyPq8ixKXSVMUgclQOS1P1Y(yk8(1YJYsvMUHhfJB6jFiaz(A8OMJYw9ONwHsEurnamz4p0t(qas(A8OMJYw9OfkNmamzAxxS0rzREurnamz4p0tEYJAT4RXhcg(A8OMJYw9OvNMsnYKNAzbZGjf0JkQbGjd)HEYhsG(A8OMJYw9ONwHsEurnamz4p0t(qQLVgpQOgaMm8h6rDWKeyAEuG3314e1ukItu6miC)67pAkMivIosTC6mY4eSRoL5OPiLoqPwUF99DDZg9rnYlqqADomiOsMbLiuSrW9RVpW7pAkwDAk1itEQLfmdMuWiuqSu57JP9dCF843hB7tgtukwDAk1itEQLfmdMuWOOgaMm2h89bFF843h49DnornLIAwEsZlt2V((JMI8UGnHnfP0bk1Y9RVVRB2OpQrEbcsRZHbbvYmOeHIncUF99bE)rtXQttPgzYtTSGzWKcgHcILkFFmTFG7Jh)(yBFYyIsXQttPgzYtTSGzWKcgf1aWKX(GVp47xFFG3h49DnornLIQ4GnRHJ9XJFFxJtutPiOGW009XJFFxJtutPO2QSp47xF)rtXQttPgzYtTSGzWKcgP0bk1Y9RV)OPy1PPuJm5PwwWmysbJqbXsLVpq3pW9b3JAokB1J6mgBAokBDYso5rzjNMQHiE0HbbvYmOmRGsLN8HuBFnEurnamz4p0J6GjjW08OKXeLI8(4KoLjxKbpkQbGjJ9RVVZ0jxKHh1Cu2QhLlYy2xtxdHfvu2QN8Ha2(A8OIAayYWFOh1btsGP5rX2(KXeLI8(4KoLjxKbpkQbGjJ9RVp22F0uKlYy2xtxdHfvu2AKshOul3V((yB)uNxSS8K2V((JMIUgclQOS1iuUGc)0aWepQ5OSvpkxKXSVMUgclQOSvp5dbm5RXJkQbGjd)HEuZrzREuRS1GEuhmjbMMh1CuItMJMIwzRb3hO7x79RVpuUGc)0aWepQlOJjtYGLcX9HGHN8HaK5RXJkQbGjd)HEuZrzREuRS1GEuhmjbMMh1CuItMJMIwzRb3htH3V27xFFOCbf(PbGj7xF)rtrRS1GrkDGsT0J6c6yYKmyPqCFiy4jFiajFnEurnamz4p0J6GjjW08OMJsCYC0uSq5KbGjt76ILokBD)W7FZ9XJFFkDGsTC)67dLlOWpnamXJAokB1JwOCYaWKPDDXshLT6jFia5(A8OIAayYWFOh1Cu2QhTq5KbGjt76ILokB1J6GjjW08OyBFkDGsTC)67xHRImMOueAivMst76ILokBLhf1aWKX(133CuItMJMIfkNmamzAxxS0rzR7d09RLh1f0XKjzWsH4(qWWt(qW4M(A8OIAayYWFOh1btsGP5r5DbBYpn4yFmTpgEuZrzREuCjtMKLk5jFiyGHVgpQOgaMm8h6rDWKeyAEuSTVRXjQPuufhSznC4r5emDKpem8OMJYw9OoJXMMJYwNSKtEuwYPPAiIh114e1uYt(qWiqFnEurnamz4p0J6GjjW08OaVVRXjQPueNO0zq4(13h49DDZg9rnMivIosTC6mY4eSRoLiuSrW9XJF)rtXePs0rQLtNrgNGD1PmhnfP0bk1Y9bF)6776Mn6JAKxGG06CyqqLmdkrOyJG7xFFG3F0uS60uQrM8ullygmPGrOGyPY3ht7h4(4XVp22NmMOuS60uQrM8ullygmPGrrnamzSp47d((13h49bEFxJtutPOkoyZA4yF843314e1ukckimnDF843314e1ukQTk7d((1331nB0h1iVabP15WGGkzguIqbXsLVpq3pW9RVpW7pAkwDAk1itEQLfmdMuWiuqSu57JP9dCF843hB7tgtukwDAk1itEQLfmdMuWOOgaMm2h89bFFG3314e1ukQz5jnVmz)67d8(UUzJ(Og5DbBcBkcfBeCF843F0uK3fSjSPiLoqPwUp47xFFx3SrFuJ8ceKwNddcQKzqjcfelv((aD)a3V((aV)OPy1PPuJm5PwwWmysbJqbXsLVpM2pW9XJFFSTpzmrPy1PPuJm5PwwWmysbJIAayYyFW3hCpQ5OSvpQZySP5OS1jl5KhLLCAQgI4rhgeujZGYSckvEYhcg1YxJhvudatg(d9OoyscmnpkGMZ3V((UUzJ(Og5fiiTohgeujZGsekiwQ89X0(xz5jnHcILkF)67d8(yBFYyIsXQttPgzYtTSGzWKcgf1aWKX(4XVVRB2OpQXQttPgzYtTSGzWKcgHcILkFFmT)vwEstOGyPY3hCpQ5OSvp6WGGM8UG5jFiyuBFnEurnamz4p0J6GjjW08OaAoF)6776Mn6JAKxGG06CyqqLmdkrOGyPY3)29DDZg9rnYlqqADomiOsMbL4OaAu26(aD)RS8KMqbXsL7rnhLT6rhge0K3fmp5dbdW2xJhvudatg(d9OMJYw9OoJXMMJYwNSKtEuwYPPAiIhnjbXt(qWam5RXJkQbGjd)HEuZrzREuNXytZrzRtwYjpkl50uneXJoeMfugtcMkiH4EYhcgaz(A8OIAayYWFOh1Cu2Qh1zm20Cu26KLCYJYsonvdr8OddXkLjbtfKqCp5dbdGKVgpQOgaMm8h6rDWKeyAE0rtXQttPgzYtTSGzWKcgP0bk1Y9XJFFSTpzmrPy1PPuJm5PwwWmysbJIAayYWJAokB1J6mgBAokBDYso5rzjNMQHiEuoz0KGPcsiUN8HGbqUVgpQOgaMm8h6rDWKeyAE0rtrCjtMKLkfP0bk1spQ5OSvpkIXKR0nHwfvafp5djWB6RXJkQbGjd)HEuhmjbMMhD0uK3fSjSPiLoqPwUF99X2(KXeLI8(4KoLjxKbpkQbGjdpQ5OSvpkIXKR0nHwfvafp5djqm814rf1aWKH)qpQdMKatZJIT9jJjkfXLmzswQuuudatgEuZrzREueJjxPBcTkQakEYhsGb6RXJkQbGjd)HEuhmjbMMhL3fSj)0GJ9X0(12JAokB1JIym5kDtOvrfqXt(qcSw(A8OIAayYWFOh1Cu2QhLNvNToz5L4rDWKeyAEuZrjozoAkYZQZwNS8s2hOH3Vw7xFFOCbf(PbGj7xFFST)OPipRoBDYYljsPduQLEuxqhtMKblfI7dbdp5djWA7RXJkQbGjd)HEuhmjbMMh114e1ukQId2Sgo8OCcMoYhcgEuZrzREuNXytZrzRtwYjpkl50uneXJ6ACIAk5jFibc2(A8OIAayYWFOh1btsGP5rbuCDftvWLKbGjZHGKCjYjZbAFmfEFW(M7Jh)(aAoF)67dO46kMQGljdatMdbj5sSOA)67FLLN0ekiwQ89b6(G9(4XVpGIRRyQcUKmamzoeKKlrozoq7JPW7xlWE)67pAkY7c2e2uKshOul9OMJYw9OdOL6KLxIN8HeiyYxJhnvsGWIkYJIHh1Cu2QhDaTuN8UG5rf1aWKH)qp5djqGmFnEuZrzREu(Pn6JtanJ8OIAayYWFON8KhnjbXxJpem814rnhLT6rl4YmjbH7rf1aWKH)qp5jpkx814dbdFnEuZrzRE0tRqjpQOgaMm8h6jFib6RXJkQbGjd)HE0ujbclQOzE5rhcGIRRi)0g9XPGaaAojYjZbctHRLh1Cu2QhDaTuN8UG5rtLeiSOIMLSgGX8Oy4jFi1YxJh1Cu2QhLFAJ(4eqZipQOgaMm8h6jp5r5KrtcMkiH4(A8HGHVgpQOgaMm8h6rvdr8OPYDWcYaWKjMRWuQazoeCPt8OMJYw9OPYDWcYaWKjMRWuQazoeCPt8KpKa914rf1aWKH)qpQAiIhnvoblCud5ZrIlvzcqympQ5OSvpAQCcw4OgYNJexQYeGWyEYhsT814rf1aWKH)qpQAiIhTXjWlwFm1YPPjInDwP4rnhLT6rBCc8I1htTCAAIytNvkEYhsT914rf1aWKH)qpQAiIhDyqqiDRZH4anRkiOWDI6epQ5OSvp6WGGq6wNdXbAwvqqH7e1jEYhcy7RXJkQbGjd)HEu1qepkI5maqzYpfHMif805rnhLT6rrmNbakt(Pi0ePGNop5dbm5RXJkQbGjd)HEu1qep6fZqKzFnbyeXepQ5OSvp6fZqKzFnbyeXep5dbiZxJhvudatg(d9OQHiE0JgirfiFEbBD4rnhLT6rpAGevG85fS1HN8HaK814rf1aWKH)qpQAiIhLmamHM91Ci8klHEuZrzREuYaWeA2xZHWRSe6jFia5(A8OIAayYWFOhvneXJYt9QGnnEvcnL4ta2OuM918sGTlPGEuZrzREuEQxfSPXRsOPeFcWgLYSVMxcSDjf0t(qW4M(A8OIAayYWFOhvneXJYt9QGnlz2inQH8jaBukZ(AEjW2LuqpQ5OSvpkp1Rc2SKzJ0OgYNaSrPm7R5LaBxsb9KpemWWxJh1Cu2QhfaR7X8Qag0JkQbGjd)HEYhcgb6RXJAokB1JELqbaR7Hhvudatg(d9KpemQLVgpQ5OSvpkabYfiOul9OIAayYWFON8KN8OwbD2qpkAIaeEYtEp]] )


end