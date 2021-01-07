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


    spec:RegisterPack( "Affliction", 20210104, [[dyu2wbqiLkEKukSjb6tsPuzukvDkvWReunlsQULsLAxs8lbLHbQ4ycWYaLEgjLMgjfxdujBduP8nqLQXPujCoLkrRtkffZtkv3JeTpsOdkLISqb0dLsr1eLsjUOsLKoPukPALQqZukfLUPukL2jOQFkLskdvPsQLkLsXtvPPsc(QsLe2lu)vsdgXHjwSs6XinzP6YO2Su8zHA0kLtl61cYSHCBq2nv)wXWvIJlLsvlh45KA6uUUq2oj57GIXRujrNxkz9sPKmFv0(v14aWkGVDXym8Wchydaobah1ucaw1a3GdChFTwlm(Ui0qsmJVUaX4BBQPbLulhhFxKwOr6yfWx9ebOm(Uz2IUntyHfN2w0AHoqHPtOiKy54uG0yHPtiAy47AuIS26oEfF7IXy4HfoWgaCcaoQPeqaQfoQbUWx9ctXWdlCdUW3TS3zhVIVDwtX324jTPMgusTC8NSRqaOHg6p2gp5O4rcO1tuJ6pbw4aBa)X)yB8K28nXJzDBM)yB8KD)K2uVZ9NCxye6jTzhAOYFSnEYUFsBQ35(tAlSQjc8K2wjoPL)yB8KD)K2uVZ9NScyjeDtCNrpbnXj9jnd4jTfGK(tUteQ8hBJNS7NOamSe6jTTcIBs6tABKflcWpbnXj9j28eygqONKnpP1e12b4NaLAD6XprEIji2TNK(tSnXEcyGP8hBJNS7NSR6YkIFsBJaTiU9K2utdkPwoU(j7Av76NycIDR8hBJNS7NOamSes)eBEIOAY(twrdmPh)K2IacfJea)K0FcueYYDBciMTNatyZtAlT1uq)KOLYFSnEYUFsB(4D218t0de)K2IacfJea)KDnGxEcvqi9tS5jaUhr5NqhOLitSC8Nyjex(JTXt29tUS9e9aXpHkiuvOwoEfLA7jSBGK1pXMNOnqsTNyZtevt2FcDJPHsp(jOuB6NyBI9eygVTZEYk)eal0nUxW3fW0KigFBJN0MAAqj1YXFYUcbGgAO)yB8KJIhjGwprnQ)eyHdSb8h)JTXtAZ3epM1Tz(JTXt29tAt9o3FYDHrON0MDOHk)X24j7(jTPEN7pPTWQMiWtABL4Kw(JTXt29tAt9o3FYkGLq0nXDg9e0eN0N0mGN0was6p5orOYFSnEYUFIcWWsON02kiUjPpPTrwSia)e0eN0NyZtGzaHEs28KwtuBhGFcuQ1Ph)e5jMGy3Es6pX2e7jGbMYFSnEYUFYUQlRi(jTnc0I42tAtnnOKA546NSRvTRFIji2TYFSnEYUFIcWWsi9tS5jIQj7pzfnWKE8tAlciumsa8ts)jqril3TjGy2EcmHnpPT0wtb9tIwk)X24j7(jT5J3zxZprpq8tAlciumsa8t21aE5jubH0pXMNa4EeLFcDGwImXYXFILqC5p2gpz3p5Y2t0de)eQGqvHA54vuQTNWUbsw)eBEI2aj1EInprunz)j0nMgk94NGsTPFITj2tGz82o7jR8taSq34E5p(hfQLJRllaMoqRIPSHr1(aLUy54QNnkTeIveob3zHTIGsvCWDwJAAkXGeAsaxNMQwOGSjPCjA5pkulhxxwamDGwflCLHPJGGgVUW2FuOwoUUSay6aTkw4kdlgKqtc460u1cfKnjLvpBuAcIDRedsOjbCDAQAHcYMKYf2Lve3)Jc1YX1LfathOvXcxzyQeqkRiwDxGyL9X0val9wQRsqrSsHAPkU2hRqhaiAXYXveobfQLQ4AFSIepElfHtqHAPkU2hRe5AtwrCvAAqj1YXveob3VJji2TIox2gVIYgUWUSI4(5PqTufx7Jv05Y24vu2WkcNdb33hRSSjUnqvD6XribKwRIL0qPhFEUJji2TYYM42av1PhhHeqATkSlRiUF4pkulhxxwamDGwflCLHfP5AAmK6UaXkL2k9MaeDTzCRon1Lbgg8hfQLJRllaMoqRIfUYW0m3RttLoaq0ILJRE2OuVWiu1eqmB6IM5EDAQ0baIwSC8QmSIkvBWD42(OCzH7LaGB7s1gGA(Jc1YX1LfathOvXcxzyBsKB)rHA546YcGPd0QyHRmm9M0hyQRdYupBuUJji2TYMe5wHDzfX9G6fgHQMaIztx0m3RttLoaq0ILJxLHBxTb3HB7JYLfUxcaUTlvBaQ5p(hBJNSRURKPrg3FcRIbTEILq8tSn(jc1gWts9tevsIKvex(Jc1YX1k1lmcvrdn0FuOwoUoCLH1zvteOcjXj9pkulhxhUYWOccvfQLJxrP2u3fiwPmS6AdKutzaQNnkfQLQ4k7muYAfv7FuOwoUoCLHTSjUnqvD6XribKwl1ZgLwcXkQw48hfQLJRdxzyubHQc1YXROuBQ7ceRSlGqXibW1faVOE2OCpDuXU4wrf72wlqW(yLeAH9E6XvQyI2aZYgx7JvSKgk94G0zq9bgVOJGGgV2fqOyKa4cGHK01TdBW99XklBIBduvNECesaP1QayijDTIWEEUJji2TYYM42av1PhhHeqATkSlRiUF4W55E6OIDXTINXBwTr4G9Xk6jcvbJvSKgk94G0zq9bgVOJGGgV2fqOyKa4cGHK01TdBW99XklBIBduvNECesaP1QayijDTIWEEUJji2TYYM42av1PhhHeqATkSlRiUF4W55(90rf7IBfNPGbnG(5jDuXU4wjulqk(5jDuXU4wXhNpeSpwzztCBGQ60JJqciTwflPHspoyFSYYM42av1PhhHeqATkagssx3oSh(Jc1YX1HRmmjE8wQNnk7JvK4XBvamKKUUD18hfQLJRdxzys84TuN2II4QjGy20kdq9Sr5EHAPkUYodLSwXaoeCFFSIepERcGHK01TRMd)rHA546Wvg2Me52FuOwoUoCLHrfeQkulhVIsTPUlqSYUacfJeaxxa8I6zJY9c1svCLDgkzTIWgKoQyxCROIDBRfi4E6mO(aJxsOf27PhxPIjAdmlBCbWsV15zFSscTWEp94kvmrBGzzJR9XkwsdLE8HG77Jvw2e3gOQo94iKasRvXsAO0Jpp3Xee7wzztCBGQ60JJqciTwf2Lve3pC48CVqTufxzNHswRiSb3thvSlUvCMcg0a6NN0rf7IBLqTaP4NN0rf7IBfFC(qW99XklBIBduvNECesaP1Qyjnu6XNN7ycIDRSSjUnqvD6XribKwRc7YkI7hoCEUxOwQIRSZqjRve2G0rf7IBfpJ3SAJWb3tNb1hy8IEIqvWyfal9wNN9Xk6jcvbJvSKgk94db33hRSSjUnqvD6XribKwRIL0qPhFEUJji2TYYM42av1PhhHeqATkSlRiUF4WFuOwoUoCLHPzUxNMkDaGOflhx9SrPqTufxzNHswRiSbnbXUv0dmvBJRAM76c7YkI7b3PpwrZCVonv6aarlwoEXsAO0JdUt61gugVz)rHA546WvgMM5EDAQ0baIwSCC1ZgLc1svCLDgkzTIWg0ee7wrNlBJxrzdxyxwrCp4o9XkAM71PPshaiAXYXlwsdLECWDsV2GY4nlyFScDaGOflhVayijDD7Q5pkulhxhUYWuLiUAs6M6zJY96jcv1BcORyaNNc1svCLDgkzTIWEiiDguFGXl6iiOXRDbekgjaUayijDTIba7FuOwoUoCLHf5AtwrCvAAqj1YXvpBukulvX1(yLixBYkIRstdkPwoUs4CEAjnu6Xb7JvICTjRiUknnOKA54fadjPRBxn)rHA546WvgMox2gVIYgw9SrzFSIox2gVIYgUayijDD7Q5pkulhxhUYW05Y24vu2WQtBrrC1eqmBALbOE2OCVqTufxzNHswRyahcUVpwrNlBJxrzdxamKKUUD1C4pkulhxhUYWOccvfQLJxrP2u3fiwjDuXU4M6zJYDOJk2f3kotbdAa9)OqTCCD4kdJoaq0ILJRE2OuOwQIRSZqjRBxn7EVji2TIEGPABCvZCxxyxwrC)80ee7wrNlBJxrzdxyxwrC)qW(yf6aarlwoEbWqs662H9pkulhxhUYWOdaeTy54QtBrrC1eqmBALbOE2OCVqTufxzNHsw3UA29EtqSBf9at124QM5UUWUSI4(5Pji2TIox2gVIYgUWUSI4(Hdb33hRqhaiAXYXlagssx3oSh(Jc1YX1HRmSLnXTbQQtpocjG0APE2OKoQyxCR4mfmOb0ppPJk2f3kEgVz1gHppPJk2f3kHAbsXppPJk2f3k(48FuOwoUoCLHbjiUjPvGSyraw9SrPEIqv9Ma6kQM)OqTCCD4kdJkiuvOwoEfLAtDxGyLDbekgjaUUa4f1ZgL7PJk2f3kQy32AbcUNodQpW4LeAH9E6XvQyI2aZYgxaS0BDE2hRKqlS3tpUsft0gyw24AFSIL0qPhFiiDguFGXl6iiOXRDbekgjaUayijDD7WgCFFSYYM42av1PhhHeqATkagssxRiSNN7ycIDRSSjUnqvD6XribKwRc7YkI7hoCEUFpDuXU4wXzkyqdOFEshvSlUvc1cKIFEshvSlUv8X5dbPZG6dmErhbbnETlGqXibWfadjPRBh2G77Jvw2e3gOQo94iKasRvbWqs6AfH98ChtqSBLLnXTbQQtpocjG0AvyxwrC)WHZZ90rf7IBfpJ3SAJWb3tNb1hy8IEIqvWyfal9wNN9Xk6jcvbJvSKgk94dbPZG6dmErhbbnETlGqXibWfadjPRBh2G77Jvw2e3gOQo94iKasRvbWqs6AfH98ChtqSBLLnXTbQQtpocjG0AvyxwrC)WH)OqTCCD4kdRlGqv9eHupBusNb1hy8IoccA8AxaHIrcGlagssxRytgVzvadjPR)Jc1YX1HRmmQGqvHA54vuQn1DbIvMgd9hfQLJRdxzyubHQc1YXROuBQ7ceRuZQNnkrSkgPiCb3dUVZRrnnf9M0hyQm0kqOCrBcnu77HD3c1YXl6nPpWuxhKvsV2GY4n7W5zNxJAAk6nPpWuzOvGq5cGHK01TR2d)rHA546WvggKG4MKwbYIfby1ZgLc1svCTpwrvI4QjPBkcN)OqTCCD4kddsqCtsRazXIaS6zJsHAPkU2hRKqlS3tpUsft0gyw24AFmfHZFuOwoUoCLHbjiUjPvGSyraw9SrPqTufx7Jv0teQcgtr48hfQLJRdxzyqcIBsAfilweGvpBuAcIDRSSjUnqvD6XribKwRc7YkI7b3lulvX1(yLLnXTbQQtpocjG0APiCop1teQQ3eqxr1EE2KXBwfWqs662PZG6dmEzztCBGQ60JJqciTwfadjPRp8hfQLJRdxzyqcIBsAfilweGvpBuAcIDROhyQ2gx1m31f2Lve3)Jc1YX1HRmSoqsVIYgw9Sr5AuttjDwvAYkIRDgk1CrBcnKIQboNNRrnnL0zvPjRiU2zOuZLOLGnz8MvbmKKUUD18hfQLJRdxzyubHQc1YXROuBQ7ceRKoQyxC7pkulhxhUYWK4XBPE2OeWnawVjRi(pkulhxhUYWK4XBPoTffXvtaXSPvgG6zJY9c1svCLDgkzTIbCi4Ea3ay9MSI4d)rHA546WvggDaGOflhx9SrjGBaSEtwrCqHAPkUYodLSUD1S79MGy3k6bMQTXvnZDDHDzfX9ZttqSBfDUSnEfLnCHDzfX9d)rHA546WvgwKRnzfXvPPbLulhx9SrjGBaSEtwr8FuOwoUoCLHPZLTXROSHvpBuc4gaR3Kve)hfQLJRdxzy6CzB8kkBy1PTOiUAciMnTYaupBuUxOwQIRSZqjRvmGdb3d4gaR3KveF4pkulhxhUYWOdaeTy54QtBrrC1eqmBALbOE2OCVqTufxzNHsw3UA29EtqSBf9at124QM5UUWUSI4(5Pji2TIox2gVIYgUWUSI4(Hdb3d4gaR3KveF4pkulhxhUYW6aj9QEIq)rHA546WvgMEt6dm11bz)X)OqTCCDrgw5YM42av1PhhHeqAT(Jc1YX1fz4Wvg2Me52FuOwoUUidhUYWOccvfQLJxrP2u3fiwzxaHIrcGRlaEr9Sr5E6OIDXTIk2TTwGG9Xkj0c790JRuXeTbMLnU2hRyjnu6XbPZG6dmErhbbnETlGqXibWfadjPRBh2G77Jvw2e3gOQo94iKasRvbWqs6AfH98ChtqSBLLnXTbQQtpocjG0AvyxwrC)WHZZ90rf7IBfpJ3SAJWb7Jv0teQcgRyjnu6XbPZG6dmErhbbnETlGqXibWfadjPRBh2G77Jvw2e3gOQo94iKasRvbWqs6AfH98ChtqSBLLnXTbQQtpocjG0AvyxwrC)WHZZ97PJk2f3kotbdAa9Zt6OIDXTsOwGu8Zt6OIDXTIpoFiyFSYYM42av1PhhHeqATkwsdLECW(yLLnXTbQQtpocjG0AvamKKUUDyp8hfQLJRlYWHRmmnZ960uPdaeTy54QNnknbXUv0dmvBJRAM76c7YkI7bPIx1m3)Jc1YX1fz4WvgMM5EDAQ0baIwSCC1ZgL7ycIDROhyQ2gx1m31f2Lve3dUtFSIM5EDAQ0baIwSC8IL0qPhhCN0RnOmEZc2hRqhaiAXYXlaUbW6nzfX)rHA546ImC4kdtIhVL60wuexnbeZMwzaQNnkfQLQ4AFSIepER2vtqa3ay9MSI4)OqTCCDrgoCLHjXJ3sDAlkIRMaIztRma1ZgLc1svCTpwrIhVLIkvtqa3ay9MSI4G9Xks84TkwsdLE8FuOwoUUidhUYWICTjRiUknnOKA54QNnkfQLQ4AFSsKRnzfXvPPbLulhxjCopTKgk94GaUbW6nzfX)rHA546ImC4kdlY1MSI4Q00GsQLJRoTffXvtaXSPvgG6zJYDSKgk94GlQwmbXUvac0I4wvAAqj1YX1f2Lve3dkulvX1(yLixBYkIRstdkPwoE7Q9pkulhxxKHdxzyQsexnjDt9SrPEIqv9Ma6kgWFuOwoUUidhUYWOccvfQLJxrP2u3fiwjDuXU4M6AdKutzaQNnk3HoQyxCR4mfmOb0)Jc1YX1fz4WvggvqOQqTC8kk1M6UaXk7ciumsaCDbWlQNnk3thvSlUvuXUT1ceCpDguFGXlj0c790JRuXeTbMLnUayP368SpwjHwyVNECLkMOnWSSX1(yflPHsp(qq6mO(aJx0rqqJx7ciumsaCbWqs662Hn4((yLLnXTbQQtpocjG0AvamKKUwrypp3Xee7wzztCBGQ60JJqciTwf2Lve3pC48C)E6OIDXTIZuWGgq)8KoQyxCReQfif)8KoQyxCR4JZhcsNb1hy8IoccA8AxaHIrcGlagssx3oSb33hRSSjUnqvD6XribKwRcGHK01kc755oMGy3klBIBduvNECesaP1QWUSI4(HdNN7PJk2f3kEgVz1gHdUNodQpW4f9eHQGXkaw6Top7Jv0teQcgRyjnu6XhcsNb1hy8IoccA8AxaHIrcGlagssx3oSb33hRSSjUnqvD6XribKwRcGHK01kc755oMGy3klBIBduvNECesaP1QWUSI4(Hd)rHA546ImC4kdRlGqv9eHupBusNb1hy8IoccA8AxaHIrcGlagssxRytgVzvadjPR)Jc1YX1fz4WvggvqOQqTC8kk1M6UaXktJH(Jc1YX1fz4WvggKG4MKwbYIfby1ZgL9XkQsexnjDRyjnu6X)rHA546ImC4kddsqCtsRazXIaS6zJY(yf9eHQGXkwsdLECWDmbXUv0dmvBJRAM76c7YkI7)rHA546ImC4kddsqCtsRazXIaS6zJYDmbXUvuLiUAs6wHDzfX9)OqTCCDrgoCLHbjiUjPvGSyraw9SrPEIqv9Ma6kQM)OqTCCDrgoCLHPZLTXROSHvN2II4QjGy20kdq9SrPqTufx7Jv05Y24vu2WTRuTbbCdG1BYkIdUtFSIox2gVIYgUyjnu6X)rHA546ImC4kdJkiuvOwoEfLAtDxGyL0rf7IBQRnqsnLbOE2OKoQyxCR4mfmOb0)Jc1YX1fz4WvgwhiPxrzdRE2OCnQPPKoRknzfX1odLAUOnHgsrLWfCopxJAAkPZQstwrCTZqPMlrlbBY4nRcyijDD7W155AuttjDwvAYkIRDgk1CrBcnKIkvlCfSpwrprOkySIL0qPh)hfQLJRlYWHRmSoqsVQNi0FuOwoUUidhUYW0BsFGPUoi7p(hfQLJRl0rf7IBktOf27PhxPIjAdmlBS6zJs6mO(aJx0rqqJx7ciumsaCbWqs662daoNN0zq9bgVOJGGgV2fqOyKa4cGHK01kcxW5pkulhxxOJk2f3cxzyDMMqILECDDqM6zJs6mO(aJx0rqqJx7ciumsaCbWqs6AfHRG778AuttztICRayijDTIQ58ChtqSBLnjYTc7YkI7h(Jc1YX1f6OIDXTWvgMEIqvWyQNnkPZG6dmErhbbnETlGqXibWfadjPRBhUopPZG6dmErhbbnETlGqXibWfadjPRveUGZ5jDguFGXl6iiOXRDbekgjaUayijDTIWcxbPJ3JsRqhaiAXspUIyguyxwrC)pkulhxxOJk2f3cxzyA6ebspUAPTX)X)OqTCCDPlGqXibW1faVOuvI4QjPBQNnkPZG6dmErhbbnETlGqXibWfadjPRBh2)OqTCCDPlGqXibW1faVeUYW6ciuvprO)OqTCCDPlGqXibW1faVeUYWwglh)pkulhxx6ciumsaCDbWlHRmSMeWROz6)rHA546sxaHIrcGRlaEjCLHTIMPxBIaT(Jc1YX1LUacfJeaxxa8s4kdBLbAgek94)OqTCCDPlGqXibW1faVeUYWOccvfQLJxrP2u3fiwjDuXU4M6zJYDOJk2f3kotbdAa9G0zq9bgVOJGGgV2fqOyKa4cGHK01Td7FuOwoUU0fqOyKa46cGxcxzy6iiOXRDbekgja(p(hfQLJRlPXqkJ0Cnngs)h)Jc1YX1fnRCtIC7pkulhxx0C4kdRdK0R6jcPE6gdarlwngnRcszaQNUXaq0IvZgLDEnQPPO3K(atLHwbcLlAtOHuuPA)Jc1YX1fnhUYW0BsFGPUoidFvXaDoogEyHdSWjayvlCWxyeGNESgFBRdTmaJ7pbU)eHA54pbLAtx(J4RezBdaFVjuBo(IsTPXkGV0rf7IByfWWhawb8LDzfXDCG4lfKgdsbFPZG6dmErhbbnETlGqXibWfadjPRFs7pja48KZZNqNb1hy8IoccA8AxaHIrcGlagssx)efFcCbh8vOwoo(MqlS3tpUsft0gyw2ySHHhwSc4l7YkI74aXxkingKc(sNb1hy8IoccA8AxaHIrcGlagssx)efFcC9KGpz)t68AuttztICRayijD9tu8jQ5jNNpzNNycIDRSjrUvyxwrC)jhWxHA544BNPjKyPhxxhKHnm8QfRa(YUSI4ooq8LcsJbPGV0zq9bgVOJGGgV2fqOyKa4cGHK01pP9Naxp588j0zq9bgVOJGGgV2fqOyKa4cGHK01prXNaxW5jNNpHodQpW4fDee041UacfJeaxamKKU(jk(eyHRNe8j0X7rPvOdaeTyPhxrmdkSlRiUJVc1YXXx9eHQGXWggE1GvaFfQLJJVA6ebspUAPTX4l7YkI74aXg2W3o3iridRag(aWkGVc1YXXx9cJqv0qdHVSlRiUJdeBy4HfRa(kulhhF7SQjcuHK4KIVSlRiUJdeBy4vlwb8LDzfXDCG4lfKgdsbFfQLQ4k7muY6NO4tul(Qnqsnm8bGVc1YXXxQGqvHA54vuQn8fLAR6ceJVYWyddVAWkGVSlRiUJdeFPG0yqk4RLq8tu8jQfo4RqTCC8DztCBGQ60JJqciTwyddpCHvaFzxwrChhi(sbPXGuW39pHoQyxCROIDBRf4jbFsFSscTWEp94kvmrBGzzJR9XkwsdLE8tc(e6mO(aJx0rqqJx7ciumsaCbWqs66N0(tG9jbFY(N0hRSSjUnqvD6XribKwRcGHK01prXNa7topFYopXee7wzztCBGQ60JJqciTwf2Lve3FYHNC4jNNpz)tOJk2f3kEgVz1gHFsWN0hRONiufmwXsAO0JFsWNqNb1hy8IoccA8AxaHIrcGlagssx)K2FcSpj4t2)K(yLLnXTbQQtpocjG0AvamKKU(jk(eyFY55t25jMGy3klBIBduvNECesaP1QWUSI4(to8Kdp588j7FY(NqhvSlUvCMcg0a6p588j0rf7IBLqTaP4p588j0rf7IBfFC(jhEsWN0hRSSjUnqvD6XribKwRIL0qPh)KGpPpwzztCBGQ60JJqciTwfadjPRFs7pb2NCaFfQLJJVubHQc1YXROuB4lk1w1figF7ciumsaCDbWlyddpCdRa(YUSI4ooq8LcsJbPGV9Xks84Tkagssx)K2FIAWxHA544RepElSHHhUJvaFzxwrChhi(kulhhFL4XBHVuqAmif8D)teQLQ4k7muY6NO4tc4jhEsWNS)j9Xks84Tkagssx)K2FIAEYb8L2II4QjGy20y4daBy43fyfWxHA5447Me5g(YUSI4ooqSHHFxIvaFzxwrChhi(sbPXGuW39prOwQIRSZqjRFIIpb2Ne8j0rf7IBfvSBBTapj4t2)e6mO(aJxsOf27PhxPIjAdmlBCbWsV1topFsFSscTWEp94kvmrBGzzJR9XkwsdLE8to8KGpz)t6Jvw2e3gOQo94iKasRvXsAO0JFY55t25jMGy3klBIBduvNECesaP1QWUSI4(to8Kdp588j7FIqTufxzNHsw)efFcSpj4t2)e6OIDXTIZuWGgq)jNNpHoQyxCReQfif)jNNpHoQyxCR4JZp5Wtc(K9pPpwzztCBGQ60JJqciTwflPHsp(jNNpzNNycIDRSSjUnqvD6XribKwRc7YkI7p5Wto8KZZNS)jc1svCLDgkz9tu8jW(KGpHoQyxCR4z8MvBe(jbFY(NqNb1hy8IEIqvWyfal9wp588j9Xk6jcvbJvSKgk94NC4jbFY(N0hRSSjUnqvD6XribKwRIL0qPh)KZZNSZtmbXUvw2e3gOQo94iKasRvHDzfX9NC4jhWxHA544lvqOQqTC8kk1g(IsTvDbIX3UacfJeaxxa8c2WWhaCWkGVSlRiUJdeFPG0yqk4RqTufxzNHsw)efFcSpj4tmbXUv0dmvBJRAM76c7YkI7pj4t25j9XkAM71PPshaiAXYXlwsdLE8tc(KDEs61gugVz4RqTCC8vZCVonv6aarlwoo2WWhqayfWx2Lve3XbIVuqAmif8vOwQIRSZqjRFIIpb2Ne8jMGy3k6CzB8kkB4c7YkI7pj4t25j9XkAM71PPshaiAXYXlwsdLE8tc(KDEs61gugVzpj4t6JvOdaeTy54fadjPRFs7prn4RqTCC8vZCVonv6aarlwoo2WWhaSyfWx2Lve3XbIVuqAmif8D)t0teQQ3eq)jk(KaEY55teQLQ4k7muY6NO4tG9jhEsWNqNb1hy8IoccA8AxaHIrcGlagssx)efFsaWIVc1YXXxvjIRMKUHnm8bOwSc4l7YkI74aXxkingKc(kulvX1(yLixBYkIRstdkPwo(tu(e48KZZNyjnu6Xpj4t6JvICTjRiUknnOKA54fadjPRFs7prn4RqTCC8nY1MSI4Q00GsQLJJnm8bOgSc4l7YkI74aXxkingKc(2hROZLTXROSHlagssx)K2FIAWxHA544Rox2gVIYggBy4daUWkGVSlRiUJdeFfQLJJV6CzB8kkBy8LcsJbPGV7FIqTufxzNHsw)efFsap5Wtc(K9pPpwrNlBJxrzdxamKKU(jT)e18Kd4lTffXvtaXSPXWha2WWhaCdRa(YUSI4ooq8LcsJbPGV78e6OIDXTIZuWGgqhFfQLJJVubHQc1YXROuB4lk1w1figFPJk2f3Wgg(aG7yfWx2Lve3XbIVuqAmif8vOwQIRSZqjRFs7prnpz3pz)tmbXUv0dmvBJRAM76c7YkI7p588jMGy3k6CzB8kkB4c7YkI7p5Wtc(K(yf6aarlwoEbWqs66N0(tGfFfQLJJV0baIwSCCSHHpGDbwb8LDzfXDCG4RqTCC8Loaq0ILJJVuqAmif8D)teQLQ4k7muY6N0(tuZt29t2)etqSBf9at124QM5UUWUSI4(topFIji2TIox2gVIYgUWUSI4(to8Kdpj4t2)K(yf6aarlwoEbWqs66N0(tG9jhWxAlkIRMaIztJHpaSHHpGDjwb8LDzfXDCG4lfKgdsbFPJk2f3kotbdAa9NCE(e6OIDXTINXBwTr4NCE(e6OIDXTsOwGu8NCE(e6OIDXTIpoJVc1YXX3LnXTbQQtpocjG0AHnm8WchSc4l7YkI74aXxkingKc(QNiuvVjG(tu8jQbFfQLJJVqcIBsAfilweGXggEydaRa(YUSI4ooq8LcsJbPGV7FcDuXU4wrf72wlWtc(K9pHodQpW4LeAH9E6XvQyI2aZYgxaS0B9KZZN0hRKqlS3tpUsft0gyw24AFSIL0qPh)Kdpj4tOZG6dmErhbbnETlGqXibWfadjPRFs7pb2Ne8j7FsFSYYM42av1PhhHeqATkagssx)efFcSp588j78etqSBLLnXTbQQtpocjG0AvyxwrC)jhEYHNCE(K9pz)tOJk2f3kotbdAa9NCE(e6OIDXTsOwGu8NCE(e6OIDXTIpo)Kdpj4tOZG6dmErhbbnETlGqXibWfadjPRFs7pb2Ne8j7FsFSYYM42av1PhhHeqATkagssx)efFcSp588j78etqSBLLnXTbQQtpocjG0AvyxwrC)jhEYHNCE(K9pHoQyxCR4z8MvBe(jbFY(NqNb1hy8IEIqvWyfal9wp588j9Xk6jcvbJvSKgk94NC4jbFcDguFGXl6iiOXRDbekgjaUayijD9tA)jW(KGpz)t6Jvw2e3gOQo94iKasRvbWqs66NO4tG9jNNpzNNycIDRSSjUnqvD6XribKwRc7YkI7p5WtoGVc1YXXxQGqvHA54vuQn8fLAR6ceJVDbekgjaUUa4fSHHhwyXkGVSlRiUJdeFPG0yqk4lDguFGXl6iiOXRDbekgjaUayijD9tu8jnz8MvbmKKUgFfQLJJVDbeQQNie2WWdRAXkGVSlRiUJdeFfQLJJVubHQc1YXROuB4lk1w1figFtJHWggEyvdwb8LDzfXDCG4lfKgdsbFrSkg9efFcCb3FsWNS)jDEnQPPO3K(atLHwbcLlAtOHEs7pz)tG9j7(jc1YXl6nPpWuxhKvsV2GY4n7jhEY55t68AuttrVj9bMkdTcekxamKKU(jT)e1(Kd4RqTCC8LkiuvOwoEfLAdFrP2QUaX4RMXggEyHlSc4l7YkI74aXxkingKc(kulvX1(yfvjIRMKU9efFcCWxHA544lKG4MKwbYIfbySHHhw4gwb8LDzfXDCG4lfKgdsbFfQLQ4AFSscTWEp94kvmrBGzzJR9XEIIpbo4RqTCC8fsqCtsRazXIam2WWdlChRa(YUSI4ooq8LcsJbPGVc1svCTpwrprOkySNO4tGd(kulhhFHee3K0kqwSiaJnm8WUlWkGVSlRiUJdeFPG0yqk4Rji2TYYM42av1PhhHeqATkSlRiU)KGpz)teQLQ4AFSYYM42av1PhhHeqATEIIpbop588j6jcv1BcO)efFIAFY55tAY4nRcyijD9tA)j0zq9bgVSSjUnqvD6XribKwRcGHK01p5a(kulhhFHee3K0kqwSiaJnm8WUlXkGVSlRiUJdeFPG0yqk4Rji2TIEGPABCvZCxxyxwrChFfQLJJVqcIBsAfilweGXggE1chSc4l7YkI74aXxkingKc(Ug10usNvLMSI4ANHsnx0Mqd9efFIAGZtopFYAuttjDwvAYkIRDgk1CjA5jbFstgVzvadjPRFs7prn4RqTCC8TdK0ROSHXggE1gawb8LDzfXDCG4RqTCC8LkiuvOwoEfLAdFrP2QUaX4lDuXU4g2WWRwyXkGVSlRiUJdeFPG0yqk4lGBaSEtwrm(kulhhFL4XBHnm8QvTyfWx2Lve3XbIVc1YXXxjE8w4lfKgdsbF3)eHAPkUYodLS(jk(KaEYHNe8j7FcGBaSEtwr8toGV0wuexnbeZMgdFayddVAvdwb8LDzfXDCG4lfKgdsbFbCdG1BYkIFsWNiulvXv2zOK1pP9NOMNS7NS)jMGy3k6bMQTXvnZDDHDzfX9NCE(etqSBfDUSnEfLnCHDzfX9NCaFfQLJJV0baIwSCCSHHxTWfwb8LDzfXDCG4lfKgdsbFbCdG1BYkIXxHA544BKRnzfXvPPbLulhhBy4vlCdRa(YUSI4ooq8LcsJbPGVaUbW6nzfX4RqTCC8vNlBJxrzdJnm8QfUJvaFzxwrChhi(kulhhF15Y24vu2W4lfKgdsbF3)eHAPkUYodLS(jk(KaEYHNe8j7FcGBaSEtwr8toGV0wuexnbeZMgdFayddVA3fyfWx2Lve3XbIVc1YXXx6aarlwoo(sbPXGuW39prOwQIRSZqjRFs7prnpz3pz)tmbXUv0dmvBJRAM76c7YkI7p588jMGy3k6CzB8kkB4c7YkI7p5Wto8KGpz)taCdG1BYkIFYb8L2II4QjGy20y4daBy4v7UeRa(kulhhF7aj9QEIq4l7YkI74aXggE1ahSc4RqTCC8vVj9bM66Gm8LDzfXDCGydB47cGPd0QyyfWWhawb8LDzfXDCG4lfKgdsbFTeIFIIpbopj4t25jlSveuQIFsWNSZtwJAAkXGeAsaxNMQwOGSjPCjAbFfQLJJVnmQ2hO0flhhBy4HfRa(kulhhF1rqqJxBy0wKBmaFzxwrChhi2WWRwSc4l7YkI74aXxkingKc(AcIDRedsOjbCDAQAHcYMKYf2Lve3XxHA544BmiHMeW1PPQfkiBskJnm8QbRa(YUSI4ooq8DwWxnB4RqTCC8vLaszfX4RkbfX4RqTufx7JvOdaeTy54prXNaNNe8jc1svCTpwrIhV1tu8jW5jbFIqTufx7JvICTjRiUknnOKA54prXNaNNe8j7FYopXee7wrNlBJxrzdxyxwrC)jNNprOwQIR9Xk6CzB8kkB4NO4tGZto8KGpz)t6Jvw2e3gOQo94iKasRvXsAO0JFY55t25jMGy3klBIBduvNECesaP1QWUSI4(toGVQeq1figF7JPRaw6TWggE4cRa(YUSI4ooq81figFL2k9MaeDTzCRon1LbggGVc1YXXxPTsVjarxBg3QttDzGHbyddpCdRa(YUSI4ooq8LcsJbPGV6fgHQMaIztx0m3RttLoaq0ILJxLHFIIkFIAFsWNSZt42(OCzH7fPTsVjarxBg3QttDzGHb4RqTCC8vZCVonv6aarlwoo2WWd3XkGVc1YXX3njYn8LDzfXDCGydd)UaRa(YUSI4ooq8LcsJbPGV78etqSBLnjYTc7YkI7pj4t0lmcvnbeZMUOzUxNMkDaGOflhVkd)K2FIAFsWNSZt42(OCzH7fPTsVjarxBg3QttDzGHb4RqTCC8vVj9bM66GmSHn8vggRag(aWkGVc1YXX3LnXTbQQtpocjG0AHVSlRiUJdeBy4HfRa(kulhhF3Ki3Wx2Lve3XbInm8QfRa(YUSI4ooq8LcsJbPGV7FcDuXU4wrf72wlWtc(K(yLeAH9E6XvQyI2aZYgx7JvSKgk94Ne8j0zq9bgVOJGGgV2fqOyKa4cGHK01pP9Na7tc(K9pPpwzztCBGQ60JJqciTwfadjPRFIIpb2NCE(KDEIji2TYYM42av1PhhHeqATkSlRiU)Kdp5WtopFY(NqhvSlUv8mEZQnc)KGpPpwrprOkySIL0qPh)KGpHodQpW4fDee041UacfJeaxamKKU(jT)eyFsWNS)j9XklBIBduvNECesaP1QayijD9tu8jW(KZZNSZtmbXUvw2e3gOQo94iKasRvHDzfX9NC4jhEY55t2)K9pHoQyxCR4mfmOb0FY55tOJk2f3kHAbsXFY55tOJk2f3k(48to8KGpPpwzztCBGQ60JJqciTwflPHsp(jbFsFSYYM42av1PhhHeqATkagssx)K2FcSp5a(kulhhFPccvfQLJxrP2WxuQTQlqm(2fqOyKa46cGxWggE1GvaFzxwrChhi(sbPXGuWxtqSBf9at124QM5UUWUSI4(tc(eQ4vnZD8vOwoo(QzUxNMkDaGOflhhBy4HlSc4l7YkI74aXxkingKc(UZtmbXUv0dmvBJRAM76c7YkI7pj4t25j9XkAM71PPshaiAXYXlwsdLE8tc(KDEs61gugVzpj4t6JvOdaeTy54fa3ay9MSIy8vOwoo(QzUxNMkDaGOflhhBy4HByfWx2Lve3XbIVc1YXXxjE8w4lfKgdsbFfQLQ4AFSIepERN0(tuZtc(ea3ay9MSIy8L2II4QjGy20y4daBy4H7yfWx2Lve3XbIVc1YXXxjE8w4lfKgdsbFfQLQ4AFSIepERNOOYNOMNe8jaUbW6nzfXpj4t6JvK4XBvSKgk9y8L2II4QjGy20y4daBy43fyfWx2Lve3XbIVuqAmif8vOwQIR9XkrU2KvexLMgusTC8NO8jW5jNNpXsAO0JFsWNa4gaR3KveJVc1YXX3ixBYkIRstdkPwoo2WWVlXkGVSlRiUJdeFfQLJJVrU2KvexLMgusTCC8LcsJbPGV78elPHsp(jbFYIQftqSBfGaTiUvLMgusTCCDHDzfX9Ne8jc1svCTpwjY1MSI4Q00GsQLJ)K2FIAXxAlkIRMaIztJHpaSHHpa4GvaFzxwrChhi(sbPXGuWx9eHQ6nb0FIIpja8vOwoo(QkrC1K0nSHHpGaWkGVSlRiUJdeFPG0yqk47opHoQyxCR4mfmOb0XxTbsQHHpa8vOwoo(sfeQkulhVIsTHVOuBvxGy8LoQyxCdBy4dawSc4l7YkI74aXxkingKc(U)j0rf7IBfvSBBTapj4t2)e6mO(aJxsOf27PhxPIjAdmlBCbWsV1topFsFSscTWEp94kvmrBGzzJR9XkwsdLE8to8KGpHodQpW4fDee041UacfJeaxamKKU(jT)eyFsWNS)j9XklBIBduvNECesaP1QayijD9tu8jW(KZZNSZtmbXUvw2e3gOQo94iKasRvHDzfX9NC4jhEY55t2)K9pHoQyxCR4mfmOb0FY55tOJk2f3kHAbsXFY55tOJk2f3k(48to8KGpHodQpW4fDee041UacfJeaxamKKU(jT)eyFsWNS)j9XklBIBduvNECesaP1QayijD9tu8jW(KZZNSZtmbXUvw2e3gOQo94iKasRvHDzfX9NC4jhEY55t2)e6OIDXTINXBwTr4Ne8j7FcDguFGXl6jcvbJvaS0B9KZZN0hRONiufmwXsAO0JFYHNe8j0zq9bgVOJGGgV2fqOyKa4cGHK01pP9Na7tc(K9pPpwzztCBGQ60JJqciTwfadjPRFIIpb2NCE(KDEIji2TYYM42av1PhhHeqATkSlRiU)Kdp5a(kulhhFPccvfQLJxrP2WxuQTQlqm(2fqOyKa46cGxWgg(aulwb8LDzfXDCG4lfKgdsbFPZG6dmErhbbnETlGqXibWfadjPRFIIpPjJ3SkGHK014RqTCC8TlGqv9eHWgg(audwb8LDzfXDCG4RqTCC8LkiuvOwoEfLAdFrP2QUaX4BAme2WWhaCHvaFzxwrChhi(sbPXGuW3(yfvjIRMKUvSKgk9y8vOwoo(cjiUjPvGSyragBy4daUHvaFzxwrChhi(sbPXGuW3(yf9eHQGXkwsdLE8tc(KDEIji2TIEGPABCvZCxxyxwrChFfQLJJVqcIBsAfilweGXgg(aG7yfWx2Lve3XbIVuqAmif8DNNycIDROkrC1K0Tc7YkI74RqTCC8fsqCtsRazXIam2WWhWUaRa(YUSI4ooq8LcsJbPGV6jcv1BcO)efFIAWxHA544lKG4MKwbYIfbySHHpGDjwb8LDzfXDCG4RqTCC8vNlBJxrzdJVuqAmif8vOwQIR9Xk6CzB8kkB4N0UYNO2Ne8jaUbW6nzfXpj4t25j9Xk6CzB8kkB4IL0qPhJV0wuexnbeZMgdFayddpSWbRa(YUSI4ooq8LcsJbPGV0rf7IBfNPGbnGo(Qnqsnm8bGVc1YXXxQGqvHA54vuQn8fLAR6ceJV0rf7IByddpSbGvaFzxwrChhi(sbPXGuW31OMMs6SQ0Kvex7muQ5I2eAONOOYNaxW5jNNpznQPPKoRknzfX1odLAUeT8KGpPjJ3SkGHK01pP9Naxp588jRrnnL0zvPjRiU2zOuZfTj0qprrLprTW1tc(K(yf9eHQGXkwsdLEm(kulhhF7aj9kkBySHHhwyXkGVc1YXX3oqsVQNie(YUSI4ooqSHHhw1IvaFfQLJJV6nPpWuxhKHVSlRiUJdeBydF7ciumsaCDbWlyfWWhawb8LDzfXDCG4lfKgdsbFPZG6dmErhbbnETlGqXibWfadjPRFs7pbw8vOwoo(QkrC1K0nSHHhwSc4RqTCC8TlGqv9eHWx2Lve3XbInm8QfRa(kulhhFxglhhFzxwrChhi2WWRgSc4RqTCC8Tjb8kAMo(YUSI4ooqSHHhUWkGVc1YXX3v0m9AteOf(YUSI4ooqSHHhUHvaFfQLJJVRmqZGqPhJVSlRiUJdeBy4H7yfWx2Lve3XbIVuqAmif8DNNqhvSlUvCMcg0a6pj4tOZG6dmErhbbnETlGqXibWfadjPRFs7pbw8vOwoo(sfeQkulhVIsTHVOuBvxGy8LoQyxCdBy43fyfWxHA544RoccA8AxaHIrcGXx2Lve3XbInSHVPXqyfWWhawb8vOwoo(gP5AAmKgFzxwrChhi2Wg(QzScy4daRa(kulhhF3Ki3Wx2Lve3XbInm8WIvaFzxwrChhi(MUXaq0IvZg8TZRrnnf9M0hyQm0kqOCrBcnKIkvl(kulhhF7aj9QEIq4B6gdarlwngnRccFdaBy4vlwb8vOwoo(Q3K(atDDqg(YUSI4ooqSHnSHnSHX]] )


end