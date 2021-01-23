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


    spec:RegisterPack( "Affliction", 20210123, [[dyKswbqiLkEKaytcYNuQu0OuQ6uQGxjfzwKKUfOc7ss)sGAyGkDmb0YafpJKOPrs4AGkABcq5BkvQgNsLsNtaQwNaeAEsrDps0(iHoOaKwOa5HkvsmrLkrxuPsGtQujPwPk0mvQe0nvQuyNGQ(PsLKmubiAPkvs5PQ0ujbFvacSxO(RedgXHjwSs6XinzP6YO2Su6Zc1OvkNw0RfuZgYTbz3u9BfdxjoUsLuTCGNtQPt56cz7KuFhuA8cqqNxkSELkHMVkA)QACGyfW3UymgEyGlmbc3aHrL1a3DveWHBahFTglm(Ui0WsmJVUaX4BaTTfLulhhFxKgOr6yfWx9ebOm(Uz2IoGyWbhN2w0ALoqbRtOiKy54uG0AbRtiAW47AuISD1oEfF7IXy4HbUWeiCdegvwdC3vrahU7o(QxykgEycyWj(UL9o74v8TZAk(gGa8KaABlkPwo(tciqaOHg(pgGa8KJIhjGgpbgvQ6tGbUWe4F8pgGa8KDLnXJzDaX)yacWtGJNeq7DU)K7cJqpzx4qdx)JbiapboEsaT35(t2LS6jc8KDdjoP1)yacWtGJNeq7DU)KvalHPBI7m6jOjoPpPDapzxcK0FYDIq1)yacWtGJNOaSSe(j7gcIBt6t21KflcWpbnXj9j28eyhq4NKTpPXeTBc4NaLAD6XprEIji2TNK(tSnXEcyGT(hdqaEcC8KDbUSI4NSRjqlIBpjG22IsQLJRFsaP6aYNycIDR(hdqaEcC8efGLLW6NyZte1t2FYkAGn94NSlfq4yKa4NK(tGIqwchMaIz7jWg88KD5Ukf0pjAP(hdqaEcC8KDLX7SR5NOhi(j7sbeogja(jbKaE5jubH0pXMNa4EeLFcDGwImXYXFILqC9pgGa8e44jx2EIEG4NqfeQiulhVGsT9e2nqY6NyZt0giP2tS5jI6j7pHUX0WPh)euQn9tSnXEcSJVBApzLFcGf6g3R47cyAteJVbiapjG22IsQLJ)KaceaAOH)Jbiap5O4rcOXtGrLQ(eyGlmb(h)Jbiapzxzt8ywhq8pgGa8e44jb0EN7p5UWi0t2fo0W1)yacWtGJNeq7DU)KDjREIapz3qItA9pgGa8e44jb0EN7pzfWsy6M4oJEcAIt6tAhWt2Laj9NCNiu9pgGa8e44jkallHFYUHG42K(KDnzXIa8tqtCsFInpb2be(jz7tAmr7Ma(jqPwNE8tKNycID7jP)eBtSNagyR)XaeGNahpzxGlRi(j7Ac0I42tcOTTOKA546NeqQoG8jMGy3Q)XaeGNahprbyzjS(j28er9K9NSIgytp(j7sbeogja(jP)eOiKLWHjGy2EcSbppzxURsb9tIwQ)XaeGNahpzxz8o7A(j6bIFYUuaHJrcGFsajGxEcvqi9tS5jaUhr5NqhOLitSC8Nyjex)JbiapboEYLTNOhi(jubHkc1YXlOuBpHDdKS(j28eTbsQ9eBEIOEY(tOBmnC6XpbLAt)eBtSNa747M2tw5NayHUX96F8pkulhxxxamDGwftzlJk9bkDXYXvnBvAjeRiCdTZcBvbLQ5q7Sg12wJbj0KaUmTfTqbzBs5A0YFuOwoUUUay6aTkwtkdwhbbnEzHT)OqTCCDDbW0bAvSMugCmiHMeWLPTOfkiBtkRA2Q0ee7wngKqtc4Y0w0cfKTjLRSlRiU)hfQLJRRlaMoqRI1KYGvlGuwrSQUaXk7JPlaw6nuvTGIyLc1s1CPpwLoaq0ILJRiCdjulvZL(yvjE8gkc3qc1s1CPpwnY1MSI4I02IsQLJRiCdTFhtqSBvDUSnEbLTCLDzfX9ZtHAPAU0hRQZLTXlOSLveUhcTVpwDztCBGk60JJqciTgvlPHtp(8ChtqSB1LnXTbQOtpocjG0AuzxwrC)WFuOwoUUUay6aTkwtkdosZL0yivDbIvk7I6nbi6s74wzAlldSm4pkulhxxxamDGwfRjLbRzUxM2cDaGOflhx1SvPEHrOIjGy20vnZ9Y0wOdaeTy54fzyfvQYq7W76r5Yc3RbgWc4Qmqv8hfQLJRRlaMoqRI1KYG3Ki3(Jc1YX11fathOvXAszW6nPpWwwhKPA2QChtqSB1njYTk7YkI7H0lmcvmbeZMUQzUxM2cDaGOflhVid3SkdTdVRhLllCVgyalGRYavXF8pgGa8KDbbeY0iJ7pHvZGgpXsi(j2g)eHAd4jP(jIAjrYkIR)rHA54AL6fgHkOHg(pkulhx3KYG7S6jcuGK4K(hfQLJRBszWubHkc1YXlOuBQ6ceRugwvTbsQPmqvZwLc1s1CHDgkzTIQ8pkulhx3KYGx2e3gOIo94iKasRHQzRslHyfvjC)Jc1YX1nPmyQGqfHA54fuQnvDbIv2fq4yKa4YcGxunBvUNoQzxCRQMDBRbiuFSAcTWEp94cvmrBGzzJl9XQwsdNECi6mO(aRx1rqqJx6ciCmsaCfWqs66MHj0((y1LnXTbQOtpocjG0AubmKKUwryop3Xee7wDztCBGk60JJqciTgv2Lve3pC48CpDuZU4w1Z4nR0kCO(yv9eHkGXQwsdNECi6mO(aRx1rqqJx6ciCmsaCfWqs66MHj0((y1LnXTbQOtpocjG0AubmKKUwryop3Xee7wDztCBGk60JJqciTgv2Lve3pC48C)E6OMDXTQZuWGgq)8KoQzxCRgUbif)8KoQzxCR6JZhc1hRUSjUnqfD6XribKwJQL0WPhhQpwDztCBGk60JJqciTgvadjPRBgMd)rHA546MugSepEdvZwL9XQs84nQagssx3Sk(Jc1YX1nPmyjE8gQsBqrCXeqmBALbQA2QCVqTunxyNHswRyGhcTVpwvIhVrfWqs66MvXH)OqTCCDtkdEtIC7pkulhx3KYGPccveQLJxqP2u1fiwzxaHJrcGllaEr1Sv5EHAPAUWodLSwrycrh1SlUvvZUT1aeApDguFG1Rj0c790JluXeTbMLnUcyP348SpwnHwyVNECHkMOnWSSXL(yvlPHtp(qO99XQlBIBdurNECesaP1OAjnC6XNN7ycIDRUSjUnqfD6XribKwJk7YkI7hoCEUxOwQMlSZqjRveMq7PJA2f3QotbdAa9Zt6OMDXTA4gGu8Zt6OMDXTQpoFi0((y1LnXTbQOtpocjG0AuTKgo94ZZDmbXUvx2e3gOIo94iKasRrLDzfX9dhop3lulvZf2zOK1kcti6OMDXTQNXBwPv4q7PZG6dSEvprOcySkGLEJZZ(yv9eHkGXQwsdNE8Hq77Jvx2e3gOIo94iKasRr1sA40Jpp3Xee7wDztCBGk60JJqciTgv2Lve3pC4pkulhx3KYG1m3ltBHoaq0ILJRA2QuOwQMlSZqjRveMqMGy3Q6b2ITXfnZDDLDzfX9q70hRQzUxM2cDaGOflhVAjnC6XH2j9slkJ3S)OqTCCDtkdwZCVmTf6aarlwoUQzRsHAPAUWodLSwryczcIDRQZLTXlOSLRSlRiUhAN(yvnZ9Y0wOdaeTy54vlPHtpo0oPxArz8MfQpwLoaq0ILJxbmKKUUzv8hfQLJRBszWQtexmjDt1Sv5E9eHk6nb0vmWZtHAPAUWodLSwryoeIodQpW6vDee04LUachJeaxbmKKUwXaH5pkulhx3KYGJCTjRiUiTTOKA54QMTkfQLQ5sFSAKRnzfXfPTfLulhxjCppTKgo94q9XQrU2KvexK2wusTC8kGHK01nRI)OqTCCDtkdwNlBJxqzlRA2QSpwvNlBJxqzlxbmKKUUzv8hfQLJRBszW6CzB8ckBzvPnOiUyciMnTYavnBvUxOwQMlSZqjRvmWdH23hRQZLTXlOSLRagssx3Sko8hfQLJRBszWubHkc1YXlOuBQ6ceRKoQzxCt1Sv5o0rn7IBvNPGbnG(FuOwoUUjLbthaiAXYXvnBvkulvZf2zOK1nRc4yVji2TQEGTyBCrZCxxzxwrC)80ee7wvNlBJxqzlxzxwrC)qO(yv6aarlwoEfWqs66MH5pkulhx3KYGPdaeTy54QsBqrCXeqmBALbQA2QCVqTunxyNHsw3SkGJ9MGy3Q6b2ITXfnZDDLDzfX9ZttqSBvDUSnEbLTCLDzfX9dhcTVpwLoaq0ILJxbmKKUUzyo8hfQLJRBszWlBIBdurNECesaP14pkulhx3KYGHee3M0cqwSiaRA2QuprOIEtaDfvXFuOwoUUjLbtfeQiulhVGsTPQlqSYUachJeaxwa8IQzRY90rn7IBv1SBBnaH2tNb1hy9AcTWEp94cvmrBGzzJRaw6nop7JvtOf27PhxOIjAdmlBCPpw1sA40JpeIodQpW6vDee04LUachJeaxbmKKUUzycTVpwDztCBGk60JJqciTgvadjPRveMZZDmbXUvx2e3gOIo94iKasRrLDzfX9dhop3VNoQzxCR6mfmOb0ppPJA2f3QHBasXppPJA2f3Q(48Hq0zq9bwVQJGGgV0fq4yKa4kGHK01ndtO99XQlBIBdurNECesaP1OcyijDTIWCEUJji2T6YM42av0PhhHeqAnQSlRiUF4W55E6OMDXTQNXBwPv4q7PZG6dSEvprOcySkGLEJZZ(yv9eHkGXQwsdNE8Hq0zq9bwVQJGGgV0fq4yKa4kGHK01ndtO99XQlBIBdurNECesaP1OcyijDTIWCEUJji2T6YM42av0PhhHeqAnQSlRiUF4WFuOwoUUjLb3fq4IEIqQMTkPZG6dSEvhbbnEPlGWXibWvadjPRvSnJ3ScGHK01)rHA546MugmvqOIqTC8ck1MQUaXktJH(Jc1YX1nPmyQGqfHA54fuQnvDbIvQzvZwLiwnJueo39q778AuBBvVj9b2cdTcekx1Mqd38EyGdHA54v9M0hylRdYQPxArz8MD48SZRrTTv9M0hylm0kqOCfWqs66Mv5H)OqTCCDtkdgsqCBslazXIaSQzRsHAPAU0hRQorCXK0nfH7FuOwoUUjLbdjiUnPfGSyraw1SvPqTunx6JvtOf27PhxOIjAdmlBCPpMIW9pkulhx3KYGHee3M0cqwSiaRA2QuOwQMl9XQ6jcvaJPiC)Jc1YX1nPmyibXTjTaKflcWQMTknbXUvx2e3gOIo94iKasRrLDzfX9q7fQLQ5sFS6YM42av0PhhHeqAnueUNN6jcv0BcOROkppBZ4nRayijDDZ0zq9bwVUSjUnqfD6XribKwJkGHK01h(Jc1YX1nPmyibXTjTaKflcWQMTknbXUv1dSfBJlAM76k7YkI7)rHA546MugChiPxqzlRA2QCnQTTMoRonzfXLodLAUQnHgwrva3ZZ1O22A6S60Kvex6muQ5A0sO2mEZkagssx3Sk(Jc1YX1nPmyQGqfHA54fuQnvDbIvsh1SlU9hfQLJRBszWs84nunBvc4waR3Kve)hfQLJRBszWs84nuL2GI4IjGy20kdu1Sv5EHAPAUWodLSwXapeApGBbSEtwr8H)OqTCCDtkdMoaq0ILJRA2QeWTawVjRioKqTunxyNHsw3SkGJ9MGy3Q6b2ITXfnZDDLDzfX9ZttqSBvDUSnEbLTCLDzfX9d)rHA546MugCKRnzfXfPTfLulhx1SvjGBbSEtwr8FuOwoUUjLbRZLTXlOSLvnBvc4waR3Kve)hfQLJRBszW6CzB8ckBzvPnOiUyciMnTYavnBvUxOwQMlSZqjRvmWdH2d4waR3KveF4pkulhx3KYGPdaeTy54QsBqrCXeqmBALbQA2QCVqTunxyNHsw3SkGJ9MGy3Q6b2ITXfnZDDLDzfX9ZttqSBvDUSnEbLTCLDzfX9dhcThWTawVjRi(WFuOwoUUjLb3bs6f9eH(Jc1YX1nPmy9M0hylRdY(J)rHA546QmSYLnXTbQOtpocjG0A8hfQLJRRYWnPm4njYT)OqTCCDvgUjLbtfeQiulhVGsTPQlqSYUachJeaxwa8IQzRY90rn7IBv1SBBnaH6JvtOf27PhxOIjAdmlBCPpw1sA40JdrNb1hy9QoccA8sxaHJrcGRagssx3mmH23hRUSjUnqfD6XribKwJkGHK01kcZ55oMGy3QlBIBdurNECesaP1OYUSI4(HdNN7PJA2f3QEgVzLwHd1hRQNiubmw1sA40JdrNb1hy9QoccA8sxaHJrcGRagssx3mmH23hRUSjUnqfD6XribKwJkGHK01kcZ55oMGy3QlBIBdurNECesaP1OYUSI4(HdNN73th1SlUvDMcg0a6NN0rn7IB1WnaP4NN0rn7IBvFC(qO(y1LnXTbQOtpocjG0AuTKgo94q9XQlBIBdurNECesaP1OcyijDDZWC4pkulhxxLHBszWAM7LPTqhaiAXYXvnBvAcIDRQhyl2gx0m31v2Lve3drfVOzU)hfQLJRRYWnPmynZ9Y0wOdaeTy54QMTk3Xee7wvpWwSnUOzURRSlRiUhAN(yvnZ9Y0wOdaeTy54vlPHtpo0oPxArz8MfQpwLoaq0ILJxbClG1BYkI)Jc1YX1vz4MugSepEdvPnOiUyciMnTYavnBvkulvZL(yvjE8gnRIqaUfW6nzfX)rHA546QmCtkdwIhVHQ0guexmbeZMwzGQMTkfQLQ5sFSQepEdfvQIqaUfW6nzfXH6JvL4XBuTKgo94)OqTCCDvgUjLbh5AtwrCrABrj1YXvnBvkulvZL(y1ixBYkIlsBlkPwoUs4EEAjnC6XHaClG1BYkI)Jc1YX1vz4MugCKRnzfXfPTfLulhxvAdkIlMaIztRmqvZwL7yjnC6XHwuVycIDRceOfXTI02IsQLJRRSlRiUhsOwQMl9XQrU2KvexK2wusTC8Mv5FuOwoUUkd3KYGvNiUys6MQzRs9eHk6nb0vmW)OqTCCDvgUjLbtfeQiulhVGsTPQlqSs6OMDXnv1giPMYavnBvUdDuZU4w1zkyqdO)hfQLJRRYWnPmyQGqfHA54fuQnvDbIv2fq4yKa4YcGxunBvUNoQzxCRQMDBRbi0E6mO(aRxtOf27PhxOIjAdmlBCfWsVX5zFSAcTWEp94cvmrBGzzJl9XQwsdNE8Hq0zq9bwVQJGGgV0fq4yKa4kGHK01ndtO99XQlBIBdurNECesaP1OcyijDTIWCEUJji2T6YM42av0PhhHeqAnQSlRiUF4W55(90rn7IBvNPGbnG(5jDuZU4wnCdqk(5jDuZU4w1hNpeIodQpW6vDee04LUachJeaxbmKKUUzycTVpwDztCBGk60JJqciTgvadjPRveMZZDmbXUvx2e3gOIo94iKasRrLDzfX9dhop3th1SlUv9mEZkTchApDguFG1R6jcvaJvbS0BCE2hRQNiubmw1sA40JpeIodQpW6vDee04LUachJeaxbmKKUUzycTVpwDztCBGk60JJqciTgvadjPRveMZZDmbXUvx2e3gOIo94iKasRrLDzfX9dh(Jc1YX1vz4MugCxaHl6jcPA2QKodQpW6vDee04LUachJeaxbmKKUwX2mEZkagssx)hfQLJRRYWnPmyQGqfHA54fuQnvDbIvMgd9hfQLJRRYWnPmyibXTjTaKflcWQMTk7JvvNiUys6w1sA40J)Jc1YX1vz4MugmKG42KwaYIfbyvZwL9XQ6jcvaJvTKgo94q7ycIDRQhyl2gx0m31v2Lve3)Jc1YX1vz4MugmKG42KwaYIfbyvZwL7ycIDRQorCXK0Tk7YkI7)rHA546QmCtkdgsqCBslazXIaSQzRs9eHk6nb0vuf)rHA546QmCtkdwNlBJxqzlRkTbfXftaXSPvgOQzRsHAPAU0hRQZLTXlOSLBwPkdb4waR3KvehAN(yvDUSnEbLTC1sA40J)Jc1YX1vz4MugmvqOIqTC8ck1MQUaXkPJA2f3uvBGKAkdu1SvjDuZU4w1zkyqdO)hfQLJRRYWnPm4oqsVGYww1Sv5AuBBnDwDAYkIlDgk1CvBcnSIkHt4EEUg12wtNvNMSI4sNHsnxJwc1MXBwbWqs66MHZZZ1O22A6S60Kvex6muQ5Q2eAyfvQs4muFSQEIqfWyvlPHtp(pkulhxxLHBszWDGKErprO)OqTCCDvgUjLbR3K(aBzDq2F8pkulhxxPJA2f3uMqlS3tpUqft0gyw2yvZwL0zq9bwVQJGGgV0fq4yKa4kGHK01nhiCppPZG6dSEvhbbnEPlGWXibWvadjPRveoH7FuOwoUUsh1SlU1KYG7mnHel94Y6GmvZwL0zq9bwVQJGGgV0fq4yKa4kGHK01kcNH2351O226Me5wfWqs6AfvX55oMGy3QBsKBv2Lve3p8hfQLJRR0rn7IBnPmy9eHkGXunBvsNb1hy9QoccA8sxaHJrcGRagssx3mCEEsNb1hy9QoccA8sxaHJrcGRagssxRiCc3Zt6mO(aRx1rqqJx6ciCmsaCfWqs6AfHbodrhVhLwLoaq0ILECbXmOYUSI4(FuOwoUUsh1SlU1KYG10jcKECXsBJ)J)rHA546AxaHJrcGllaErP6eXfts3unBvsNb1hy9QoccA8sxaHJrcGRagssx3mm)rHA546AxaHJrcGllaEPjLb3fq4IEIq)rHA546AxaHJrcGllaEPjLbVmwo(FuOwoUU2fq4yKa4YcGxAszWTjGxrZ0)Jc1YX11UachJeaxwa8stkdEfntV0gbA8hfQLJRRDbeogjaUSa4LMug8kd0miC6X)rHA546AxaHJrcGllaEPjLbtfeQiulhVGsTPQlqSs6OMDXnvZwL7qh1SlUvDMcg0a6HOZG6dSEvhbbnEPlGWXibWvadjPRBgM)OqTCCDTlGWXibWLfaV0KYG1rqqJx6ciCmsa8F8pkulhxxtJHugP5sAmK(p(hfQLJRRAw5Me52FuOwoUUQ5MugChiPx0tes10ngaIwSsmAwfKYavnDJbGOfRKTk78AuBBvVj9b2cdTcekx1MqdROsv(hfQLJRRAUjLbR3K(aBzDqg(QMb6CCm8WaxyceUbcxvGVWkap9yn(URgAzag3FYU)eHA54pbLAtx)J4lk1MgRa(sh1SlUHvadFGyfWx2Lve3XbHVuqAmif8LodQpW6vDee04LUachJeaxbmKKU(jn)KaH7topFcDguFG1R6iiOXlDbeogjaUcyijD9tu8jWjCXxHA544BcTWEp94cvmrBGzzJXggEyWkGVSlRiUJdcFPG0yqk4lDguFG1R6iiOXlDbeogjaUcyijD9tu8jW5tc9K9pPZRrTT1njYTkGHK01prXNOINCE(KDEIji2T6Me5wLDzfX9NCaFfQLJJVDMMqILECzDqg2WWRsSc4l7YkI74GWxkingKc(sNb1hy9QoccA8sxaHJrcGRagssx)KMFcC(KZZNqNb1hy9QoccA8sxaHJrcGRagssx)efFcCc3NCE(e6mO(aRx1rqqJx6ciCmsaCfWqs66NO4tGboFsONqhVhLwLoaq0ILECbXmOYUSI4o(kulhhF1teQagdBy4vbwb8vOwoo(QPtei94IL2gJVSlRiUJdcBydF7CReHmScy4deRa(kulhhF1lmcvqdnm(YUSI4ooiSHHhgSc4RqTCC8TZQNiqbsItk(YUSI4ooiSHHxLyfWx2Lve3XbHVuqAmif8vOwQMlSZqjRFIIprL4R2aj1WWhi(kulhhFPccveQLJxqP2WxuQTIlqm(kdJnm8QaRa(YUSI4ooi8LcsJbPGVwcXprXNOs4IVc1YXX3LnXTbQOtpocjG0AGnm8Wjwb8LDzfXDCq4lfKgdsbF3)e6OMDXTQA2TTgGNe6j9XQj0c790JluXeTbMLnU0hRAjnC6Xpj0tOZG6dSEvhbbnEPlGWXibWvadjPRFsZpbMNe6j7FsFS6YM42av0PhhHeqAnQagssx)efFcmp588j78etqSB1LnXTbQOtpocjG0AuzxwrC)jhEYHNCE(K9pHoQzxCR6z8MvAf(jHEsFSQEIqfWyvlPHtp(jHEcDguFG1R6iiOXlDbeogjaUcyijD9tA(jW8Kqpz)t6Jvx2e3gOIo94iKasRrfWqs66NO4tG5jNNpzNNycIDRUSjUnqfD6XribKwJk7YkI7p5Wto8KZZNS)j7FcDuZU4w1zkyqdO)KZZNqh1SlUvd3aKI)KZZNqh1SlUv9X5NC4jHEsFS6YM42av0PhhHeqAnQwsdNE8tc9K(y1LnXTbQOtpocjG0AubmKKU(jn)eyEYb8vOwoo(sfeQiulhVGsTHVOuBfxGy8TlGWXibWLfaVGnm8bmSc4l7YkI74GWxkingKc(2hRkXJ3OcyijD9tA(jQaFfQLJJVs84nWgg(DhRa(YUSI4ooi8vOwoo(kXJ3aFPG0yqk47(NiulvZf2zOK1prXNe4to8Kqpz)t6JvL4XBubmKKU(jn)ev8Kd4lTbfXftaXSPXWhi2WWVBXkGVc1YXX3njYn8LDzfXDCqyddFahRa(YUSI4ooi8LcsJbPGV7FIqTunxyNHsw)efFcmpj0tOJA2f3QQz32AaEsONS)j0zq9bwVMqlS3tpUqft0gyw24kGLEJNCE(K(y1eAH9E6XfQyI2aZYgx6JvTKgo94NC4jHEY(N0hRUSjUnqfD6XribKwJQL0WPh)KZZNSZtmbXUvx2e3gOIo94iKasRrLDzfX9NC4jhEY55t2)eHAPAUWodLS(jk(eyEsONS)j0rn7IBvNPGbnG(topFcDuZU4wnCdqk(topFcDuZU4w1hNFYHNe6j7FsFS6YM42av0PhhHeqAnQwsdNE8topFYopXee7wDztCBGk60JJqciTgv2Lve3FYHNC4jNNpz)teQLQ5c7muY6NO4tG5jHEcDuZU4w1Z4nR0k8tc9K9pHodQpW6v9eHkGXQaw6nEY55t6Jv1teQagRAjnC6Xp5Wtc9K9pPpwDztCBGk60JJqciTgvlPHtp(jNNpzNNycIDRUSjUnqfD6XribKwJk7YkI7p5WtoGVc1YXXxQGqfHA54fuQn8fLAR4ceJVDbeogjaUSa4fSHHpq4IvaFzxwrChhe(sbPXGuWxHAPAUWodLS(jk(eyEsONycIDRQhyl2gx0m31v2Lve3FsONSZt6Jv1m3ltBHoaq0ILJxTKgo94Ne6j78K0lTOmEZWxHA544RM5EzAl0baIwSCCSHHpWaXkGVSlRiUJdcFPG0yqk4RqTunxyNHsw)efFcmpj0tmbXUv15Y24fu2Yv2Lve3FsONSZt6Jv1m3ltBHoaq0ILJxTKgo94Ne6j78K0lTOmEZEsON0hRshaiAXYXRagssx)KMFIkWxHA544RM5EzAl0baIwSCCSHHpqyWkGVSlRiUJdcFPG0yqk47(NONiurVjG(tu8jb(KZZNiulvZf2zOK1prXNaZto8KqpHodQpW6vDee04LUachJeaxbmKKU(jk(KaHbFfQLJJVQtexmjDdBy4duLyfWx2Lve3XbHVuqAmif8vOwQMl9XQrU2KvexK2wusTC8NO8jW9jNNpXsA40JFsON0hRg5AtwrCrABrj1YXRagssx)KMFIkWxHA544BKRnzfXfPTfLulhhBy4dufyfWx2Lve3XbHVuqAmif8TpwvNlBJxqzlxbmKKU(jn)evGVc1YXXxDUSnEbLTm2WWhiCIvaFzxwrChhe(kulhhF15Y24fu2Y4lfKgdsbF3)eHAPAUWodLS(jk(KaFYHNe6j7FsFSQox2gVGYwUcyijD9tA(jQ4jhWxAdkIlMaIztJHpqSHHpWagwb8LDzfXDCq4lfKgdsbF35j0rn7IBvNPGbnGo(kulhhFPccveQLJxqP2WxuQTIlqm(sh1SlUHnm8bU7yfWx2Lve3XbHVuqAmif8vOwQMlSZqjRFsZprfpboEY(NycIDRQhyl2gx0m31v2Lve3FY55tmbXUv15Y24fu2Yv2Lve3FYHNe6j9XQ0baIwSC8kGHK01pP5Nad(kulhhFPdaeTy54yddFG7wSc4l7YkI74GWxHA544lDaGOflhhFPG0yqk47(NiulvZf2zOK1pP5NOINahpz)tmbXUv1dSfBJlAM76k7YkI7p588jMGy3Q6CzB8ckB5k7YkI7p5Wto8Kqpz)t6JvPdaeTy54vadjPRFsZpbMNCaFPnOiUyciMnng(aXgg(ad4yfWxHA5447YM42av0PhhHeqAnWx2Lve3XbHnm8WaxSc4l7YkI74GWxkingKc(QNiurVjG(tu8jQaFfQLJJVqcIBtAbilweGXggEyceRa(YUSI4ooi8LcsJbPGV7FcDuZU4wvn72wdWtc9K9pHodQpW61eAH9E6XfQyI2aZYgxbS0B8KZZN0hRMqlS3tpUqft0gyw24sFSQL0WPh)Kdpj0tOZG6dSEvhbbnEPlGWXibWvadjPRFsZpbMNe6j7FsFS6YM42av0PhhHeqAnQagssx)efFcmp588j78etqSB1LnXTbQOtpocjG0AuzxwrC)jhEYHNCE(K9pz)tOJA2f3QotbdAa9NCE(e6OMDXTA4gGu8NCE(e6OMDXTQpo)Kdpj0tOZG6dSEvhbbnEPlGWXibWvadjPRFsZpbMNe6j7FsFS6YM42av0PhhHeqAnQagssx)efFcmp588j78etqSB1LnXTbQOtpocjG0AuzxwrC)jhEYHNCE(K9pHoQzxCR6z8MvAf(jHEY(NqNb1hy9QEIqfWyval9gp588j9XQ6jcvaJvTKgo94NC4jHEcDguFG1R6iiOXlDbeogjaUcyijD9tA(jW8Kqpz)t6Jvx2e3gOIo94iKasRrfWqs66NO4tG5jNNpzNNycIDRUSjUnqfD6XribKwJk7YkI7p5WtoGVc1YXXxQGqfHA54fuQn8fLAR4ceJVDbeogjaUSa4fSHHhgyWkGVSlRiUJdcFPG0yqk4lDguFG1R6iiOXlDbeogjaUcyijD9tu8jTz8MvamKKUgFfQLJJVDbeUONie2WWdJkXkGVSlRiUJdcFfQLJJVubHkc1YXlOuB4lk1wXfigFtJHWggEyubwb8LDzfXDCq4lfKgdsbFrSAg9efFcCU7pj0t2)KoVg12w1BsFGTWqRaHYvTj0WpP5NS)jW8e44jc1YXR6nPpWwwhKvtV0IY4n7jhEY55t68AuBBvVj9b2cdTcekxbmKKU(jn)ev(Kd4RqTCC8LkiurOwoEbLAdFrP2kUaX4RMXggEyGtSc4l7YkI74GWxkingKc(kulvZL(yv1jIlMKU9efFcCXxHA544lKG42KwaYIfbySHHhMagwb8LDzfXDCq4lfKgdsbFfQLQ5sFSAcTWEp94cvmrBGzzJl9XEIIpbU4RqTCC8fsqCBslazXIam2WWdZUJvaFzxwrChhe(sbPXGuWxHAPAU0hRQNiubm2tu8jWfFfQLJJVqcIBtAbilweGXggEy2TyfWx2Lve3XbHVuqAmif81ee7wDztCBGk60JJqciTgv2Lve3FsONS)jc1s1CPpwDztCBGk60JJqciTgprXNa3NCE(e9eHk6nb0FIIprLp588jTz8MvamKKU(jn)e6mO(aRxx2e3gOIo94iKasRrfWqs66NCaFfQLJJVqcIBtAbilweGXggEyc4yfWx2Lve3XbHVuqAmif81ee7wvpWwSnUOzURRSlRiUJVc1YXXxibXTjTaKflcWyddVkHlwb8LDzfXDCq4lfKgdsbFxJABRPZQttwrCPZqPMRAtOHFIIprfW9jNNpznQTTMoRonzfXLodLAUgT8KqpPnJ3ScGHK01pP5NOc8vOwoo(2bs6fu2YyddVkdeRa(YUSI4ooi8vOwoo(sfeQiulhVGsTHVOuBfxGy8LoQzxCdBy4vjmyfWx2Lve3XbHVuqAmif8fWTawVjRigFfQLJJVs84nWggEvQsSc4l7YkI74GWxHA544RepEd8LcsJbPGV7FIqTunxyNHsw)efFsGp5Wtc9K9pbWTawVjRi(jhWxAdkIlMaIztJHpqSHHxLQaRa(YUSI4ooi8LcsJbPGVaUfW6nzfXpj0teQLQ5c7muY6N08tuXtGJNS)jMGy3Q6b2ITXfnZDDLDzfX9NCE(etqSBvDUSnEbLTCLDzfX9NCaFfQLJJV0baIwSCCSHHxLWjwb8LDzfXDCq4lfKgdsbFbClG1BYkIXxHA544BKRnzfXfPTfLulhhBy4vzadRa(YUSI4ooi8LcsJbPGVaUfW6nzfX4RqTCC8vNlBJxqzlJnm8QC3XkGVSlRiUJdcFfQLJJV6CzB8ckBz8LcsJbPGV7FIqTunxyNHsw)efFsGp5Wtc9K9pbWTawVjRi(jhWxAdkIlMaIztJHpqSHHxL7wSc4l7YkI74GWxHA544lDaGOflhhFPG0yqk47(NiulvZf2zOK1pP5NOINahpz)tmbXUv1dSfBJlAM76k7YkI7p588jMGy3Q6CzB8ckB5k7YkI7p5Wto8Kqpz)taClG1BYkIFYb8L2GI4IjGy20y4deBy4vzahRa(kulhhF7aj9IEIq4l7YkI74GWggEvaxSc4RqTCC8vVj9b2Y6Gm8LDzfXDCqydB47cGPd0QyyfWWhiwb8LDzfXDCq4lfKgdsbFTeIFIIpbUpj0t25jlSvfuQMFsONSZtwJABRXGeAsaxM2IwOGSnPCnAbFfQLJJVTmQ0hO0flhhBy4HbRa(kulhhF1rqqJxAz0wKBmaFzxwrChhe2WWRsSc4l7YkI74GWxkingKc(AcIDRgdsOjbCzAlAHcY2KYv2Lve3XxHA544BmiHMeWLPTOfkiBtkJnm8QaRa(YUSI4ooi8DwWxnB4RqTCC8vTaszfX4RAbfX4RqTunx6JvPdaeTy54prXNa3Ne6jc1s1CPpwvIhVXtu8jW9jHEIqTunx6JvJCTjRiUiTTOKA54prXNa3Ne6j7FYopXee7wvNlBJxqzlxzxwrC)jNNprOwQMl9XQ6CzB8ckB5NO4tG7to8Kqpz)t6Jvx2e3gOIo94iKasRr1sA40JFY55t25jMGy3QlBIBdurNECesaP1OYUSI4(toGVQfqXfigF7JPlaw6nWggE4eRa(YUSI4ooi81figFLDr9MaeDPDCRmTLLbwgGVc1YXXxzxuVjarxAh3ktBzzGLbyddFadRa(YUSI4ooi8LcsJbPGV6fgHkMaIztx1m3ltBHoaq0ILJxKHFIIkFIkFsONSZt4D9OCzH7vzxuVjarxAh3ktBzzGLb4RqTCC8vZCVmTf6aarlwoo2WWV7yfWxHA5447Me5g(YUSI4ooiSHHF3IvaFzxwrChhe(sbPXGuW3DEIji2T6Me5wLDzfX9Ne6j6fgHkMaIztx1m3ltBHoaq0ILJxKHFsZprLpj0t25j8UEuUSW9QSlQ3eGOlTJBLPTSmWYa8vOwoo(Q3K(aBzDqg2Wg(kdJvadFGyfWxHA5447YM42av0PhhHeqAnWx2Lve3XbHnm8WGvaFfQLJJVBsKB4l7YkI74GWggEvIvaFzxwrChhe(sbPXGuW39pHoQzxCRQMDBRb4jHEsFSAcTWEp94cvmrBGzzJl9XQwsdNE8tc9e6mO(aRx1rqqJx6ciCmsaCfWqs66N08tG5jHEY(N0hRUSjUnqfD6XribKwJkGHK01prXNaZtopFYopXee7wDztCBGk60JJqciTgv2Lve3FYHNC4jNNpz)tOJA2f3QEgVzLwHFsON0hRQNiubmw1sA40JFsONqNb1hy9QoccA8sxaHJrcGRagssx)KMFcmpj0t2)K(y1LnXTbQOtpocjG0AubmKKU(jk(eyEY55t25jMGy3QlBIBdurNECesaP1OYUSI4(to8Kdp588j7FY(Nqh1SlUvDMcg0a6p588j0rn7IB1WnaP4p588j0rn7IBvFC(jhEsON0hRUSjUnqfD6XribKwJQL0WPh)KqpPpwDztCBGk60JJqciTgvadjPRFsZpbMNCaFfQLJJVubHkc1YXlOuB4lk1wXfigF7ciCmsaCzbWlyddVkWkGVSlRiUJdcFPG0yqk4Rji2TQEGTyBCrZCxxzxwrC)jHEcv8IM5o(kulhhF1m3ltBHoaq0ILJJnm8Wjwb8LDzfXDCq4lfKgdsbF35jMGy3Q6b2ITXfnZDDLDzfX9Ne6j78K(yvnZ9Y0wOdaeTy54vlPHtp(jHEYopj9slkJ3SNe6j9XQ0baIwSC8kGBbSEtwrm(kulhhF1m3ltBHoaq0ILJJnm8bmSc4l7YkI74GWxHA544RepEd8LcsJbPGVc1s1CPpwvIhVXtA(jQ4jHEcGBbSEtwrm(sBqrCXeqmBAm8bInm87owb8LDzfXDCq4RqTCC8vIhVb(sbPXGuWxHAPAU0hRkXJ34jkQ8jQ4jHEcGBbSEtwr8tc9K(yvjE8gvlPHtpgFPnOiUyciMnng(aXgg(Dlwb8LDzfXDCq4lfKgdsbFfQLQ5sFSAKRnzfXfPTfLulh)jkFcCFY55tSKgo94Ne6jaUfW6nzfX4RqTCC8nY1MSI4I02IsQLJJnm8bCSc4l7YkI74GWxHA544BKRnzfXfPTfLulhhFPG0yqk47opXsA40JFsONSOEXee7wfiqlIBfPTfLulhxxzxwrC)jHEIqTunx6JvJCTjRiUiTTOKA54pP5NOs8L2GI4IjGy20y4deBy4deUyfWx2Lve3XbHVuqAmif8vprOIEta9NO4tceFfQLJJVQtexmjDdBy4dmqSc4l7YkI74GWxkingKc(UZtOJA2f3QotbdAaD8vBGKAy4deFfQLJJVubHkc1YXlOuB4lk1wXfigFPJA2f3Wgg(aHbRa(YUSI4ooi8LcsJbPGV7FcDuZU4wvn72wdWtc9K9pHodQpW61eAH9E6XfQyI2aZYgxbS0B8KZZN0hRMqlS3tpUqft0gyw24sFSQL0WPh)Kdpj0tOZG6dSEvhbbnEPlGWXibWvadjPRFsZpbMNe6j7FsFS6YM42av0PhhHeqAnQagssx)efFcmp588j78etqSB1LnXTbQOtpocjG0AuzxwrC)jhEYHNCE(K9pz)tOJA2f3QotbdAa9NCE(e6OMDXTA4gGu8NCE(e6OMDXTQpo)Kdpj0tOZG6dSEvhbbnEPlGWXibWvadjPRFsZpbMNe6j7FsFS6YM42av0PhhHeqAnQagssx)efFcmp588j78etqSB1LnXTbQOtpocjG0AuzxwrC)jhEYHNCE(K9pHoQzxCR6z8MvAf(jHEY(NqNb1hy9QEIqfWyval9gp588j9XQ6jcvaJvTKgo94NC4jHEcDguFG1R6iiOXlDbeogjaUcyijD9tA(jW8Kqpz)t6Jvx2e3gOIo94iKasRrfWqs66NO4tG5jNNpzNNycIDRUSjUnqfD6XribKwJk7YkI7p5WtoGVc1YXXxQGqfHA54fuQn8fLAR4ceJVDbeogjaUSa4fSHHpqvIvaFzxwrChhe(sbPXGuWx6mO(aRx1rqqJx6ciCmsaCfWqs66NO4tAZ4nRayijDn(kulhhF7ciCrpriSHHpqvGvaFzxwrChhe(kulhhFPccveQLJxqP2WxuQTIlqm(MgdHnm8bcNyfWx2Lve3XbHVuqAmif8TpwvDI4IjPBvlPHtpgFfQLJJVqcIBtAbilweGXgg(adyyfWx2Lve3XbHVuqAmif8TpwvprOcySQL0WPh)KqpzNNycIDRQhyl2gx0m31v2Lve3XxHA544lKG42KwaYIfbySHHpWDhRa(YUSI4ooi8LcsJbPGV78etqSBv1jIlMKUvzxwrChFfQLJJVqcIBtAbilweGXgg(a3TyfWx2Lve3XbHVuqAmif8vprOIEta9NO4tub(kulhhFHee3M0cqwSiaJnm8bgWXkGVSlRiUJdcFfQLJJV6CzB8ckBz8LcsJbPGVc1s1CPpwvNlBJxqzl)KMv(ev(KqpbWTawVjRi(jHEYopPpwvNlBJxqzlxTKgo9y8L2GI4IjGy20y4deBy4HbUyfWx2Lve3XbHVuqAmif8LoQzxCR6mfmOb0XxTbsQHHpq8vOwoo(sfeQiulhVGsTHVOuBfxGy8LoQzxCdBy4HjqSc4l7YkI74GWxkingKc(Ug12wtNvNMSI4sNHsnx1Mqd)efv(e4eUp588jRrTT10z1PjRiU0zOuZ1OLNe6jTz8MvamKKU(jn)e48jNNpznQTTMoRonzfXLodLAUQnHg(jkQ8jQeoFsON0hRQNiubmw1sA40JXxHA544BhiPxqzlJnm8Wadwb8vOwoo(2bs6f9eHWx2Lve3XbHnm8WOsSc4RqTCC8vVj9b2Y6Gm8LDzfXDCqydB4RMXkGHpqSc4RqTCC8DtICdFzxwrChhe2WWddwb8LDzfXDCq4B6gdarlwjBX3oVg12w1BsFGTWqRaHYvTj0WkQuL4RqTCC8TdK0l6jcHVPBmaeTyLy0Ski8nqSHHxLyfWxHA544REt6dSL1bz4l7YkI74GWg2W30yiScy4deRa(kulhhFJ0CjngsJVSlRiUJdcBydF7ciCmsaCzbWlyfWWhiwb8LDzfXDCq4lfKgdsbFPZG6dSEvhbbnEPlGWXibWvadjPRFsZpbg8vOwoo(QorCXK0nSHHhgSc4RqTCC8TlGWf9eHWx2Lve3XbHnm8QeRa(kulhhFxglhhFzxwrChhe2WWRcSc4RqTCC8Tnb8kAMo(YUSI4ooiSHHhoXkGVc1YXX3v0m9sBeOb(YUSI4ooiSHHpGHvaFfQLJJVRmqZGWPhJVSlRiUJdcBy43DSc4l7YkI74GWxkingKc(UZtOJA2f3QotbdAa9Ne6j0zq9bwVQJGGgV0fq4yKa4kGHK01pP5Nad(kulhhFPccveQLJxqP2WxuQTIlqm(sh1SlUHnm87wSc4RqTCC8vhbbnEPlGWXibW4l7YkI74GWg2Wg(kr22aW3BcTRGnSHXa]] )


end