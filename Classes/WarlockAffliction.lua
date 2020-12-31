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


    spec:RegisterPack( "Affliction", 20201230, [[dy0JwbqiLkEKue2KG8jLkHgLsvNsf5vcQMffXTuQu7sIFjOmmkOoMazzGspJcY0OaUgfiBJcu9nPiPXjfPCoLkrRtPssZtkQ7rH2hfPdkfrwOa1dLIeMifOCrPikoPuKOwPkQzkfrPBkfPQDcQ8tPirgQsLulvksLNQstfu1xvQKWEH6VsAWiDyIfRKEmIjlvxg1MvIpluJwPCArVwaZgYTbz3u9BfdxkDCLkblh45uA6KUUq2of13bfJxPsIoVuy9srunFvy)QACqy4X3UOmgoynmSgoiynKHlbzadeKbAA4R2OLX3wHeqIz81figFBsllOKO544BR0anshdp(ANiaHX3nvBT7QHfwCQBrRfYafMnHIqIMJtaYIgMnHiHHVRrjsBk74v8TlkJHdwddRHdcwdz4sqgWabzado(ABzcgoyn4ge(UL9o74v8TZwc(2epTjTSGsIMJ)0DfcanKa)5M4PgmMWqRm4PgYWM8uynmSg(p)NBIN2uSjEmB3v)ZnXt39tBs9o3F6TLrON2KDibk)5M4P7(PnPEN7p1GXMNiWtB6L4Ku(ZnXt39tBs9o3F6kGLaKnXDg9u0eNKNUmGNAWas6p9orOYFUjE6UFk8WWsGN20liEjjpTPtA1ia)u0eNKNQZtHzabEAU80gt0UiGFkuATPh)u5PQGyxFA6pv3e9PGbMYFUjE6UFAtgxwr8tB6eOwX1N2KwwqjrZXTpDxBEx)uvqSRL)Ct80D)u4HHLa2NQZtfZt2F6kAGj94NAWeqGyKa4NM(tHIqAUBvaXS(uycBEQbRPe82Ng1w(ZnXt39tBkgVZULFQDG4NAWeqGyKa4NURbC7tjcczFQopfW9ic)uYa1gPIMJ)unH4YFUjE6UF6L1NAhi(PebHQcrZXRO0QpLDfKS9P68uRcsI(uDEQyEY(tjBmjq6XpfLw1(uDt0NcZ47I6tx5NcyHSX9c(2cMLeX4Bt80M0YckjAo(t3via0qc8NBINAWycdTYGNAidBYtH1WWA4)8FUjEAtXM4XSDx9p3epD3pTj17C)P3wgHEAt2HeO8NBINU7N2K6DU)udgBEIapTPxIts5p3epD3pTj17C)PRawcq2e3z0trtCsE6YaEQbdiP)07eHk)5M4P7(PWddlbEAtVG4LK80MoPvJa8trtCsEQopfMbe4P5YtBmr7Ia(PqP1ME8tLNQcID9PP)uDt0Ncgyk)5M4P7(PnzCzfXpTPtGAfxFAtAzbLenh3(0DT5D9tvbXUw(ZnXt39tHhgwcyFQopvmpz)PRObM0JFQbtabIrcGFA6pfkcP5UvbeZ6tHjS5PgSMsWBFAuB5p3epD3pTPy8o7w(P2bIFQbtabIrcGF6UgWTpLiiK9P68ua3Ji8tjduBKkAo(t1eIl)5M4P7(PxwFQDG4NseeQkenhVIsR(u2vqY2NQZtTkij6t15PI5j7pLSXKaPh)uuAv7t1nrFkmJVlQpDLFkGfYg3l)5)Sq0CCBPfWKbAvuJlmQ2hO0fnh3KCXOMqSPgo0oTSweuAMdTZA0YsjgKqtc46SuTcbKljHlrT)zHO542slGjd0QOHBmmBee041ww)ZcrZXTLwatgOvrd3yyXGeAsaxNLQviGCjjSj5IrvqSRLyqcnjGRZs1keqUKeUWUSI4(FwiAoUT0cyYaTkA4gdZSaszfXM4ceBSpQTcyP3WeZckInkennZ1(OfYaarTAoUPgoKq00mx7JwK4XByQHdjennZ1(OLi3QYkIRYYckjAoUPgo0(DubXUwSz724vuUWf2Lve3poeIMM5AF0InB3gVIYf2udFk0((OL2nX1bQAtpocjGuBu0Kei94JJDubXUwA3exhOQn94iKasTrHDzfX9t)zHO542slGjd0QOHBmSilxtLHmXfi2O0KB3eGyRlJR1zP2oWWG)Sq0CCBPfWKbAv0WngML5EDwQKbaIA1CCtYfJ2wgHQQaIz1wSm3RZsLmaquRMJxLHn1OHcTdVleLTTCVeKbFxAOGmWFwiAoUT0cyYaTkA4gdBtIC9plenh3wAbmzGwfnCJHz3K(atDDqQj5IXDubXUw2KixlSlRiUhY2YiuvfqmR2IL5EDwQKbaIA1C8QmCZgk0o8Uqu22Y9sqg8DPHcYa)5)Ct80Mm7kzsKY9NYMzqJNQje)uDJFQq0b800(uXSKizfXL)Sq0CCRrBlJqv0qc8NfIMJBd3yyD28ebQqsCs(ZcrZXTHBmmIGqvHO54vuAvtCbInkdBIvbjrngKj5IrHOPzUYodLS1ud9NfIMJBd3yyTBIRdu1MECesaP2WKCXOMqSPgYW)zHO542WnggrqOQq0C8kkTQjUaXg7ciqmsaCTfWTMKlg3tgZSlUwmZUU1aeQpAjHAzVNECLiQyvW0UX1(OfnjbspoezguFGXl2iiOXRDbeigjaUayijDBZWgAFF0s7M46avTPhhHeqQnkagss3AkShh7OcIDT0UjUoqvB6XribKAJc7YkI7NoDCSNmMzxCT4z8MwxeouF0IDIqvWOfnjbspoezguFGXl2iiOXRDbeigjaUayijDBZWgAFF0s7M46avTPhhHeqQnkagss3AkShh7OcIDT0UjUoqvB6XribKAJc7YkI7NoDCSFpzmZU4AXzcyqdOFCqgZSlUwc0aKIFCqgZSlUw8X5tH6JwA3exhOQn94iKasTrrtsG0Jd1hT0UjUoqvB6XribKAJcGHK0Tnd7P)Sq0CCB4gdtIhVHj5IX(OfjE8gfadjPBB2a)zHO542WngMepEdtiniiUQciMvRXGmjxmUxiAAMRSZqjBnnOtH23hTiXJ3OayijDBZg40FwiAoUnCJHTjrU(NfIMJBd3yyebHQcrZXRO0QM4ceBSlGaXibW1wa3AsUyCVq00mxzNHs2AkSHiJz2fxlMzx3AacTNmdQpW4LeQL9E6XvIOIvbt7gxaS0BCC0hTKqTS3tpUsevSkyA34AF0IMKaPhFk0((OL2nX1bQAtpocjGuBu0Kei94JJDubXUwA3exhOQn94iKasTrHDzfX9tNoo2lennZv2zOKTMcBO9KXm7IRfNjGbnG(XbzmZU4Ajqdqk(XbzmZU4AXhNpfAFF0s7M46avTPhhHeqQnkAscKE8XXoQGyxlTBIRdu1MECesaP2OWUSI4(Pthh7fIMM5k7muYwtHnezmZU4AXZ4nTUiCO9Kzq9bgVyNiufmAbWsVXXrF0IDIqvWOfnjbsp(uO99rlTBIRdu1MECesaP2OOjjq6Xhh7OcIDT0UjUoqvB6XribKAJc7YkI7No9NfIMJBd3yywM71zPsgaiQvZXnjxmkennZv2zOKTMcBivqSRf7atv34QL5UTWUSI4EOD6JwSm3RZsLmaquRMJx0Kei94q7KEDbLXB6FwiAoUnCJHzzUxNLkzaGOwnh3KCXOq00mxzNHs2AkSHubXUwSz724vuUWf2Lve3dTtF0IL5EDwQKbaIA1C8IMKaPhhAN0RlOmEtd1hTqgaiQvZXlagss32Sb(ZcrZXTHBmmZjIRQKUAsUyCVDIqv7Ma6Mg0XHq00mxzNHs2AkSNcrMb1hy8InccA8AxabIrcGlagss3AAqW(NfIMJBd3yyrUvLvexLLfus0CCtYfJcrtZCTpAjYTQSI4QSSGsIMJB0WhhAscKECO(OLi3QYkIRYYckjAoEbWqs62MnWFwiAoUnCJHzZ2TXROCHnjxm2hTyZ2TXROCHlagss32Sb(ZcrZXTHBmmB2UnEfLlSjKgeexvbeZQ1yqMKlg3lennZv2zOKTMg0Pq77JwSz724vuUWfadjPBB2aN(ZcrZXTHBmmIGqvHO54vuAvtCbInsgZSlUAsUyChYyMDX1IZeWGgq)plenh3gUXWidae1Q54MKlgfIMM5k7muY2MnWU3RcIDTyhyQ6gxTm3Tf2Lve3poubXUwSz724vuUWf2Lve3pfQpAHmaquRMJxamKKUTzy)ZcrZXTHBmmYaarTAoUjKgeexvbeZQ1yqMKlg3lennZv2zOKTnBGDVxfe7AXoWu1nUAzUBlSlRiUFCOcIDTyZ2TXROCHlSlRiUF6uO99rlKbaIA1C8cGHK0Tnd7P)Sq0CCB4gdRDtCDGQ20JJqci1gMKlgjJz2fxlotadAa9JdYyMDX1INXBADr4JdYyMDX1sGgGu8JdYyMDX1Ipo)NfIMJBd3yyqcIxssfiTAeGnjxmANiu1UjGUPg4plenh3gUXWiccvfIMJxrPvnXfi2yxabIrcGRTaU1KCX4EYyMDX1Iz21TgGq7jZG6dmEjHAzVNECLiQyvW0UXfal9ghh9rljul790JRerfRcM2nU2hTOjjq6XNcrMb1hy8InccA8AxabIrcGlagss32mSH23hT0UjUoqvB6XribKAJcGHK0TMc7XXoQGyxlTBIRdu1MECesaP2OWUSI4(Pthh73tgZSlUwCMag0a6hhKXm7IRLanaP4hhKXm7IRfFC(uiYmO(aJxSrqqJx7ciqmsaCbWqs62MHn0((OL2nX1bQAtpocjGuBuamKKU1uypo2rfe7APDtCDGQ20JJqci1gf2Lve3pD64ypzmZU4AXZ4nTUiCO9Kzq9bgVyNiufmAbWsVXXrF0IDIqvWOfnjbsp(uiYmO(aJxSrqqJx7ciqmsaCbWqs62MHn0((OL2nX1bQAtpocjGuBuamKKU1uypo2rfe7APDtCDGQ20JJqci1gf2Lve3pD6plenh3gUXW6ciq1oritYfJKzq9bgVyJGGgV2fqGyKa4cGHK0TMQjex1P2t(plenh3gUXWiccvfIMJxrPvnXfi2yQm0FwiAoUnCJHreeQkenhVIsRAIlqSrlBsUySZRrllf7M0hyQm0kqiCXQcjqZ7HD3crZXl2nPpWuxhKwsVUGY4n90XrNxJwwk2nPpWuzOvGq4cGHK0TnBO)Sq0CCB4gddsq8ssQaPvJaSj5IX(OfZjIRQKUw0Kei94)Sq0CCB4gddsq8ssQaPvJaSj5IX(OLeQL9E6XvIOIvbt7gx7Jw0Kei94)Sq0CCB4gddsq8ssQaPvJaSj5IX(Of7eHQGrlAscKE8FwiAoUnCJHbjiEjjvG0Qra2KCXOki21s7M46avTPhhHeqQnkSlRiUhAFF0s7M46avTPhhHeqQnkAscKE8XHDIqv7Ma6MAOJdnH4Qo1EYntMb1hy8s7M46avTPhhHeqQnkagss3E6plenh3gUXWGeeVKKkqA1iaBsUyufe7AXoWu1nUAzUBlSlRiU)NfIMJBd3yyDGKEfLlSj5IX1OLLs6S5uLvex7muA5IvfsatnGHpowJwwkPZMtvwrCTZqPLlrTH0eIR6u7j3Sb(ZcrZXTHBmmIGqvHO54vuAvtCbInsgZSlU(NfIMJBd3yys84nmjxmc4faB3Kve)NfIMJBd3yys84nmH0GG4QkGywTgdYKCX4EHOPzUYodLS10GofApGxaSDtwr8P)Sq0CCB4gdJmaquRMJBsUyeWla2UjRioKq00mxzNHs22Sb29EvqSRf7atv34QL5UTWUSI4(XHki21InB3gVIYfUWUSI4(P)Sq0CCB4gdlYTQSI4QSSGsIMJBsUyeWla2UjRi(plenh3gUXWSz724vuUWMKlgb8cGTBYkI)ZcrZXTHBmmB2UnEfLlSjKgeexvbeZQ1yqMKlg3lennZv2zOKTMg0Pq7b8cGTBYkIp9NfIMJBd3yyKbaIA1CCtiniiUQciMvRXGmjxmUxiAAMRSZqjBB2a7EVki21IDGPQBC1YC3wyxwrC)4qfe7AXMTBJxr5cxyxwrC)0Pq7b8cGTBYkIp9NfIMJBd3yyDGKE1orO)Sq0CCB4gdZUj9bM66G0)8FwiAoUTidBSDtCDGQ20JJqci1g)zHO542ImC4gdBtIC9plenh3wKHd3yyebHQcrZXRO0QM4ceBSlGaXibW1wa3AsUyCpzmZU4AXm76wdqO(OLeQL9E6XvIOIvbt7gx7Jw0Kei94qKzq9bgVyJGGgV2fqGyKa4cGHK0TndBO99rlTBIRdu1MECesaP2OayijDRPWECSJki21s7M46avTPhhHeqQnkSlRiUF60XXEYyMDX1INXBADr4q9rl2jcvbJw0Kei94qKzq9bgVyJGGgV2fqGyKa4cGHK0TndBO99rlTBIRdu1MECesaP2OayijDRPWECSJki21s7M46avTPhhHeqQnkSlRiUF60XX(9KXm7IRfNjGbnG(XbzmZU4Ajqdqk(XbzmZU4AXhNpfQpAPDtCDGQ20JJqci1gfnjbspouF0s7M46avTPhhHeqQnkagss32mSN(ZcrZXTfz4WngML5EDwQKbaIA1CCtYfJQGyxl2bMQUXvlZDBHDzfX9qeXRwM7)zHO542ImC4gdZYCVolvYaarTAoUj5IXDubXUwSdmvDJRwM72c7YkI7H2PpAXYCVolvYaarTAoErtsG0JdTt61fugVPH6Jwidae1Q54faVay7MSI4)Sq0CCBrgoCJHjXJ3WesdcIRQaIz1AmitYfJcrtZCTpArIhVrZgieGxaSDtwr8FwiAoUTidhUXWK4XBycPbbXvvaXSAngKj5IrHOPzU2hTiXJ3WuJgieGxaSDtwrCO(OfjE8gfnjbsp(plenh3wKHd3yyrUvLvexLLfus0CCtYfJcrtZCTpAjYTQSI4QSSGsIMJB0WhhAscKECiaVay7MSI4)Sq0CCBrgoCJHf5wvwrCvwwqjrZXnH0GG4QkGywTgdYKCX4oAscKECOwZTQGyxlabQvCTkllOKO542c7YkI7HeIMM5AF0sKBvzfXvzzbLenhVzd9NfIMJBlYWHBmmZjIRQKUAsUy0orOQDtaDtd6plenh3wKHd3yyebHQcrZXRO0QM4ceBKmMzxC1eRcsIAmitYfJ7qgZSlUwCMag0a6)zHO542ImC4gdJiiuviAoEfLw1exGyJDbeigjaU2c4wtYfJ7jJz2fxlMzx3AacTNmdQpW4LeQL9E6XvIOIvbt7gxaS0BCC0hTKqTS3tpUsevSkyA34AF0IMKaPhFkezguFGXl2iiOXRDbeigjaUayijDBZWgAFF0s7M46avTPhhHeqQnkagss3AkShh7OcIDT0UjUoqvB6XribKAJc7YkI7NoDCSFpzmZU4AXzcyqdOFCqgZSlUwc0aKIFCqgZSlUw8X5tHiZG6dmEXgbbnETlGaXibWfadjPBBg2q77JwA3exhOQn94iKasTrbWqs6wtH94yhvqSRL2nX1bQAtpocjGuBuyxwrC)0PJJ9KXm7IRfpJ306IWH2tMb1hy8IDIqvWOfal9ghh9rl2jcvbJw0Kei94tHiZG6dmEXgbbnETlGaXibWfadjPBBg2q77JwA3exhOQn94iKasTrbWqs6wtH94yhvqSRL2nX1bQAtpocjGuBuyxwrC)0P)Sq0CCBrgoCJH1fqGQDIqMKlgjZG6dmEXgbbnETlGaXibWfadjPBnvtiUQtTN8FwiAoUTidhUXWiccvfIMJxrPvnXfi2yQm0FwiAoUTidhUXWGeeVKKkqA1iaBsUySpAXCI4QkPRfnjbsp(plenh3wKHd3yyqcIxssfiTAeGnjxm2hTyNiufmArtsG0JdTJki21IDGPQBC1YC3wyxwrC)plenh3wKHd3yyqcIxssfiTAeGnjxmUJki21I5eXvvsxlSlRiU)NfIMJBlYWHBmmibXljPcKwncWMKlgTteQA3eq3ud8NfIMJBlYWHBmmB2UnEfLlSjKgeexvbeZQ1yqMKlgfIMM5AF0InB3gVIYfUzJgkeGxaSDtwrCOD6JwSz724vuUWfnjbsp(plenh3wKHd3yyebHQcrZXRO0QM4ceBKmMzxC1eRcsIAmitYfJKXm7IRfNjGbnG(FwiAoUTidhUXW6aj9kkxytYfJRrllL0zZPkRiU2zO0YfRkKaMA0Gm8XXA0YsjD2CQYkIRDgkTCjQnKMqCvNAp5MnOJJ1OLLs6S5uLvex7muA5IvfsatnAidkuF0IDIqvWOfnjbsp(plenh3wKHd3yyDGKE1orO)Sq0CCBrgoCJHz3K(atDDq6F(plenh3wiJz2fxnMqTS3tpUsevSkyA3ytYfJKzq9bgVyJGGgV2fqGyKa4cGHK0TnhKHpoiZG6dmEXgbbnETlGaXibWfadjPBn1Gm8FwiAoUTqgZSlUgUXW6mjHen9466GutYfJKzq9bgVyJGGgV2fqGyKa4cGHK0TMAqH2351OLLYMe5AbWqs6wtnWXXoQGyxlBsKRf2Lve3p9NfIMJBlKXm7IRHBmm7eHQGrnjxmsMb1hy8InccA8AxabIrcGlagss32SbDCqMb1hy8InccA8AxabIrcGlagss3AQbz4JdYmO(aJxSrqqJx7ciqmsaCbWqs6wtH1GcrgVhLAHmaquRMECfXmOWUSI4(FwiAoUTqgZSlUgUXWSKjcKECvtDJ)Z)zHO542sxabIrcGRTaU1O5eXvvsxnjxmsMb1hy8InccA8AxabIrcGlagss32mS)zHO542sxabIrcGRTaUnCJH1fqGQDIq)zHO542sxabIrcGRTaUnCJH1oAo(FwiAoUT0fqGyKa4AlGBd3yyljGxrZ0)ZcrZXTLUaceJeaxBbCB4gdBfntVUebA8NfIMJBlDbeigjaU2c42Wng2kdSmiq6X)zHO542sxabIrcGRTaUnCJHreeQkenhVIsRAIlqSrYyMDXvtYfJ7qgZSlUwCMag0a6HiZG6dmEXgbbnETlGaXibWfadjPBBg2)Sq0CCBPlGaXibW1wa3gUXWSrqqJx7ciqmsa8F(plenh3wsLHmgz5AQmK9p)NfIMJBlw24Me56FwiAoUTy5WngwhiPxTteYK0vgaIA1AmAwfKXGmjDLbGOwTMlg78A0YsXUj9bMkdTcecxSQqcyQrd9NfIMJBlwoCJHz3K(atDDqk(AMb2CCmCWAyynCqWAidJVWiap9yl(2ugQDak3FAt9PcrZXFkkTQT8NXxuAvlgE8LmMzxCfdpgUGWWJVSlRiUJdgFjGuzqk4lzguFGXl2iiOXRDbeigjaUayijD7tB(Pbz4NEC8uYmO(aJxSrqqJx7ciqmsaCbWqs62NA6tnidJVcrZXX3eQL9E6XvIOIvbt7gJvmCWIHhFzxwrChhm(saPYGuWxYmO(aJxSrqqJx7ciqmsaCbWqs62NA6tnONg6P7FANxJwwkBsKRfadjPBFQPp1ap944P78uvqSRLnjY1c7YkI7p9e(kenhhF7mjHen9466GuSIHZqy4Xx2Lve3XbJVeqQmif8LmdQpW4fBee041UaceJeaxamKKU9Pn)ud6PhhpLmdQpW4fBee041UaceJeaxamKKU9PM(udYWp944PKzq9bgVyJGGgV2fqGyKa4cGHK0Tp10NcRb90qpLmEpk1czaGOwn94kIzqHDzfXD8viAoo(ANiufmkwXWzam84Rq0CC81sMiq6Xvn1ngFzxwrChhmwXk(25fjcPy4XWfegE8viAoo(ABzeQIgsa8LDzfXDCWyfdhSy4XxHO544BNnprGkKeNe8LDzfXDCWyfdNHWWJVSlRiUJdgFjGuzqk4Rq00mxzNHs2(utFQHWxRcsIIHli8viAoo(seeQkenhVIsRIVO0QvxGy8vggRy4magE8LDzfXDCW4lbKkdsbF1eIFQPp1qggFfIMJJVTBIRdu1MECesaP2aRy4mim84l7YkI74GXxcivgKc(U)PKXm7IRfZSRBnapn0t7JwsOw27PhxjIkwfmTBCTpArtsG0JFAONsMb1hy8InccA8AxabIrcGlagss3(0MFkSpn0t3)0(OL2nX1bQAtpocjGuBuamKKU9PM(uyF6XXt35PQGyxlTBIRdu1MECesaP2OWUSI4(tp90tp944P7FkzmZU4AXZ4nTUi8td90(Of7eHQGrlAscKE8td9uYmO(aJxSrqqJx7ciqmsaCbWqs62N28tH9PHE6(N2hT0UjUoqvB6XribKAJcGHK0Tp10Nc7tpoE6opvfe7APDtCDGQ20JJqci1gf2Lve3F6PNE6PhhpD)t3)uYyMDX1IZeWGgq)PhhpLmMzxCTeObif)PhhpLmMzxCT4JZp90td90(OL2nX1bQAtpocjGuBu0Kei94Ng6P9rlTBIRdu1MECesaP2OayijD7tB(PW(0t4Rq0CC8LiiuviAoEfLwfFrPvRUaX4BxabIrcGRTaUfRy4m4y4Xx2Lve3XbJVeqQmif8TpArIhVrbWqs62N28tna(kenhhFL4XBGvmCnvm84l7YkI74GXxHO544RepEd8LasLbPGV7FQq00mxzNHs2(utFAqp90td909pTpArIhVrbWqs62N28tnWtpHVKgeexvbeZQfdxqyfdxtddp(kenhhF3KixXx2Lve3XbJvmC7sm84l7YkI74GXxcivgKc(U)PcrtZCLDgkz7tn9PW(0qpLmMzxCTyMDDRb4PHE6(NsMb1hy8sc1YEp94kruXQGPDJlaw6nE6XXt7JwsOw27PhxjIkwfmTBCTpArtsG0JF6PNg6P7FAF0s7M46avTPhhHeqQnkAscKE8tpoE6opvfe7APDtCDGQ20JJqci1gf2Lve3F6PNE6PhhpD)tfIMM5k7muY2NA6tH9PHE6(NsgZSlUwCMag0a6p944PKXm7IRLanaP4p944PKXm7IRfFC(PNEAONU)P9rlTBIRdu1MECesaP2OOjjq6Xp944P78uvqSRL2nX1bQAtpocjGuBuyxwrC)PNE6PNEC809pviAAMRSZqjBFQPpf2Ng6PKXm7IRfpJ306IWpn0t3)uYmO(aJxSteQcgTayP34PhhpTpAXorOky0IMKaPh)0tpn0t3)0(OL2nX1bQAtpocjGuBu0Kei94NEC80DEQki21s7M46avTPhhHeqQnkSlRiU)0tp9e(kenhhFjccvfIMJxrPvXxuA1Qlqm(2fqGyKa4AlGBXkgUGmmgE8LDzfXDCW4lbKkdsbFfIMM5k7muY2NA6tH9PHEQki21IDGPQBC1YC3wyxwrC)PHE6opTpAXYCVolvYaarTAoErtsG0JFAONUZttVUGY4nfFfIMJJVwM71zPsgaiQvZXXkgUGccdp(YUSI4ooy8LasLbPGVcrtZCLDgkz7tn9PW(0qpvfe7AXMTBJxr5cxyxwrC)PHE6opTpAXYCVolvYaarTAoErtsG0JFAONUZttVUGY4n9PHEAF0czaGOwnhVayijD7tB(PgaFfIMJJVwM71zPsgaiQvZXXkgUGGfdp(YUSI4ooy8LasLbPGV7FQDIqv7Ma6p10Ng0tpoEQq00mxzNHs2(utFkSp90td9uYmO(aJxSrqqJx7ciqmsaCbWqs62NA6tdcw8viAoo(AorCvL0vSIHlidHHhFzxwrChhm(saPYGuWxHOPzU2hTe5wvwrCvwwqjrZXFQXNA4NEC8unjbsp(PHEAF0sKBvzfXvzzbLenhVayijD7tB(PgaFfIMJJVrUvLvexLLfus0CCSIHlidGHhFzxwrChhm(saPYGuW3(OfB2UnEfLlCbWqs62N28tna(kenhhFTz724vuUWyfdxqgegE8LDzfXDCW4Rq0CC81MTBJxr5cJVeqQmif8D)tfIMM5k7muY2NA6td6PNEAONU)P9rl2SDB8kkx4cGHK0TpT5NAGNEcFjniiUQciMvlgUGWkgUGm4y4Xx2Lve3XbJVeqQmif8DNNsgZSlUwCMag0a64Rq0CC8LiiuviAoEfLwfFrPvRUaX4lzmZU4kwXWfutfdp(YUSI4ooy8LasLbPGVcrtZCLDgkz7tB(Pg4P7(P7FQki21IDGPQBC1YC3wyxwrC)Phhpvfe7AXMTBJxr5cxyxwrC)PNEAON2hTqgaiQvZXlagss3(0MFkS4Rq0CC8LmaquRMJJvmCb10WWJVSlRiUJdgFfIMJJVKbaIA1CC8LasLbPGV7FQq00mxzNHs2(0MFQbE6UF6(NQcIDTyhyQ6gxTm3Tf2Lve3F6XXtvbXUwSz724vuUWf2Lve3F6PNE6PHE6(N2hTqgaiQvZXlagss3(0MFkSp9e(sAqqCvfqmRwmCbHvmCbTlXWJVSlRiUJdgFjGuzqk4lzmZU4AXzcyqdO)0JJNsgZSlUw8mEtRlc)0JJNsgZSlUwc0aKI)0JJNsgZSlUw8Xz8viAoo(2UjUoqvB6XribKAdSIHdwdJHhFzxwrChhm(saPYGuWx7eHQ2nb0FQPp1a4Rq0CC8fsq8ssQaPvJamwXWbBqy4Xx2Lve3XbJVeqQmif8D)tjJz2fxlMzx3AaEAONU)PKzq9bgVKqTS3tpUsevSkyA34cGLEJNEC80(OLeQL9E6XvIOIvbt7gx7Jw0Kei94NE6PHEkzguFGXl2iiOXRDbeigjaUayijD7tB(PW(0qpD)t7JwA3exhOQn94iKasTrbWqs62NA6tH9PhhpDNNQcIDT0UjUoqvB6XribKAJc7YkI7p90tp90JJNU)P7FkzmZU4AXzcyqdO)0JJNsgZSlUwc0aKI)0JJNsgZSlUw8X5NE6PHEkzguFGXl2iiOXRDbeigjaUayijD7tB(PW(0qpD)t7JwA3exhOQn94iKasTrbWqs62NA6tH9PhhpDNNQcIDT0UjUoqvB6XribKAJc7YkI7p90tp90JJNU)PKXm7IRfpJ306IWpn0t3)uYmO(aJxSteQcgTayP34PhhpTpAXorOky0IMKaPh)0tpn0tjZG6dmEXgbbnETlGaXibWfadjPBFAZpf2Ng6P7FAF0s7M46avTPhhHeqQnkagss3(utFkSp944P78uvqSRL2nX1bQAtpocjGuBuyxwrC)PNE6j8viAoo(seeQkenhVIsRIVO0QvxGy8TlGaXibW1wa3IvmCWclgE8LDzfXDCW4lbKkdsbFjZG6dmEXgbbnETlGaXibWfadjPBFQPpvtiUQtTNm(kenhhF7ciq1oriSIHdwdHHhFzxwrChhm(kenhhFjccvfIMJxrPvXxuA1Qlqm(MkdHvmCWAam84l7YkI74GXxcivgKc(251OLLIDt6dmvgAfieUyvHe4Pn)09pf2NU7NkenhVy3K(atDDqAj96ckJ30NE6PhhpTZRrllf7M0hyQm0kqiCbWqs62N28tne(kenhhFjccvfIMJxrPvXxuA1Qlqm(AzSIHdwdcdp(YUSI4ooy8LasLbPGV9rlMtexvjDTOjjq6X4Rq0CC8fsq8ssQaPvJamwXWbRbhdp(YUSI4ooy8LasLbPGV9rljul790JRerfRcM2nU2hTOjjq6X4Rq0CC8fsq8ssQaPvJamwXWbBtfdp(YUSI4ooy8LasLbPGV9rl2jcvbJw0Kei9y8viAoo(cjiEjjvG0QragRy4GTPHHhFzxwrChhm(saPYGuWxvqSRL2nX1bQAtpocjGuBuyxwrC)PHE6(N2hT0UjUoqvB6XribKAJIMKaPh)0JJNANiu1UjG(tn9Pg6PhhpvtiUQtTN8tB(PKzq9bgV0UjUoqvB6XribKAJcGHK0Tp9e(kenhhFHeeVKKkqA1iaJvmCWUlXWJVSlRiUJdgFjGuzqk4Rki21IDGPQBC1YC3wyxwrChFfIMJJVqcIxssfiTAeGXkgodzym84l7YkI74GXxcivgKc(UgTSusNnNQSI4ANHslxSQqc8utFQbm8tpoE6A0YsjD2CQYkIRDgkTCjQ9PHEQMqCvNAp5N28tna(kenhhF7aj9kkxySIHZqbHHhFzxwrChhm(kenhhFjccvfIMJxrPvXxuA1Qlqm(sgZSlUIvmCgcwm84l7YkI74GXxcivgKc(c4faB3KveJVcrZXXxjE8gyfdNHmegE8LDzfXDCW4Rq0CC8vIhVb(saPYGuW39pviAAMRSZqjBFQPpnONE6PHE6(Nc4faB3Kve)0t4lPbbXvvaXSAXWfewXWzidGHhFzxwrChhm(saPYGuWxaVay7MSI4Ng6PcrtZCLDgkz7tB(Pg4P7(P7FQki21IDGPQBC1YC3wyxwrC)Phhpvfe7AXMTBJxr5cxyxwrC)PNWxHO544lzaGOwnhhRy4mKbHHhFzxwrChhm(saPYGuWxaVay7MSIy8viAoo(g5wvwrCvwwqjrZXXkgodzWXWJVSlRiUJdgFjGuzqk4lGxaSDtwrm(kenhhFTz724vuUWyfdNHAQy4Xx2Lve3XbJVcrZXXxB2UnEfLlm(saPYGuW39pviAAMRSZqjBFQPpnONE6PHE6(Nc4faB3Kve)0t4lPbbXvvaXSAXWfewXWzOMggE8LDzfXDCW4Rq0CC8LmaquRMJJVeqQmif8D)tfIMM5k7muY2N28tnWt39t3)uvqSRf7atv34QL5UTWUSI4(tpoEQki21InB3gVIYfUWUSI4(tp90tpn0t3)uaVay7MSI4NEcFjniiUQciMvlgUGWkgodTlXWJVcrZXX3oqsVANie(YUSI4ooySIHZaggdp(kenhhFTBsFGPUoifFzxwrChhmwXk(2cyYaTkkgEmCbHHhFzxwrChhm(saPYGuWxnH4NA6tn8td90DEAlRfbLM5Ng6P7801OLLsmiHMeW1zPAfcixscxIAXxHO5447cJQ9bkDrZXXkgoyXWJVcrZXXxBee041fgTf5kdWx2Lve3XbJvmCgcdp(YUSI4ooy8LasLbPGVQGyxlXGeAsaxNLQviGCjjCHDzfXD8viAoo(gdsOjbCDwQwHaYLKWyfdNbWWJVSlRiUJdgFNw81Yk(kenhhFnlGuwrm(Awqrm(kennZ1(OfYaarTAo(tn9Pg(PHEQq00mx7JwK4XB8utFQHFAONkennZ1(OLi3QYkIRYYckjAo(tn9Pg(PHE6(NUZtvbXUwSz724vuUWf2Lve3F6XXtfIMM5AF0InB3gVIYf(PM(ud)0tpn0t3)0(OL2nX1bQAtpocjGuBu0Kei94NEC80DEQki21s7M46avTPhhHeqQnkSlRiU)0t4RzbuDbIX3(O2kGLEdSIHZGWWJVSlRiUJdgFDbIXxPj3UjaXwxgxRZsTDGHb4Rq0CC8vAYTBcqS1LX16SuBhyyawXWzWXWJVSlRiUJdgFjGuzqk4RTLrOQkGywTflZ96Sujdae1Q54vz4NAQXNAONg6P78uExikBB5ErAYTBcqS1LX16SuBhyya(kenhhFTm3RZsLmaquRMJJvmCnvm84Rq0CC8DtICfFzxwrChhmwXW10WWJVSlRiUJdgFjGuzqk47opvfe7AztICTWUSI4(td9uBlJqvvaXSAlwM71zPsgaiQvZXRYWpT5NAONg6P78uExikBB5ErAYTBcqS1LX16SuBhyya(kenhhFTBsFGPUoifRyfFLHXWJHlim84Rq0CC8TDtCDGQ20JJqci1g4l7YkI74GXkgoyXWJVcrZXX3njYv8LDzfXDCWyfdNHWWJVSlRiUJdgFjGuzqk47(NsgZSlUwmZUU1a80qpTpAjHAzVNECLiQyvW0UX1(Ofnjbsp(PHEkzguFGXl2iiOXRDbeigjaUayijD7tB(PW(0qpD)t7JwA3exhOQn94iKasTrbWqs62NA6tH9PhhpDNNQcIDT0UjUoqvB6XribKAJc7YkI7p90tp90JJNU)PKXm7IRfpJ306IWpn0t7JwSteQcgTOjjq6Xpn0tjZG6dmEXgbbnETlGaXibWfadjPBFAZpf2Ng6P7FAF0s7M46avTPhhHeqQnkagss3(utFkSp944P78uvqSRL2nX1bQAtpocjGuBuyxwrC)PNE6PNEC809pD)tjJz2fxlotadAa9NEC8uYyMDX1sGgGu8NEC8uYyMDX1Ipo)0tpn0t7JwA3exhOQn94iKasTrrtsG0JFAON2hT0UjUoqvB6XribKAJcGHK0TpT5Nc7tpHVcrZXXxIGqvHO54vuAv8fLwT6ceJVDbeigjaU2c4wSIHZay4Xx2Lve3XbJVeqQmif8vfe7AXoWu1nUAzUBlSlRiU)0qpLiE1YChFfIMJJVwM71zPsgaiQvZXXkgodcdp(YUSI4ooy8LasLbPGV78uvqSRf7atv34QL5UTWUSI4(td90DEAF0IL5EDwQKbaIA1C8IMKaPh)0qpDNNMEDbLXB6td90(OfYaarTAoEbWla2UjRigFfIMJJVwM71zPsgaiQvZXXkgodogE8LDzfXDCW4Rq0CC8vIhVb(saPYGuWxHOPzU2hTiXJ34Pn)ud80qpfWla2UjRigFjniiUQciMvlgUGWkgUMkgE8LDzfXDCW4Rq0CC8vIhVb(saPYGuWxHOPzU2hTiXJ34PMA8Pg4PHEkGxaSDtwr8td90(OfjE8gfnjbspgFjniiUQciMvlgUGWkgUMggE8LDzfXDCW4lbKkdsbFfIMM5AF0sKBvzfXvzzbLenh)PgFQHF6XXt1Kei94Ng6PaEbW2nzfX4Rq0CC8nYTQSI4QSSGsIMJJvmC7sm84l7YkI74GXxHO544BKBvzfXvzzbLenhhFjGuzqk47opvtsG0JFAON2AUvfe7AbiqTIRvzzbLenh3wyxwrC)PHEQq00mx7JwICRkRiUkllOKO54pT5NAi8L0GG4QkGywTy4ccRy4cYWy4Xx2Lve3XbJVeqQmif81orOQDta9NA6tdcFfIMJJVMtexvjDfRy4ckim84l7YkI74GXxcivgKc(UZtjJz2fxlotadAaD81QGKOy4ccFfIMJJVebHQcrZXRO0Q4lkTA1figFjJz2fxXkgUGGfdp(YUSI4ooy8LasLbPGV7FkzmZU4AXm76wdWtd909pLmdQpW4LeQL9E6XvIOIvbt7gxaS0B80JJN2hTKqTS3tpUsevSkyA34AF0IMKaPh)0tpn0tjZG6dmEXgbbnETlGaXibWfadjPBFAZpf2Ng6P7FAF0s7M46avTPhhHeqQnkagss3(utFkSp944P78uvqSRL2nX1bQAtpocjGuBuyxwrC)PNE6PNEC809pD)tjJz2fxlotadAa9NEC8uYyMDX1sGgGu8NEC8uYyMDX1Ipo)0tpn0tjZG6dmEXgbbnETlGaXibWfadjPBFAZpf2Ng6P7FAF0s7M46avTPhhHeqQnkagss3(utFkSp944P78uvqSRL2nX1bQAtpocjGuBuyxwrC)PNE6PNEC809pLmMzxCT4z8Mwxe(PHE6(NsMb1hy8IDIqvWOfal9gp944P9rl2jcvbJw0Kei94NE6PHEkzguFGXl2iiOXRDbeigjaUayijD7tB(PW(0qpD)t7JwA3exhOQn94iKasTrbWqs62NA6tH9PhhpDNNQcIDT0UjUoqvB6XribKAJc7YkI7p90tpHVcrZXXxIGqvHO54vuAv8fLwT6ceJVDbeigjaU2c4wSIHlidHHhFzxwrChhm(saPYGuWxYmO(aJxSrqqJx7ciqmsaCbWqs62NA6t1eIR6u7jJVcrZXX3UacuTtecRy4cYay4Xx2Lve3XbJVcrZXXxIGqvHO54vuAv8fLwT6ceJVPYqyfdxqgegE8LDzfXDCW4lbKkdsbF7JwmNiUQs6ArtsG0JXxHO544lKG4LKubsRgbySIHlidogE8LDzfXDCW4lbKkdsbF7JwSteQcgTOjjq6Xpn0t35PQGyxl2bMQUXvlZDBHDzfXD8viAoo(cjiEjjvG0QragRy4cQPIHhFzxwrChhm(saPYGuW3DEQki21I5eXvvsxlSlRiUJVcrZXXxibXljPcKwncWyfdxqnnm84l7YkI74GXxcivgKc(ANiu1UjG(tn9PgaFfIMJJVqcIxssfiTAeGXkgUG2Ly4Xx2Lve3XbJVcrZXXxB2UnEfLlm(saPYGuWxHOPzU2hTyZ2TXROCHFAZgFQHEAONc4faB3Kve)0qpDNN2hTyZ2TXROCHlAscKEm(sAqqCvfqmRwmCbHvmCWAym84l7YkI74GXxcivgKc(sgZSlUwCMag0a64RvbjrXWfe(kenhhFjccvfIMJxrPvXxuA1Qlqm(sgZSlUIvmCWgegE8LDzfXDCW4lbKkdsbFxJwwkPZMtvwrCTZqPLlwvibEQPgFQbz4NEC801OLLs6S5uLvex7muA5su7td9unH4Qo1EYpT5NAqp944PRrllL0zZPkRiU2zO0YfRkKap1uJp1qg0td90(Of7eHQGrlAscKEm(kenhhF7aj9kkxySIHdwyXWJVcrZXX3oqsVANie(YUSI4ooySIHdwdHHhFfIMJJV2nPpWuxhKIVSlRiUJdgRyfFTmgEmCbHHhFfIMJJVBsKR4l7YkI74GXkgoyXWJVSlRiUJdgFtxzaiQvR5c(251OLLIDt6dmvgAfieUyvHeWuJgcFfIMJJVDGKE1ori8nDLbGOwTgJMvbHVbHvmCgcdp(kenhhFTBsFGPUoifFzxwrChhmwXk(MkdHHhdxqy4XxHO544BKLRPYqw8LDzfXDCWyfR4BxabIrcGRTaUfdpgUGWWJVSlRiUJdgFjGuzqk4lzguFGXl2iiOXRDbeigjaUayijD7tB(PWIVcrZXXxZjIRQKUIvmCWIHhFfIMJJVDbeOANie(YUSI4ooySIHZqy4XxHO544B7O544l7YkI74GXkgodGHhFfIMJJVljGxrZ0Xx2Lve3XbJvmCgegE8viAoo(UIMPxxIanWx2Lve3XbJvmCgCm84Rq0CC8DLbwgei9y8LDzfXDCWyfdxtfdp(YUSI4ooy8LasLbPGV78uYyMDX1IZeWGgq)PHEkzguFGXl2iiOXRDbeigjaUayijD7tB(PWIVcrZXXxIGqvHO54vuAv8fLwT6ceJVKXm7IRyfdxtddp(kenhhFTrqqJx7ciqmsam(YUSI4ooySIvSIVsKUna89MqnfyfRym]] )


end