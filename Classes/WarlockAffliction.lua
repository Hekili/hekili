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


    spec:RegisterPack( "Affliction", 20210208, [[dCeQwbqiLk9iscBsq(eOaAuQGtPu1RKImlss3sPI2LK(LazyGIoMaSmqPNjGAAcixduOTrsu(gjr14ijIZPuHSosIuMNuu3JeTpsOdQubwOa1dvQGAIkvOUiOGQnckaojOGIvQcntsIuDtqbPDcQ6NGcudLKizPGcINQstLe8vqbO9c1FLyWiomXIvspgPjlvxg1MvIpluJwPCArVwqnBi3gKDt1VvmCP0Xbfilh45KA6uUUq2oj13bvgpOGsNxkSELkiZxfTFvnoaSc4BxmgdpSWe2aGjSWuLudyhbJWIVwJwgFBfAyjMXxxGy8DhSSGsQLJJVTsd0iDSc4REIaugF3mRvRslOGItBlATshOG0juesSCCkqwSG0jeni8DnkrgmmoEfF7IXy4HfMWgamHfMQKAa7iymayvj4RULPy4HvLbJ47w27SJxX3oRP4RkuXt2bllOKA54pbgqbGgA4)OkuXtGbGxbrcOXtujQ(eyHjSb8h)JQqfpzhEt8ywRs7pQcv8KD(KDqVZ9NCBze6jQ0hA46FufQ4j78j7GEN7pzhZQNiWtGHkXjT(hvHkEYoFYoO35(twbSeMUjUZONGM4K(KLb8KDmqs)j3jcv)JQqfpzNprb4yj8tGHkiEjPpbgI0Ara(jOjoPpXMNa3ac)KC5jnMiyGa(jqPwNE8tKNycID7jP)eBtSNag4Q)rvOINSZNad3Lve)eyicuR42t2bllOKA546NOsPwL6jMGy3Q)rvOINSZNOaCSew)eBEIOEY(twrdCPh)KDSachJea)K0FcueYYDAciMTNaxqZt2XWGvq)KO26FufQ4j78j7WJ3zxZprpq8t2XciCmsa8tuPaC7tOccPFInpbW9ik)e6a1gzILJ)elH46FufQ4j78jx2EIEG4NqfeQiulhVGsT9e2nqY6NyZt0giP2tS5jI6j7pHUX0WPh)euQn9tSnXEcCJdd0EYk)eal0nUx)JQqfpzNpbgSJA8KlZ9NmoLFslG3zBecvX3wWSKigFvHkEYoyzbLulh)jWaka0qd)hvHkEcma8kisanEIkr1NalmHnG)4FufQ4j7WBIhZAvA)rvOINSZNSd6DU)KBlJqprL(qdx)JQqfpzNpzh07C)j7yw9ebEcmujoP1)OkuXt25t2b9o3FYkGLW0nXDg9e0eN0NSmGNSJbs6p5orO6FufQ4j78jkahlHFcmubXlj9jWqKwlcWpbnXj9j28e4gq4NKlpPXebdeWpbk160JFI8etqSBpj9NyBI9eWax9pQcv8KD(ey4USI4NadrGAf3EYoyzbLulhx)evk1QupXee7w9pQcv8KD(efGJLW6NyZte1t2FYkAGl94NSJfq4yKa4NK(tGIqwUttaXS9e4cAEYoggSc6Ne1w)JQqfpzNpzhE8o7A(j6bIFYowaHJrcGFIkfGBFcvqi9tS5jaUhr5NqhO2itSC8Nyjex)JQqfpzNp5Y2t0de)eQGqfHA54fuQTNWUbsw)eBEI2aj1EInprupz)j0nMgo94NGsTPFITj2tGBCyG2tw5NayHUX96FufQ4j78jWGDuJNCzU)KXP8tAb8oBJqO6F8pkulhxxBbmDGwft5cJk9bkDXYXvnxuAjeRimdTBlBvbLQ5q7UgTSuJbj0KaUmlfTqb5ss5Au7FuOwoUU2cy6aTkwtkdshbbnEPLT)OqTCCDTfW0bAvSMugumiHMeWLzPOfkixskRAUO0ee7wngKqtc4YSu0cfKljLRSlRiU)hfQLJRRTaMoqRI1KYGulGuwrSQUaXk7JPlaw6nuvTGIyLc1s1CPpwLoaquRLJRimdjulvZL(yvjE8gkcZqc1s1CPpwnY1MSI4ISSGsQLJRimdDyxtqSBvD2UnEbLlCLDzfX9ZtHAPAU0hRQZ2TXlOCHveM7dDOpwTDtCBGk60JJqciTgvlPHtp(8CxtqSB12nXTbQOtpocjG0AuzxwrCF)FuOwoUU2cy6aTkwtkdksZL0yivDbIvk7q6nbi6YY4wzwkTdCm4pkulhxxBbmDGwfRjLbPzUxMLcDaGOwlhxvu6CH2vgamvnxuQBzeQyciMnDvZCVmlf6aarTwoErgwrLbo0UmmOOSTL71auz7OahqG(Jc1YX11wathOvXAszqBsKB)rHA546AlGPd0QynPmi9M0h4kRdYunxuURji2T6Me5wLDzfX9q6wgHkMaIztx1m3lZsHoaquRLJxKHBoWH2LHbfLTTCVgGkBhf4ac0F8pQcv8ey4WWY0iJ7pHvZGgpXsi(j2g)eHAd4jP(jIAjrYkIR)rHA54AL6wgHkOHg(pkulhx3KYG6S6jcuGK4K(hfQLJRBszqubHkc1YXlOuBQ6ceRugwvTbsQPmavZfLc1s1CHDgkzTIb(pkulhx3KYGA3e3gOIo94iKasRHQ5IslHyfdmm)Jc1YX1nPmiQGqfHA54fuQnvDbIv2fq4yKa4slGBvnxuEGoQzxCRQMDBRbiuFSAc1YEp94cvmrBGPDJl9XQwsdNECi6mO(aNx1rqqJx6ciCmsaCfWqs66MHn0H(y12nXTbQOtpocjG0AubmKKUwrypp31ee7wTDtCBGk60JJqciTgv2Lve33V)88aDuZU4w1Z4nRSiCO(yv9eHkGXQwsdNECi6mO(aNx1rqqJx6ciCmsaCfWqs66MHn0H(y12nXTbQOtpocjG0AubmKKUwrypp31ee7wTDtCBGk60JJqciTgv2Lve33V)88Wb6OMDXTQZuWGgq)8KoQzxCRgUbif)8KoQzxCR6JZ7d1hR2UjUnqfD6XribKwJQL0WPhhQpwTDtCBGk60JJqciTgvadjPRBg29)rHA546MugKepEdvZfL9XQs84nQagssx3CG(Jc1YX1nPmijE8gQsBqrCXeqmBALbOAUO8GqTunxyNHswRya7dDOpwvIhVrfWqs66Md0()OqTCCDtkdAtIC7pkulhx3KYGOccveQLJxqP2u1fiwzxaHJrcGlTaUv1Cr5bHAPAUWodLSwrydrh1SlUvvZUT1ae6aDguFGZRjul790JluXeTbM2nUcyP348SpwnHAzVNECHkMOnW0UXL(yvlPHtpEFOd9XQTBIBdurNECesaP1OAjnC6XNN7AcIDR2UjUnqfD6XribKwJk7YkI773FEEqOwQMlSZqjRve2qhOJA2f3QotbdAa9Zt6OMDXTA4gGu8Zt6OMDXTQpoVp0H(y12nXTbQOtpocjG0AuTKgo94ZZDnbXUvB3e3gOIo94iKasRrLDzfX997pppiulvZf2zOK1kcBi6OMDXTQNXBwzr4qhOZG6dCEvprOcySkGLEJZZ(yv9eHkGXQwsdNE8(qh6JvB3e3gOIo94iKasRr1sA40Jpp31ee7wTDtCBGk60JJqciTgv2Lve33V)pkulhx3KYG0m3lZsHoaquRLJRAUOuOwQMlSZqjRve2qMGy3Q6bUITXfnZDDLDzfX9q72hRQzUxMLcDaGOwlhVAjnC6XH2n9YckJ3S)OqTCCDtkdsZCVmlf6aarTwoUQ5IsHAPAUWodLSwrydzcIDRQZ2TXlOCHRSlRiUhA3(yvnZ9YSuOdae1A54vlPHtpo0UPxwqz8MfQpwLoaquRLJxbmKKUU5a9hfQLJRBszqQtexmjDt1Cr5b9eHk6nb0vmGZtHAPAUWodLSwry3hIodQpW5vDee04LUachJeaxbmKKUwXaG9pkulhx3KYGICTjRiUillOKA54QMlkfQLQ5sFSAKRnzfXfzzbLulhxjmppTKgo94q9XQrU2KvexKLfusTC8kGHK01nhO)OqTCCDtkdsNTBJxq5cRAUOSpwvNTBJxq5cxbmKKUU5a9hfQLJRBszq6SDB8ckxyvPnOiUyciMnTYaunxuEqOwQMlSZqjRvmG9Ho0hRQZ2TXlOCHRagssx3CG2)hfQLJRBszqubHkc1YXlOuBQ6ceRKoQzxCt1Cr5U0rn7IBvNPGbnG(FuOwoUUjLbrhaiQ1YXvnxukulvZf2zOK1nhODEWee7wvpWvSnUOzURRSlRiUFEAcIDRQZ2TXlOCHRSlRiUVpuFSkDaGOwlhVcyijDDZW(hfQLJRBszq0baIATCCvPnOiUyciMnTYaunxuEqOwQMlSZqjRBoq78Gji2TQEGRyBCrZCxxzxwrC)80ee7wvNTBJxq5cxzxwrCF)(qh6JvPdae1A54vadjPRBg29)rHA546Mugu7M42av0PhhHeqAn(Jc1YX1nPmiibXljTaKwlcWQMlk1teQO3eqxXa9hfQLJRBszqubHkc1YXlOuBQ6ceRSlGWXibWLwa3QAUO8aDuZU4wvn72wdqOd0zq9boVMqTS3tpUqft0gyA34kGLEJZZ(y1eQL9E6XfQyI2at7gx6JvTKgo949HOZG6dCEvhbbnEPlGWXibWvadjPRBg2qh6JvB3e3gOIo94iKasRrfWqs6AfH98CxtqSB12nXTbQOtpocjG0AuzxwrCF)(ZZdhOJA2f3QotbdAa9Zt6OMDXTA4gGu8Zt6OMDXTQpoVpeDguFGZR6iiOXlDbeogjaUcyijDDZWg6qFSA7M42av0PhhHeqAnQagssxRiSNN7AcIDR2UjUnqfD6XribKwJk7YkI773FEEGoQzxCR6z8Mvweo0b6mO(aNx1teQagRcyP348SpwvprOcySQL0WPhVpeDguFGZR6iiOXlDbeogjaUcyijDDZWg6qFSA7M42av0PhhHeqAnQagssxRiSNN7AcIDR2UjUnqfD6XribKwJk7YkI773)hfQLJRBszqDbeUONiKQ5Is6mO(aNx1rqqJx6ciCmsaCfWqs6AfxY4nRayijD9FuOwoUUjLbrfeQiulhVGsTPQlqSY0yO)OqTCCDtkdIkiurOwoEbLAtvxGyLAw1CrjIvZifHrvEOdDEnAzPQ3K(axHHwbcLRAtOHB(aS7uOwoEvVj9bUY6GSA6LfugVz7pp78A0YsvVj9bUcdTcekxbmKKUU5aV)pkulhx3KYGGeeVK0cqATiaRAUOuOwQMl9XQQtexmjDtry(hfQLJRBszqqcIxsAbiTweGvnxukulvZL(y1eQL9E6XfQyI2at7gx6JPim)Jc1YX1nPmiibXljTaKwlcWQMlkfQLQ5sFSQEIqfWykcZ)OqTCCDtkdcsq8sslaP1IaSQ5IstqSB12nXTbQOtpocjG0AuzxwrCp0bHAPAU0hR2UjUnqfD6XribKwdfH55PEIqf9Ma6kg4ZZLmEZkagssx3mDguFGZRTBIBdurNECesaP1OcyijD9()OqTCCDtkdcsq8sslaP1IaSQ5IstqSBv9axX24IM5UUYUSI4(FuOwoUUjLb1bs6fuUWQMlkxJwwQPZQttwrCPZqPMRAtOHvmqW88CnAzPMoRonzfXLodLAUg1gAjJ3ScGHK01nhO)OqTCCDtkdIkiurOwoEbLAtvxGyL0rn7IB)rHA546MugKepEdvZfLaEbW6nzfX)rHA546MugKepEdvPnOiUyciMnTYaunxuEqOwQMlSZqjRvmG9Hoa4faR3KveV)pkulhx3KYGOdae1A54QMlkb8cG1BYkIdjulvZf2zOK1nhODEWee7wvpWvSnUOzURRSlRiUFEAcIDRQZ2TXlOCHRSlRiUV)pkulhx3KYGICTjRiUillOKA54QMlkb8cG1BYkI)Jc1YX1nPmiD2UnEbLlSQ5IsaVay9MSI4)OqTCCDtkdsNTBJxq5cRkTbfXftaXSPvgGQ5IYdc1s1CHDgkzTIbSp0baVay9MSI49)rHA546MugeDaGOwlhxvAdkIlMaIztRmavZfLheQLQ5c7muY6Md0opycIDRQh4k2gx0m31v2Lve3ppnbXUv1z724fuUWv2Lve33Vp0baVay9MSI49)rHA546MuguhiPx0te6pkulhx3KYG0BsFGRSoi7p(hfQLJRRYWkB3e3gOIo94iKasRXFuOwoUUkd3KYG2Ki3(Jc1YX1vz4MugevqOIqTC8ck1MQUaXk7ciCmsaCPfWTQMlkpqh1SlUvvZUT1aeQpwnHAzVNECHkMOnW0UXL(yvlPHtpoeDguFGZR6iiOXlDbeogjaUcyijDDZWg6qFSA7M42av0PhhHeqAnQagssxRiSNN7AcIDR2UjUnqfD6XribKwJk7YkI773FEEGoQzxCR6z8MvweouFSQEIqfWyvlPHtpoeDguFGZR6iiOXlDbeogjaUcyijDDZWg6qFSA7M42av0PhhHeqAnQagssxRiSNN7AcIDR2UjUnqfD6XribKwJk7YkI773FEE4aDuZU4w1zkyqdOFEsh1SlUvd3aKIFEsh1SlUv9X59H6JvB3e3gOIo94iKasRr1sA40Jd1hR2UjUnqfD6XribKwJkGHK01nd7()OqTCCDvgUjLbPzUxMLcDaGOwlhx1CrPji2TQEGRyBCrZCxxzxwrCpev8IM5(FuOwoUUkd3KYG0m3lZsHoaquRLJRAUOCxtqSBv9axX24IM5UUYUSI4EOD7Jv1m3lZsHoaquRLJxTKgo94q7MEzbLXBwO(yv6aarTwoEfWlawVjRi(pkulhxxLHBszqs84nuL2GI4IjGy20kdq1CrPqTunx6JvL4XB0CGcb4faR3Kve)hfQLJRRYWnPmijE8gQsBqrCXeqmBALbOAUOuOwQMl9XQs84nuuzGcb4faR3KvehQpwvIhVr1sA40J)Jc1YX1vz4MuguKRnzfXfzzbLulhx1CrPqTunx6JvJCTjRiUillOKA54kH55PL0WPhhcWlawVjRi(pkulhxxLHBszqrU2KvexKLfusTCCvPnOiUyciMnTYaunxuURL0WPhhQvDRji2TkqGAf3kYYckPwoUUYUSI4EiHAPAU0hRg5AtwrCrwwqj1YXBoW)rHA546QmCtkdsDI4IjPBQMlk1teQO3eqxXa(Jc1YX1vz4MugevqOIqTC8ck1MQUaXkPJA2f3uvBGKAkdq1Cr5U0rn7IBvNPGbnG(FuOwoUUkd3KYGOccveQLJxqP2u1fiwzxaHJrcGlTaUv1Cr5b6OMDXTQA2TTgGqhOZG6dCEnHAzVNECHkMOnW0UXval9gNN9XQjul790JluXeTbM2nU0hRAjnC6X7drNb1h48QoccA8sxaHJrcGRagssx3mSHo0hR2UjUnqfD6XribKwJkGHK01kc755UMGy3QTBIBdurNECesaP1OYUSI4((9NNhoqh1SlUvDMcg0a6NN0rn7IB1WnaP4NN0rn7IBvFCEFi6mO(aNx1rqqJx6ciCmsaCfWqs66MHn0H(y12nXTbQOtpocjG0AubmKKUwrypp31ee7wTDtCBGk60JJqciTgv2Lve33V)88aDuZU4w1Z4nRSiCOd0zq9boVQNiubmwfWsVX5zFSQEIqfWyvlPHtpEFi6mO(aNx1rqqJx6ciCmsaCfWqs66MHn0H(y12nXTbQOtpocjG0AubmKKUwrypp31ee7wTDtCBGk60JJqciTgv2Lve33V)pkulhxxLHBszqDbeUONiKQ5Is6mO(aNx1rqqJx6ciCmsaCfWqs6AfxY4nRayijD9FuOwoUUkd3KYGOccveQLJxqP2u1fiwzAm0FuOwoUUkd3KYGGeeVK0cqATiaRAUOSpwvDI4IjPBvlPHtp(pkulhxxLHBszqqcIxsAbiTweGvnxu2hRQNiubmw1sA40JdTRji2TQEGRyBCrZCxxzxwrC)pkulhxxLHBszqqcIxsAbiTweGvnxuURji2TQ6eXfts3QSlRiU)hfQLJRRYWnPmiibXljTaKwlcWQMlk1teQO3eqxXa9hfQLJRRYWnPmiD2UnEbLlSQ0guexmbeZMwzaQMlkfQLQ5sFSQoB3gVGYfUzLboeGxaSEtwrCOD7Jv1z724fuUWvlPHtp(pkulhxxLHBszqubHkc1YXlOuBQ6ceRKoQzxCtvTbsQPmavZfL0rn7IBvNPGbnG(FuOwoUUkd3KYG6aj9ckxyvZfLRrll10z1PjRiU0zOuZvTj0WkQegH555A0YsnDwDAYkIlDgk1CnQn0sgVzfadjPRBggppxJwwQPZQttwrCPZqPMRAtOHvuzGHXq9XQ6jcvaJvTKgo94)OqTCCDvgUjLb1bs6f9eH(Jc1YX1vz4MugKEt6dCL1bz)X)OqTCCDLoQzxCtzc1YEp94cvmrBGPDJvnxusNb1h48QoccA8sxaHJrcGRagssx3CaW88KodQpW5vDee04LUachJeaxbmKKUwryeM)rHA546kDuZU4wtkdQZ0esS0JlRdYunxusNb1h48QoccA8sxaHJrcGRagssxRimg6qNxJwwQBsKBvadjPRvmqNN7AcIDRUjrUvzxwrCF)FuOwoUUsh1SlU1KYG0teQagt1CrjDguFGZR6iiOXlDbeogjaUcyijDDZW45jDguFGZR6iiOXlDbeogjaUcyijDTIWimppPZG6dCEvhbbnEPlGWXibWvadjPRvewymeD8EuAv6aarTw6XfeZGk7YkI7)rHA546kDuZU4wtkdstNiq6XflTn(p(hfQLJRRDbeogjaU0c4wLQtexmjDt1CrjDguFGZR6iiOXlDbeogjaUcyijDDZW(hfQLJRRDbeogjaU0c42MuguxaHl6jc9hfQLJRRDbeogjaU0c42Mugu7y54)rHA546AxaHJrcGlTaUTjLbTKaEfnt)pkulhxx7ciCmsaCPfWTnPmOv0m9YseOXFuOwoUU2fq4yKa4slGBBszqRmqZGWPh)hfQLJRRDbeogjaU0c42MugevqOIqTC8ck1MQUaXkPJA2f3unxuUlDuZU4w1zkyqdOhIodQpW5vDee04LUachJeaxbmKKUUzy)Jc1YX11UachJeaxAbCBtkdshbbnEPlGWXibW)X)OqTCCDnngszKMlPXq6)4FuOwoUUQzLBsKB)rHA546QMBszqDGKErprivt3yaiQ1kXOzvqkdq10ngaIATsUOSZRrllv9M0h4km0kqOCvBcnSIkd8FuOwoUUQ5MugKEt6dCL1bz4RAgOZXXWdlmHnaygaSbgFHtaE6XA8fggO2byC)jQ8Niulh)jOuB66FeFrP20yfWx6OMDXnScy4daRa(YUSI4ooy8LcsJbPGV0zq9boVQJGGgV0fq4yKa4kGHK01pP5NeamFY55tOZG6dCEvhbbnEPlGWXibWvadjPRFIIpbgHj(kulhhFtOw27PhxOIjAdmTBm2WWdlwb8LDzfXDCW4lfKgdsbFPZG6dCEvhbbnEPlGWXibWvadjPRFIIpbgFsONC4jDEnAzPUjrUvbmKKU(jk(Ka9KZZNS7tmbXUv3Ki3QSlRiU)K94RqTCC8TZ0esS0JlRdYWgg(aJvaFzxwrChhm(sbPXGuWx6mO(aNx1rqqJx6ciCmsaCfWqs66N08tGXNCE(e6mO(aNx1rqqJx6ciCmsaCfWqs66NO4tGry(KZZNqNb1h48QoccA8sxaHJrcGRagssx)efFcSW4tc9e649O0Q0baIAT0JliMbv2Lve3XxHA544REIqfWyyddFGWkGVc1YXXxnDIaPhxS02y8LDzfXDCWydB4BNxKiKHvadFayfWxHA544RULrOcAOHXx2Lve3XbJnm8WIvaFfQLJJVDw9ebkqsCsXx2Lve3XbJnm8bgRa(YUSI4ooy8LcsJbPGVc1s1CHDgkz9tu8jbgF1giPgg(aWxHA544lvqOIqTC8ck1g(IsTvCbIXxzySHHpqyfWx2Lve3XbJVuqAmif81si(jk(Kadt8vOwoo(2UjUnqfD6XribKwdSHHhgXkGVSlRiUJdgFPG0yqk47HNqh1SlUvvZUT1a8KqpPpwnHAzVNECHkMOnW0UXL(yvlPHtp(jHEcDguFGZR6iiOXlDbeogjaUcyijD9tA(jW(Kqp5Wt6JvB3e3gOIo94iKasRrfWqs66NO4tG9jNNpz3NycIDR2UjUnqfD6XribKwJk7YkI7pz)t2)KZZNC4j0rn7IBvpJ3SYIWpj0t6Jv1teQagRAjnC6Xpj0tOZG6dCEvhbbnEPlGWXibWvadjPRFsZpb2Ne6jhEsFSA7M42av0PhhHeqAnQagssx)efFcSp588j7(etqSB12nXTbQOtpocjG0AuzxwrC)j7FY(NCE(Kdp5WtOJA2f3QotbdAa9NCE(e6OMDXTA4gGu8NCE(e6OMDXTQpo)K9pj0t6JvB3e3gOIo94iKasRr1sA40JFsON0hR2UjUnqfD6XribKwJkGHK01pP5Na7t2JVc1YXXxQGqfHA54fuQn8fLAR4ceJVDbeogjaU0c4wSHHxLHvaFzxwrChhm(sbPXGuW3(yvjE8gvadjPRFsZpjq4RqTCC8vIhVb2WWRYXkGVSlRiUJdgFfQLJJVs84nWxkingKc(E4jc1s1CHDgkz9tu8jb8K9pj0to8K(yvjE8gvadjPRFsZpjqpzp(sBqrCXeqmBAm8bGnm8QeSc4RqTCC8DtICdFzxwrChhm2WWVJWkGVSlRiUJdgFPG0yqk47HNiulvZf2zOK1prXNa7tc9e6OMDXTQA2TTgGNe6jhEcDguFGZRjul790JluXeTbM2nUcyP34jNNpPpwnHAzVNECHkMOnW0UXL(yvlPHtp(j7FsONC4j9XQTBIBdurNECesaP1OAjnC6Xp588j7(etqSB12nXTbQOtpocjG0AuzxwrC)j7FY(NCE(KdprOwQMlSZqjRFIIpb2Ne6jhEcDuZU4w1zkyqdO)KZZNqh1SlUvd3aKI)KZZNqh1SlUv9X5NS)jHEYHN0hR2UjUnqfD6XribKwJQL0WPh)KZZNS7tmbXUvB3e3gOIo94iKasRrLDzfX9NS)j7FY55to8eHAPAUWodLS(jk(eyFsONqh1SlUv9mEZklc)Kqp5WtOZG6dCEvprOcySkGLEJNCE(K(yv9eHkGXQwsdNE8t2)Kqp5Wt6JvB3e3gOIo94iKasRr1sA40JFY55t29jMGy3QTBIBdurNECesaP1OYUSI4(t2)K94RqTCC8LkiurOwoEbLAdFrP2kUaX4BxaHJrcGlTaUfBy4daMyfWx2Lve3XbJVuqAmif8vOwQMlSZqjRFIIpb2Ne6jMGy3Q6bUITXfnZDDLDzfX9Ne6j7(K(yvnZ9YSuOdae1A54vlPHtp(jHEYUpj9YckJ3m8vOwoo(QzUxMLcDaGOwlhhBy4diaSc4l7YkI74GXxkingKc(kulvZf2zOK1prXNa7tc9etqSBvD2UnEbLlCLDzfX9Ne6j7(K(yvnZ9YSuOdae1A54vlPHtp(jHEYUpj9YckJ3SNe6j9XQ0baIATC8kGHK01pP5Nei8vOwoo(QzUxMLcDaGOwlhhBy4dawSc4l7YkI74GXxkingKc(E4j6jcv0BcO)efFsap588jc1s1CHDgkz9tu8jW(K9pj0tOZG6dCEvhbbnEPlGWXibWvadjPRFIIpjayXxHA544R6eXfts3Wgg(acmwb8LDzfXDCW4lfKgdsbFfQLQ5sFSAKRnzfXfzzbLulh)jkFcmFY55tSKgo94Ne6j9XQrU2KvexKLfusTC8kGHK01pP5Nei8vOwoo(g5AtwrCrwwqj1YXXgg(acewb8LDzfXDCW4lfKgdsbF7Jv1z724fuUWvadjPRFsZpjq4RqTCC8vNTBJxq5cJnm8baJyfWx2Lve3XbJVc1YXXxD2UnEbLlm(sbPXGuW3dprOwQMlSZqjRFIIpjGNS)jHEYHN0hRQZ2TXlOCHRagssx)KMFsGEYE8L2GI4IjGy20y4daBy4dqLHvaFzxwrChhm(sbPXGuW3DFcDuZU4w1zkyqdOJVc1YXXxQGqfHA54fuQn8fLAR4ceJV0rn7IByddFaQCSc4l7YkI74GXxkingKc(kulvZf2zOK1pP5NeONSZNC4jMGy3Q6bUITXfnZDDLDzfX9NCE(etqSBvD2UnEbLlCLDzfX9NS)jHEsFSkDaGOwlhVcyijD9tA(jWIVc1YXXx6aarTwoo2WWhGkbRa(YUSI4ooy8vOwoo(shaiQ1YXXxkingKc(E4jc1s1CHDgkz9tA(jb6j78jhEIji2TQEGRyBCrZCxxzxwrC)jNNpXee7wvNTBJxq5cxzxwrC)j7FY(Ne6jhEsFSkDaGOwlhVcyijD9tA(jW(K94lTbfXftaXSPXWha2WWhWocRa(kulhhFB3e3gOIo94iKasRb(YUSI4ooySHHhwyIvaFzxwrChhm(sbPXGuWx9eHk6nb0FIIpjq4RqTCC8fsq8sslaP1Iam2WWdBayfWx2Lve3XbJVuqAmif89WtOJA2f3QQz32AaEsONC4j0zq9boVMqTS3tpUqft0gyA34kGLEJNCE(K(y1eQL9E6XfQyI2at7gx6JvTKgo94NS)jHEcDguFGZR6iiOXlDbeogjaUcyijD9tA(jW(Kqp5Wt6JvB3e3gOIo94iKasRrfWqs66NO4tG9jNNpz3NycIDR2UjUnqfD6XribKwJk7YkI7pz)t2)KZZNC4jhEcDuZU4w1zkyqdO)KZZNqh1SlUvd3aKI)KZZNqh1SlUv9X5NS)jHEcDguFGZR6iiOXlDbeogjaUcyijD9tA(jW(Kqp5Wt6JvB3e3gOIo94iKasRrfWqs66NO4tG9jNNpz3NycIDR2UjUnqfD6XribKwJk7YkI7pz)t2)KZZNC4j0rn7IBvpJ3SYIWpj0to8e6mO(aNx1teQagRcyP34jNNpPpwvprOcySQL0WPh)K9pj0tOZG6dCEvhbbnEPlGWXibWvadjPRFsZpb2Ne6jhEsFSA7M42av0PhhHeqAnQagssx)efFcSp588j7(etqSB12nXTbQOtpocjG0AuzxwrC)j7FYE8vOwoo(sfeQiulhVGsTHVOuBfxGy8TlGWXibWLwa3Inm8Wclwb8LDzfXDCW4lfKgdsbFPZG6dCEvhbbnEPlGWXibWvadjPRFIIpzjJ3ScGHK014RqTCC8TlGWf9eHWggEydmwb8LDzfXDCW4RqTCC8LkiurOwoEbLAdFrP2kUaX4BAme2WWdBGWkGVSlRiUJdgFPG0yqk4lIvZONO4tGrv(tc9KdpPZRrllv9M0h4km0kqOCvBcn8tA(jhEcSpzNprOwoEvVj9bUY6GSA6LfugVzpz)topFsNxJwwQ6nPpWvyOvGq5kGHK01pP5Ne4NShFfQLJJVubHkc1YXlOuB4lk1wXfigF1m2WWdlmIvaFzxwrChhm(sbPXGuWxHAPAU0hRQorCXK0TNO4tGj(kulhhFHeeVK0cqATiaJnm8WQYWkGVSlRiUJdgFPG0yqk4RqTunx6JvtOw27PhxOIjAdmTBCPp2tu8jWeFfQLJJVqcIxsAbiTweGXggEyv5yfWx2Lve3XbJVuqAmif8vOwQMl9XQ6jcvaJ9efFcmXxHA544lKG4LKwasRfbySHHhwvcwb8LDzfXDCW4lfKgdsbFnbXUvB3e3gOIo94iKasRrLDzfX9Ne6jhEIqTunx6JvB3e3gOIo94iKasRXtu8jW8jNNprprOIEta9NO4tc8topFYsgVzfadjPRFsZpHodQpW512nXTbQOtpocjG0AubmKKU(j7XxHA544lKG4LKwasRfbySHHh2Dewb8LDzfXDCW4lfKgdsbFnbXUv1dCfBJlAM76k7YkI74RqTCC8fsq8sslaP1Iam2WWhyyIvaFzxwrChhm(sbPXGuW31OLLA6S60Kvex6muQ5Q2eA4NO4tcemFY55twJwwQPZQttwrCPZqPMRrTpj0twY4nRayijD9tA(jbcFfQLJJVDGKEbLlm2WWh4aWkGVSlRiUJdgFfQLJJVubHkc1YXlOuB4lk1wXfigFPJA2f3Wgg(adlwb8LDzfXDCW4lfKgdsbFb8cG1BYkIXxHA544RepEdSHHpWbgRa(YUSI4ooy8vOwoo(kXJ3aFPG0yqk47HNiulvZf2zOK1prXNeWt2)Kqp5Wta8cG1BYkIFYE8L2GI4IjGy20y4daBy4dCGWkGVSlRiUJdgFPG0yqk4lGxaSEtwr8tc9eHAPAUWodLS(jn)Ka9KD(KdpXee7wvpWvSnUOzURRSlRiU)KZZNycIDRQZ2TXlOCHRSlRiU)K94RqTCC8LoaquRLJJnm8bggXkGVSlRiUJdgFPG0yqk4lGxaSEtwrm(kulhhFJCTjRiUillOKA54yddFGvzyfWx2Lve3XbJVuqAmif8fWlawVjRigFfQLJJV6SDB8ckxySHHpWQCSc4l7YkI74GXxHA544RoB3gVGYfgFPG0yqk47HNiulvZf2zOK1prXNeWt2)Kqp5Wta8cG1BYkIFYE8L2GI4IjGy20y4daBy4dSkbRa(YUSI4ooy8vOwoo(shaiQ1YXXxkingKc(E4jc1s1CHDgkz9tA(jb6j78jhEIji2TQEGRyBCrZCxxzxwrC)jNNpXee7wvNTBJxq5cxzxwrC)j7FY(Ne6jhEcGxaSEtwr8t2JV0guexmbeZMgdFayddFG3ryfWxHA544BhiPx0tecFzxwrChhm2WWhiyIvaFfQLJJV6nPpWvwhKHVSlRiUJdgBydFBbmDGwfdRag(aWkGVSlRiUJdgFPG0yqk4RLq8tu8jW8jHEYUpPLTQGs18tc9KDFYA0YsngKqtc4YSu0cfKljLRrT4RqTCC8DHrL(aLUy54yddpSyfWxHA544RoccA8YcJ2ICJb4l7YkI74GXgg(aJvaFzxwrChhm(sbPXGuWxtqSB1yqcnjGlZsrluqUKuUYUSI4o(kulhhFJbj0KaUmlfTqb5sszSHHpqyfWx2Lve3XbJVtl(QzdFfQLJJVQfqkRigFvlOigFfQLQ5sFSkDaGOwlh)jk(ey(KqprOwQMl9XQs84nEIIpbMpj0teQLQ5sFSAKRnzfXfzzbLulh)jk(ey(Kqp5Wt29jMGy3Q6SDB8ckx4k7YkI7p588jc1s1CPpwvNTBJxq5c)efFcmFY(Ne6jhEsFSA7M42av0PhhHeqAnQwsdNE8topFYUpXee7wTDtCBGk60JJqciTgv2Lve3FYE8vTakUaX4BFmDbWsVb2WWdJyfWx2Lve3XbJVUaX4RSdP3eGOllJBLzP0oWXa8vOwoo(k7q6nbi6YY4wzwkTdCmaBy4vzyfWx2Lve3XbJVc1YXXxnZ9YSuOdae1A544lfKgdsbF1TmcvmbeZMUQzUxMLcDaGOwlhVid)efv(Ka)Kqpz3NWWGIY2wUxLDi9MaeDzzCRmlL2bogGVO05cTJVbatSHHxLJvaFfQLJJVBsKB4l7YkI74GXggEvcwb8LDzfXDCW4lfKgdsbF39jMGy3QBsKBv2Lve3FsONOBzeQyciMnDvZCVmlf6aarTwoErg(jn)Ka)Kqpz3NWWGIY2wUxLDi9MaeDzzCRmlL2bogGVc1YXXx9M0h4kRdYWg2WxzyScy4daRa(kulhhFB3e3gOIo94iKasRb(YUSI4ooySHHhwSc4RqTCC8DtICdFzxwrChhm2WWhySc4l7YkI74GXxkingKc(E4j0rn7IBv1SBBnapj0t6JvtOw27PhxOIjAdmTBCPpw1sA40JFsONqNb1h48QoccA8sxaHJrcGRagssx)KMFcSpj0to8K(y12nXTbQOtpocjG0AubmKKU(jk(eyFY55t29jMGy3QTBIBdurNECesaP1OYUSI4(t2)K9p588jhEcDuZU4w1Z4nRSi8tc9K(yv9eHkGXQwsdNE8tc9e6mO(aNx1rqqJx6ciCmsaCfWqs66N08tG9jHEYHN0hR2UjUnqfD6XribKwJkGHK01prXNa7topFYUpXee7wTDtCBGk60JJqciTgv2Lve3FY(NS)jNNp5Wto8e6OMDXTQZuWGgq)jNNpHoQzxCRgUbif)jNNpHoQzxCR6JZpz)tc9K(y12nXTbQOtpocjG0AuTKgo94Ne6j9XQTBIBdurNECesaP1OcyijD9tA(jW(K94RqTCC8LkiurOwoEbLAdFrP2kUaX4BxaHJrcGlTaUfBy4dewb8LDzfXDCW4lfKgdsbFnbXUv1dCfBJlAM76k7YkI7pj0tOIx0m3XxHA544RM5Ezwk0baIATCCSHHhgXkGVSlRiUJdgFPG0yqk47UpXee7wvpWvSnUOzURRSlRiU)Kqpz3N0hRQzUxMLcDaGOwlhVAjnC6Xpj0t29jPxwqz8M9KqpPpwLoaquRLJxb8cG1BYkIXxHA544RM5Ezwk0baIATCCSHHxLHvaFzxwrChhm(kulhhFL4XBGVuqAmif8vOwQMl9XQs84nEsZpjqpj0ta8cG1BYkIXxAdkIlMaIztJHpaSHHxLJvaFzxwrChhm(kulhhFL4XBGVuqAmif8vOwQMl9XQs84nEIIkFsGEsONa4faR3Kve)KqpPpwvIhVr1sA40JXxAdkIlMaIztJHpaSHHxLGvaFzxwrChhm(sbPXGuWxHAPAU0hRg5AtwrCrwwqj1YXFIYNaZNCE(elPHtp(jHEcGxaSEtwrm(kulhhFJCTjRiUillOKA54ydd)ocRa(YUSI4ooy8vOwoo(g5AtwrCrwwqj1YXXxkingKc(U7tSKgo94Ne6jTQBnbXUvbcuR4wrwwqj1YX1v2Lve3FsONiulvZL(y1ixBYkIlYYckPwo(tA(jbgFPnOiUyciMnng(aWgg(aGjwb8LDzfXDCW4lfKgdsbF1teQO3eq)jk(KaWxHA544R6eXfts3Wgg(acaRa(YUSI4ooy8LcsJbPGV7(e6OMDXTQZuWGgqhF1giPgg(aWxHA544lvqOIqTC8ck1g(IsTvCbIXx6OMDXnSHHpayXkGVSlRiUJdgFPG0yqk47HNqh1SlUvvZUT1a8Kqp5WtOZG6dCEnHAzVNECHkMOnW0UXval9gp588j9XQjul790JluXeTbM2nU0hRAjnC6Xpz)tc9e6mO(aNx1rqqJx6ciCmsaCfWqs66N08tG9jHEYHN0hR2UjUnqfD6XribKwJkGHK01prXNa7topFYUpXee7wTDtCBGk60JJqciTgv2Lve3FY(NS)jNNp5Wto8e6OMDXTQZuWGgq)jNNpHoQzxCRgUbif)jNNpHoQzxCR6JZpz)tc9e6mO(aNx1rqqJx6ciCmsaCfWqs66N08tG9jHEYHN0hR2UjUnqfD6XribKwJkGHK01prXNa7topFYUpXee7wTDtCBGk60JJqciTgv2Lve3FY(NS)jNNp5WtOJA2f3QEgVzLfHFsONC4j0zq9boVQNiubmwfWsVXtopFsFSQEIqfWyvlPHtp(j7FsONqNb1h48QoccA8sxaHJrcGRagssx)KMFcSpj0to8K(y12nXTbQOtpocjG0AubmKKU(jk(eyFY55t29jMGy3QTBIBdurNECesaP1OYUSI4(t2)K94RqTCC8LkiurOwoEbLAdFrP2kUaX4BxaHJrcGlTaUfBy4diWyfWx2Lve3XbJVuqAmif8LodQpW5vDee04LUachJeaxbmKKU(jk(KLmEZkagssxJVc1YXX3Uacx0tecBy4diqyfWx2Lve3XbJVc1YXXxQGqfHA54fuQn8fLAR4ceJVPXqyddFaWiwb8LDzfXDCW4lfKgdsbF7JvvNiUys6w1sA40JXxHA544lKG4LKwasRfbySHHpavgwb8LDzfXDCW4lfKgdsbF7Jv1teQagRAjnC6Xpj0t29jMGy3Q6bUITXfnZDDLDzfXD8vOwoo(cjiEjPfG0AragBy4dqLJvaFzxwrChhm(sbPXGuW3DFIji2TQ6eXfts3QSlRiUJVc1YXXxibXljTaKwlcWyddFaQeSc4l7YkI74GXxkingKc(QNiurVjG(tu8jbcFfQLJJVqcIxsAbiTweGXgg(a2ryfWx2Lve3XbJVc1YXXxD2UnEbLlm(sbPXGuWxHAPAU0hRQZ2TXlOCHFsZkFsGFsONa4faR3Kve)Kqpz3N0hRQZ2TXlOCHRwsdNEm(sBqrCXeqmBAm8bGnm8WctSc4l7YkI74GXxkingKc(sh1SlUvDMcg0a64R2aj1WWha(kulhhFPccveQLJxqP2WxuQTIlqm(sh1SlUHnm8Wgawb8LDzfXDCW4lfKgdsbFxJwwQPZQttwrCPZqPMRAtOHFIIkFcmcZNCE(K1OLLA6S60Kvex6muQ5Au7tc9KLmEZkagssx)KMFcm(KZZNSgTSutNvNMSI4sNHsnx1Mqd)efv(KadJpj0t6Jv1teQagRAjnC6X4RqTCC8TdK0lOCHXggEyHfRa(kulhhF7aj9IEIq4l7YkI74GXggEydmwb8vOwoo(Q3K(axzDqg(YUSI4ooySHn8vZyfWWhawb8vOwoo(UjrUHVSlRiUJdgBy4HfRa(YUSI4ooy8nDJbGOwRKl4BNxJwwQ6nPpWvyOvGq5Q2eAyfvgy8vOwoo(2bs6f9eHW30ngaIATsmAwfe(ga2WWhySc4RqTCC8vVj9bUY6Gm8LDzfXDCWydB4BAmewbm8bGvaFfQLJJVrAUKgdPXx2Lve3XbJnSHVDbeogjaU0c4wScy4daRa(YUSI4ooy8LcsJbPGV0zq9boVQJGGgV0fq4yKa4kGHK01pP5Nal(kulhhFvNiUys6g2WWdlwb8vOwoo(2fq4IEIq4l7YkI74GXgg(aJvaFfQLJJVTJLJJVSlRiUJdgBy4dewb8vOwoo(UKaEfnthFzxwrChhm2WWdJyfWxHA5447kAMEzjc0aFzxwrChhm2WWRYWkGVc1YXX3vgOzq40JXx2Lve3XbJnm8QCSc4l7YkI74GXxkingKc(U7tOJA2f3QotbdAa9Ne6j0zq9boVQJGGgV0fq4yKa4kGHK01pP5Nal(kulhhFPccveQLJxqP2WxuQTIlqm(sh1SlUHnm8QeSc4RqTCC8vhbbnEPlGWXibW4l7YkI74GXg2Wg(kr22aW3BcTdJnSHXa]] )


end