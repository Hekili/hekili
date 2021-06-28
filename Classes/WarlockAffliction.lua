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

        shadow_embrace = 23139, -- 32388
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
        rapid_contagion = 5386, -- 344566
        rot_and_decay = 16, -- 212371
        shadow_rift = 5392, -- 353294
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
            duration = 16,
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
            duration = 10,
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
                if not talent.shadow_embrace.enabled or not settings.manage_ds_ticks then return nil end
                return class.auras.drain_soul.tick_time
            end,

            start = function ()
                applyDebuff( "target", "drain_soul" )
                applyBuff( "casting", 5 * haste )
                channelSpell( "drain_soul" )
                removeStack( "decimating_bolt" )
                removeBuff( "malefic_wrath" )

                if talent.shadow_embrace.enabled then applyDebuff( "target", "shadow_embrace", nil, debuff.shadow_embrace.stack + 1 ) end
            end,

            tick = function ()
                if not settings.manage_ds_ticks or not talent.shadow_embrace.enabled then return end
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
            end,

            impact = function ()
                if talent.shadow_embrace.enabled then applyDebuff( "target", "shadow_embrace", nil, debuff.shadow_embrace.stack + 1 ) end
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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( level > 57 and 120 or 180 ) end,
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
                },
                -- Legendary
                languishing_soul_detritus = {
                    id = 356255,
                    duration = 8,
                    max_stack = 1,
                },
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
                if legendary.shard_of_annihilation.enabled then
                    applyBuff( "shard_of_annihilation" )
                end
            end,

            auras = {
                decimating_bolt = {
                    id = 325299,
                    duration = 3600,
                    max_stack = 3,
                },
                shard_of_annihilation = {
                    id = 356342,
                    duration = 44,
                    max_stack = 1,
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
                if legendary.decaying_soul_satchel.enabled then
                    applyBuff( "decaying_soul_satchel", nil, active_dot.soul_rot )
                end
            end,

            auras = {
                soul_rot = {
                    id = 325640,
                    duration = 8,
                    max_stack = 1
                },
                decaying_soul_satchel = {
                    id = 356369,
                    duration = 8,
                    max_stack = 4,
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


    spec:RegisterPack( "Affliction", 20210627, [[d8uvMcqiiPwKKOqpcsvTjjPpbPmkqQtbkTkqbPEfiXSOkCljr1Ue6xQKmmvk6yqILrv0ZKezAQu4AqQ02uPu9nivX4af4CuLOSoijnpqs3tcTpqrhesfTqvs9qvkzIQukxKQevBeuqYhLef1jPkbRuLQzcjXnLeL2jvP(jvjsdfsvAPuLqpfktvs4QGcITkjkYxbfuJLQK2RG)QudwvhMYIbXJPYKvYLj2Sk8zjA0QOtlA1uLi8Aq1Sr52qSBs)wQHlPooKkSCGNJQPJCDQQTdv9DvIXdk05LG1ljky(qL7tvIO9R4akHkcylJKG3EEtpr5M3UNONikOh01ZBwPagvOwcy1MdUvkbm1qKag684GLokBnGvBfyTTcveW4TpWjbStIQ5O6vxvM0PpKORrUINi(mJYwDa7GUINiURcyq8tg5f0aKa2Yij4TN30tuU5T7j6jIc6bDrbDrpbmET4cE75TJUbSZCTenajGTeUlGHopoyPJYwNhg2aS2bFUF3xL59e94X8EEtprzUp3V1PPLchvN7v(8OZ1swZJvlm28Os7GhN7v(8OZ1swZFBc(2hmFL1ktxCUx5ZJoxlznpeGyWDNMQcBEwxMU5pAW83gWsDES2NfN7v(8vCrm4ZxznMCKU59Iwn5dK5zDz6MN65V0a4ZNhZxO9rdiZJKCEQLZBZtgtuA(uNNonAEqFjo3R859YvdctM3lAi1MsZJopoyPJYw5ZJEXJENNmMOuCUx5ZxXfXGZNN65n8DUMhcRVKA583MbGxYmGmFQZJ4ZOSYjduk08xUQN)28sRGpVFDCUx5ZFRwxIYL55nIm)Tza4LmdiZJEbs98oJX4Zt98az57K5DnsTpzu268uIiX5ELppMqZZBezENXyBZrzRBwYP5fLaPWNN655eiD08upVHVZ18UtXbp1Y5zjN4ZtNgn)LwrJMhImpqm3PSIZ9kFEVuLvyEmrwZ3QtMVgivETpJfN7v(8OZLxcFonFLri(aD(BDB85HihnqMx0189X8hz5jvzCEwxMU5PEERUMvy(wzfMN65H0C(8hz5jXNhATP5jGXpNV2CW5Wgdy1G(izsad9r)5rNhhS0rzRZddBaw7Gp3rF0F(7(QmVNOhpM3ZB6jkZ95o6J(ZFRttlfoQo3rF0F(kFE05AjR5XQfgBEuPDWJZD0h9NVYNhDUwYA(BtW3(G5RSwz6IZD0h9NVYNhDUwYAEiaXG7onvf28SUmDZF0G5VnGL68yTplo3rF0F(kF(kUig85RSgtos38ErRM8bY8SUmDZt98xAa85ZJ5l0(ObK5rsop1Y5T5jJjknFQZtNgnpOVeN7Op6pFLpVxUAqyY8ErdP2uAE05XblDu2kFE0lE078KXeLIZD0h9NVYNVIlIbNpp1ZB47CnpewFj1Y5VndaVKzaz(uNhXNrzLtgOuO5VCvp)T5LwbFE)64Ch9r)5R85VvRlr5Y88grM)2ma8sMbK5rVaPEENXy85PEEGS8DY8UgP2NmkBDEkrK4Ch9r)5R85XeAEEJiZ7mgBBokBDZsonVOeif(8uppNaPJMN65n8DUM3Dko4Pwopl5eFE60O5V0kA08qK5bI5oLvCUJ(O)8v(8EPkRW8yISMVvNmFnqQ8AFglo3rF0F(kFE05YlHpNMVYieFGo)TUn(8qKJgiZl6A((y(JS8KQmopRlt38upVvxZkmFRScZt98qAoF(JS8K4ZdT208eW4NZxBo4CyJZ95U5OSvESgiUgbIrfpe2E1iPAu2Qh5rrkreyEZQOUwOOXs8svudX)4iwcsKobYUp2CZbYJ0jr)65U5OSvESgiUgbIrqP4vCFeKw31cn3nhLTYJ1aX1iqmckfVQeKiDcKDFS5MdKhPt8ipksgtukwcsKobYUp2CZbYJ0jrrnimzn3nhLTYJ1aX1iqmckfVcVbsdct8qneP4Qj(gi2QGh4nMVu0CuIx2RMIUga8RPSvyEZQMJs8YE1u0kBTamVzvZrjEzVAk6RCYGWKTDCWshLTcZBwfAutgtukYZ6Zw3S8qIIAqyYchoZrjEzVAkYZ6Zw3S8qG5nHTk0RMI1NMsnYMNAPpZajvisPdEQL4WHAYyIsX6ttPgzZtT0NzGKkef1GWKfSZDZrzR8ynqCnceJGsXR85YojbXd1qKIwLb(Pbm((OvA3h76(IaM7MJYw5XAG4AeigbLIxXfzT7JTRba)AkB1dwQY2TkIYn9ipkYRfgBtgOuiEKlYA3hBxda(1u262AbMfR0C3Cu2kpwdexJaXiOu8QtZxP5U5OSvESgiUgbIrqP4v(kNmimzBhhS0rzRZ95o6J(Z7LdJIZNK18cEbuyEkrK5PtzEZrny(KpVH3sMbHjX5U5OSvErETWyBw7Gp3nhLTYHsXRwc(2hSrSY0n3nhLTYHsXRCgJTnhLTUzjN8qnePO1IhCcKoQikEKhfnhL4LTOcskCywP5o6pp60rzRZZsoXN)ObZtGuHl08qKtdF2G48yKr85nGmp3WlR5pAW8qKJgiZJ1(S59InDLxaPw0vQLZFlJmob66t5k07PPuJmpwQL(mdKubpMVPtbCj5Y8ToVRB2QVOZDZrzRCOu8kNXyBZrzRBwYjpudrksGuHl0MxZsA7ofhCp4eiDuru8ipksjIavuM7MJYw5qP4voJX2MJYw3SKtEOgIuCjmRGS2eiv4cXN7MJYw5qP4voJX2MJYw3SKtEOgIuKtgTjqQWfI7bNaPJkIIh5rrOxnf5TpBdAksPdEQL4WTAkMi1IUsTC7mY4eORpL9QPiLo4PwId3QPy9PPuJS5Pw6ZmqsfIu6GNAjSv5TpBZpnWcMvchUvtr8jt2KLkfP0bp1sC4iJjkf59LnDkBUil(C3Cu2khkfVYzm22Cu26MLCYd1qKIldXkLnbsfUqCp4eiDuru8ipk6A8IAkf1S8K2hMufAuJ3aPbHjrcKkCH28Aws4W56MT6lAK3(SnOPiqqSu5W0ZBIdh04nqAqysKaPcxODRsvx3SvFrJ82NTbnfbcILkhQeiv4cfrj66MT6lAeiiwQCyXHdA8ginimjsGuHl0MU0vDDZw9fnYBF2g0ueiiwQCOsGuHlu0ZORB2QVOrGGyPYHf25U5OSvoukELZyST5OS1nl5KhQHifxgIvkBcKkCH4EWjq6OIO4rEu014f1ukIxu6SaOk0OgVbsdctIeiv4cT51SKWHZ1nB1x0yIul6k1YTZiJtGU(uIabXsLdtpVjoCqJ3aPbHjrcKkCH2TkvDDZw9fnMi1IUsTC7mY4eORpLiqqSu5qLaPcxOikrx3SvFrJabXsLdloCqJ3aPbHjrcKkCH20LUQRB2QVOXePw0vQLBNrgNaD9PebcILkhQeiv4cf9m66MT6lAeiiwQCyHDUBokBLdLIx5mgBBokBDZso5HAisXLHyLYMaPcxiUhCcKoQikEKhfH214f1ukQId0SgSWHZ14f1ukcVainfhoxJxutPO2QaBvOrnEdKgeMejqQWfAZRzjHdNRB2QVOX6ttPgzZtT0NzGKkebcILkhMEEtC4GgVbsdctIeiv4cTBvQ66MT6lAS(0uQr28ul9zgiPcrGGyPYHkbsfUqruIUUzR(IgbcILkhwC4GgVbsdctIeiv4cTPlDvx3SvFrJ1NMsnYMNAPpZajviceelvoujqQWfk6z01nB1x0iqqSu5Wc7C3Cu2khkfVYzm22Cu26MLCYd1qKIldXkLnbsfUqCp4eiDuru8ipkIAYyIsX6ttPgzZtT0NzGKkef1GWKvvOrnEdKgeMejqQWfAZRzjHdNRB2QVOrUpcsR7LbGxYmGebcILkhMEEtC4GgVbsdctIeiv4cTBvQ66MT6lAK7JG06Eza4LmdirGGyPYHkbsfUqruIUUzR(IgbcILkhwC4GgVbsdctIeiv4cTPlDvx3SvFrJCFeKw3ldaVKzajceelvoujqQWfk6z01nB1x0iqqSu5Wc7Ch9N)AFGopV9zZZpnWIpFEm)rwEsZN85ngsZP5B8cyUBokBLdLIxHym5iDBGvt(aXJ8OiKMZREKLN0giiwQCOkWO48jztjIadnV9zB(Pbwvxnf9vozqyY2ooyPJYwJu6GNA5Ch9N3lCmVRXlQP08RMUc9EAk1iZJLAPpZajvy(KppWx1ul9yEFUm)Tza4LmdiZt98cmsIUMNoL5D(aGO08CHM7MJYw5qP4voJX2MJYw3SKtEOgIuCza4Lmdi7AGu7rEueAxJxutPiErPZcGQRMIjsTORul3oJmob66tzVAksPdEQLvDDZw9fnY9rqADVma8sMbKiqqSu5q1ZQqVAkwFAk1iBEQL(mdKuHiqqSu5W0tC4qnzmrPy9PPuJS5Pw6ZmqsfGfwC4G214f1ukQz5jTpmP6QPiV9zBqtrkDWtTSQRB2QVOrUpcsR7LbGxYmGebcILkhQEwf6vtX6ttPgzZtT0NzGKkebcILkhMEIdhQjJjkfRpnLAKnp1sFMbsQaSWIdh0q7A8IAkfvXbAwdw4W5A8IAkfHxaKMIdNRXlQPuuBvGT6QPy9PPuJS5Pw6ZmqsfIu6GNAz1vtX6ttPgzZtT0NzGKkebcILkhQEc7Ch9N3lkhaHFo)Qj(8IbyfMppMVStTC(uPEEBE(PbwZZRfDLA581NgxM7MJYw5qP4voJX2MJYw3SKtEOgIuC10Ugi1EKhfH214f1ukQz5jTpmPkQxnf5TpBdAksPdEQLvDDZw9fnYBF2g0ueiiwQCOEdyXHdAxJxutPiErPZcGQOE1umrQfDLA52zKXjqxFk7vtrkDWtTSQRB2QVOXePw0vQLBNrgNaD9PebcILkhQ3awC4GgAxJxutPOkoqZAWchoxJxutPi8cG0uC4CnErnLIARcSvjJjkfRpnLAKnp1sFMbsQqvuVAkwFAk1iBEQL(mdKuHiLo4Pww11nB1x0y9PPuJS5Pw6ZmqsfIabXsLd1Ba7Ch9N3lCmp690uQrMhl1sFMbsQW8jFEkDWtT0J5tA(Kpp3oK5PEEFUm)Tza4ZJ1(S5U5OSvoukE1YaW382N5rEuC1uS(0uQr28ul9zgiPcrkDWtTCUBokBLdLIxTma8nV9zEKhfrnzmrPy9PPuJS5Pw6ZmqsfQc9QPiV9zBqtrkDWtTehUvtXePw0vQLBNrgNaD9PSxnfP0bp1syN7O)8yfu38O3ttPgzESul9zgiPcZFjPZ5RmjkDwaCL3z5jnpmuMmVRXlQP08RM8y(MofWLKlZ7ZL5BDEx3SvFrJZ7foM3lhPUaqm28EPGLAQtMhI)XX8jF(uDnsQLEm)zZwZ7RuYMpj04ZdeBvyEOrbgmpxCTU4ZBhKaM3NlWo3nhLTYHsXRQpnLAKnp1sFMbsQGh5rrxJxutPOMLN0(WKQuIiWeDR66MT6lAK3(SnOPiqqSu5qfLQqtGuHluuqQlaeJTBWsn1jrx3SvFrJabXsLdvuUDpXHd1c6WpRRLvuqQlaeJTBWsn1jWo3nhLTYHsXRQpnLAKnp1sFMbsQGh5rrxJxutPiErPZcGQuIiWeDR66MT6lAmrQfDLA52zKXjqxFkrGGyPYHkkvHMaPcxOOGuxaigB3GLAQtIUUzR(IgbcILkhQOC7EIdhQf0HFwxlROGuxaigB3GLAQtGDUBokBLdLIxvFAk1iBEQL(mdKubpYJIq7A8IAkfvXbAwdw4W5A8IAkfHxaKMIdNRXlQPuuBvGTk0eiv4cffK6caXy7gSutDs01nB1x0iqqSu5qfLB3tC4qTGo8Z6AzffK6caXy7gSutDcSZDZrzRCOu8Q6ttPgzZtT0NzGKk4rEuesZ5vpYYtAdeelvour52N7O)8EHJ5rVNMsnY8yPw6ZmqsfMp5ZtPdEQLEmFsOXNNsezEQN3NlZ30PaMhX8s0G5xnXN7MJYw5qP4voJX2MJYw3SKtEOgIu014f1uYJ8O4QPy9PPuJS5Pw6ZmqsfIu6GNAzvODnErnLIAwEs7dtWHZ14f1ukIxu6Saa25U5OSvoukELv2AbpCfCmztgOuiEru8ipkUAkALTwiceelvouVXC3Cu2khkfV608vAUJ(ZJ1xMNoL5XezXNV15R08KbkfIpFEmFsZNCfnAENpaikXkmFQZFWYYtA(gmFRZtNY8KbkfkopmCsNZJL1NTopQKhY8jHgFEJX75HiejG5PEEFUmpMiR5B8cyEet9ngRW8wDnRqQLZxP5Vvda(1u2kpo3nhLTYHsXR4IS29X21aGFnLT6rEu0CuIx2IkiPWHPNvjJjkf59LnDkBUilEvuVAkYfzT7JTRba)AkBnsPdEQLvrDQ7dwwEsZDZrzRCOu8kUiRDFSDna4xtzREKhfnhL4LTOcskCy6zvYyIsrEwF26MLhsvuVAkYfzT7JTRba)AkBnsPdEQLvrDQ7dwwEsvxnfDna4xtzRrGGyPYH6nM7MJYw5qP4v4tMSjlvYJ8Oi082NT5NgybtuWHZCuIx2IkiPWHPNWw11nB1x0i3hbP19YaWlzgqIabXsLdtu8CUBokBLdLIx5RCYGWKTDCWshLT6rEu0CuIx2RMI(kNmimzBhhS0rzRfVjoCu6GNAz1vtrFLtgeMSTJdw6OS1iqqSu5q9gZDZrzRCOu8kEwF26MLhIhUcoMSjdukeVikEKhfxnf5z9zRBwEirGGyPYH6nM7MJYw5qP4voJX2MJYw3SKtEOgIu014f1uYdobshvefpYJIO214f1ukQId0SgSM7O)8OZ6AwH5Vvda(1u268iM6BmwH5BDEuQCpNNmqPqCpMVbZ368vA(ljDop6ecVz(Km)TAaWVMYwN7MJYw5qP4vUga8RPSvpCfCmztgOuiEru8ipkAokXlBrfKu4q9gvo0KXeLI8(YMoLnxKfhhoYyIsrEwF26MLhcSvxnfDna4xtzRrGGyPYHQNZD0FE05bjG5Ptz(Uwub4X88ArxZBZZpnWA(lNIoVrZJUZ368vwJjhPBEVOvt(azEQN3W35A(gVaCwDDQLZDZrzRCOu8keJjhPBdSAYhiEKhf5TpBZpnWcM3OkLicm9eL5o6ppm8POZRnnpVG6sTCE07PPuJmpwQL(mdKuH5PE(ktIsNfax5DwEsZddLjEmpMpcsRZFBgaEjZaY85X8gJn)Qj(8gqM3QRzPSM7MJYw5qP4voJX2MJYw3SKtEOgIuCza4Lmdi7AGu7rEueAxJxutPiErPZcGQOMmMOuS(0uQr28ul9zgiPcvxnftKArxPwUDgzCc01NYE1uKsh8ulR66MT6lAK7JG06Eza4LmdirGyRcWIdh0UgVOMsrnlpP9HjvrnzmrPy9PPuJS5Pw6ZmqsfQUAkYBF2g0uKsh8ulR66MT6lAK7JG06Eza4LmdirGyRcWIdh0q7A8IAkfvXbAwdw4W5A8IAkfHxaKMIdNRXlQPuuBvGTQRB2QVOrUpcsR7LbGxYmGebITka7Ch9NhgcxM)2ma85XAF285X83MbGxYmGm)LwrJMhImpqSvH5TslvpMVbZNhZtNcqM)sYyZdrM3O5zIXP59CEKgiZFBgaEjZaY8(CHp3nhLTYHsXRwga(M3(mpYJIqAoVQRB2QVOrUpcsR7LbGxYmGebcILkhMhz5jTbcILkVk0OMmMOuS(0uQr28ul9zgiPc4W56MT6lAS(0uQr28ul9zgiPcrGGyPYH5rwEsBGGyPYHDUBokBLdLIxTma8nV9zEKhfH0CEvutgtukwFAk1iBEQL(mdKuHQUUzR(Ig5(iiTUxgaEjZaseiiwQCO46MT6lAK7JG06Eza4LmdiXLpWOSvOEKLN0giiwQ85o6p)TmYDw5gJnFscY8(CRuM)ObZBAb6m1Y51MMNxlU8iL18cJlxofGm3nhLTYHsXRCgJTnhLTUzjN8qnePyscYCh9r)59IYbq4NZJDAR(Y8E5iqaMtMhIC0azEETORulNNFAGfF(wNVYAm5iDZ7fTAYhiZDZrzRCOu8kNXyBZrzRBwYjpudrkYfpYJImbVWGj6IEQc9sG4FCe5N2QVSfeiaZjrozo4qfApRCZrzRr(PT6lBinJIPUpyz5jbloClbI)XrKFAR(YwqGamNebcILkhQvc25o6ppmeUmFL1yYr6M3lA1KpqM)YPOZJyEjAW8RM4ZBazE)ApMVbZNhZtNcqM)sYyZdrMNNLAEKotP5PerM3xPKnpDkZRcmsZJEpnLAK5XsT0NzGKkeN3lCmVpLSSYqQLZxznMCKU5HHbgD6X8NnBnVnp)0aR5PEEGCae(580Pmpe)JJ5U5OSvoukEfIXKJ0Tbwn5depYJIqVAkIpzYMSuPiLo4PwId3QPyIul6k1YTZiJtGU(u2RMIu6GNAjoCRMI82NTbnfP0bp1syRcnQb(QC0GsjIym5iD7laJoXHdI)XreXyYr62xagDg5K5Gd1kHdhV9zB(PbwWefyN7O)8Wq4Y8vwJjhPBEVOvt(azEQNhXsLSuNNoL5rmMCKU5Vam6CEi(hhZ7RuYMNFAGfFEvK18uppez(srfGrYA(JgmpDkZRcmsZdXhWP5VK6QVmp0EEZ55IR1fF(KppsdK5PttNN7FCKUuuAEQNVuubyKmFLMNFAGfh25U5OSvoukEfIXKJ0Tbwn5depYJIaFvoAqPermMCKU9fGrNvDDZw9fnYBF2g0ueiiwQCy65nRcX)4iIym5iD7laJoJabXsLd1Bm3r)5HHWL5RSgtos38ErRM8bY8Top690uQrMhl1sFMbsQW8oJtCpMhXGNA58CFGmp1ZZn8Y8288tdSMN655K5GpFL1yYr6Mhggy0585X8(8ulNpP5U5OSvoukEfIXKJ0Tbwn5depYJIKXeLI1NMsnYMNAPpZajvOk0RMI1NMsnYMNAPpZajvisPdEQL4W56MT6lAS(0uQr28ul9zgiPcrGGyPYHPNOloCqAoVkLiYM69kfO66MT6lAS(0uQr28ul9zgiPcrGGyPYHTk0Og4RYrdkLiIXKJ0TVam6ehoi(hhreJjhPBFby0zKtMdouReoC82NT5NgybtuGDUJ(ZFBal15rL8qMp5Z3kRW8283g6fB(sl15VK058EbvWNKbHjZFBcsYL5vXaZJyW48CYCW5X59chZFKLN08jFEds7tZt98IUMF1ZRnnpsY5ZZRfDLA580PmpNmhC(C3Cu2khkfVAbSu3S8q8ipkcX)4iMQGpjdct2lbj5sKtMdomVXnXHdI)XrmvbFsgeMSxcsYLOFDvinNx9ilpPnqqSu5q9gZDZrzRCOu8kNXyBZrzRBwYjpudrk6A8IAkn3nhLTYHsXRSYwl4HRGJjBYaLcXlIIh5rrGCae(PbHjZDZrzRCOu8kFLtgeMSTJdw6OSvpYJIMJs8YE1u0x5KbHjB74GLokBT4nXHJsh8ulRcKdGWpnimzUBokBLdLIxXZ6Zw3S8q8WvWXKnzGsH4frXJ8Oiqoac)0GWK5U5OSvoukELRba)AkB1dxbht2KbkfIxefpYJIa5ai8tdctQAokXlBrfKu4q9gvo0KXeLI8(YMoLnxKfhhoYyIsrEwF26MLhcSZDZrzRCOu8QfWsDZBFMhPsca4xtfrzUBokBLdLIxXpTvFzdPz0CFUBokBLhTwkwFAk1iBEQL(mdKuH5U5OSvE0AbkfV608vAUBokBLhTwGsXRCgJTnhLTUzjN8qneP4YaWlzgq21aP2J8Oi0UgVOMsr8IsNfavxnftKArxPwUDgzCc01NYE1uKsh8ulR66MT6lAK7JG06Eza4LmdirGyRcvHE1uS(0uQr28ul9zgiPcrGGyPYHPN4WHAYyIsX6ttPgzZtT0NzGKkalS4WbTRXlQPuuZYtAFys1vtrE7Z2GMIu6GNAzvx3SvFrJCFeKw3ldaVKzajceBvOk0RMI1NMsnYMNAPpZajviceelvom9ehoutgtukwFAk1iBEQL(mdKubyHTk0q7A8IAkfvXbAwdw4W5A8IAkfHxaKMIdNRXlQPuuBvGT6QPy9PPuJS5Pw6ZmqsfIu6GNAz1vtX6ttPgzZtT0NzGKkebcILkhQEc7C3Cu2kpATaLIxXfzT7JTRba)AkB1J8OizmrPiVVSPtzZfzXR6mDZfzn3nhLTYJwlqP4vCrw7(y7AaWVMYw9ipkIAYyIsrEFztNYMlYIxf1RMICrw7(y7AaWVMYwJu6GNAzvuN6(GLLNu1vtrxda(1u2AeihaHFAqyYC3Cu2kpATaLIxzLTwWdxbht2KbkfIxefpYJIMJs8YE1u0kBTauVrvGCae(PbHjZDZrzR8O1cukELv2AbpCfCmztgOuiEru8ipkAokXl7vtrRS1cWS4nQcKdGWpnimP6QPOv2AHiLo4Pwo3nhLTYJwlqP4v(kNmimzBhhS0rzREKhfnhL4L9QPOVYjdct22XblDu2AXBIdhLo4PwwfihaHFAqyYC3Cu2kpATaLIx5RCYGWKTDCWshLT6HRGJjBYaLcXlIIh5rrutPdEQLvRXxtgtukcmKAtPTDCWshLTYJIAqyYQQ5OeVSxnf9vozqyY2ooyPJYwHALM7MJYw5rRfOu8k8jt2KLk5rEuK3(Sn)0alyIYC3Cu2kpATaLIx5mgBBokBDZso5HAisrxJxutjp4eiDuru8ipkIAxJxutPOkoqZAWAUBokBLhTwGsXRCgJTnhLTUzjN8qneP4YaWlzgq21aP2J8Oi0UgVOMsr8IsNfavH21nB1x0yIul6k1YTZiJtGU(uIaXwfWHB1umrQfDLA52zKXjqxFk7vtrkDWtTe2QUUzR(Ig5(iiTUxgaEjZasei2QqvOxnfRpnLAKnp1sFMbsQqeiiwQCy6joCOMmMOuS(0uQr28ul9zgiPcWcBvOH214f1ukQId0SgSWHZ14f1ukcVainfhoxJxutPO2QaBvx3SvFrJCFeKw3ldaVKzajceelvou9Sk0RMI1NMsnYMNAPpZajviceelvom9ehoutgtukwFAk1iBEQL(mdKubyHfhoODnErnLIAwEs7dtQcTRB2QVOrE7Z2GMIaXwfWHB1uK3(SnOPiLo4PwcBvx3SvFrJCFeKw3ldaVKzajceelvou9Sk0RMI1NMsnYMNAPpZajviceelvom9ehoutgtukwFAk1iBEQL(mdKubyHDUBokBLhTwGsXRwga(M3(mpYJIqAoVQRB2QVOrUpcsR7LbGxYmGebcILkhMhz5jTbcILkVk0OMmMOuS(0uQr28ul9zgiPc4W56MT6lAS(0uQr28ul9zgiPcrGGyPYH5rwEsBGGyPYHDUBokBLhTwGsXRwga(M3(mpYJIqAoVQRB2QVOrUpcsR7LbGxYmGebcILkhkUUzR(Ig5(iiTUxgaEjZasC5dmkBfQhz5jTbcILkFUBokBLhTwGsXRCgJTnhLTUzjN8qnePyscYC3Cu2kpATaLIx5mgBBokBDZso5HAisXLWScYAtGuHleFUBokBLhTwGsXRCgJTnhLTUzjN8qneP4YqSsztGuHleFUBokBLhTwGsXRCgJTnhLTUzjN8qnePiNmAtGuHle3J8O4QPy9PPuJS5Pw6ZmqsfIu6GNAjoCOMmMOuS(0uQr28ul9zgiPcZDZrzR8O1cukEfIXKJ0Tbwn5depYJIRMI4tMSjlvksPdEQLZDZrzR8O1cukEfIXKJ0Tbwn5depYJIRMI82NTbnfP0bp1YQOMmMOuK3x20PS5IS4ZDZrzR8O1cukEfIXKJ0Tbwn5depYJIOMmMOueFYKnzPsZDZrzR8O1cukEfIXKJ0Tbwn5depYJI82NT5NgybZBm3nhLTYJwlqP4v8S(S1nlpepCfCmztgOuiEru8ipkAokXl7vtrEwF26MLhculwPQa5ai8tdctQI6vtrEwF26MLhsKsh8ulN7MJYw5rRfOu8kNXyBZrzRBwYjpudrk6A8IAk5bNaPJkIIh5rrxJxutPOkoqZAWAUBokBLhTwGsXRwal1nlpepYJIq8poIPk4tYGWK9sqsUe5K5GdZIO7nXHdsZ5vH4FCetvWNKbHj7LGKCj6xx9ilpPnqqSu5qfDXHdI)XrmvbFsgeMSxcsYLiNmhCywSsOB1vtrE7Z2GMIu6GNA5C3Cu2kpATaLIxTawQBE7Z8ivsaa)AQikZDZrzR8O1cukEf)0w9LnKMrZ95U5OSvE014f1uQyIul6k1YTZiJtGU(u8ipkIAYyIsX6ttPgzZtT0NzGKkufAx3SvFrJCFeKw3ldaVKzajceelvour5M4W56MT6lAK7JG06Eza4LmdirGGyPYHj6EZQUUzR(Ig5(iiTUxgaEjZaseiiwQCy6j6w116YpPORba)Ak1YnteaSZDZrzR8ORXlQPeukEvIul6k1YTZiJtGU(u8ipksgtukwFAk1iBEQL(mdKuHQRMI1NMsnYMNAPpZajvisPdEQLZDZrzR8ORXlQPeukE1sCjIrPwUH0mYJ8OORB2QVOrUpcsR7LbGxYmGebcILkhMOBvOxce)JJ4P5RueiiwQCyEdC4qnzmrP4P5ReSZDZrzR8ORXlQPeukEfV9zBqtEKhfrnzmrPy9PPuJS5Pw6ZmqsfQcTRB2QVOrUpcsR7LbGxYmGebcILkhQOloCUUzR(Ig5(iiTUxgaEjZaseiiwQCyIU3ehox3SvFrJCFeKw3ldaVKzajceelvom9eDR6AD5Nu01aGFnLA5Mjca25U5OSvE014f1uckfVI3(SnOjpYJIKXeLI1NMsnYMNAPpZajvO6QPy9PPuJS5Pw6ZmqsfIu6GNA5C3Cu2kp6A8IAkbLIxXDTpi1YnL0Pm3N7MJYw5XLHyLYMaPcxiErFUStsq8qnePiV9z7SutsaZDZrzR84YqSsztGuHlehkfVYNl7KeepudrkUaITosGSXlCUWM7MJYw5XLHyLYMaPcxioukELpx2jjiEOgIuSKvO(C3hBJZtKKzu26CFUBokBLhxgaEjZaYUgi1fXNmztwQ0C3Cu2kpUma8sMbKDnqQHsXRwga(M3(S5U5OSvECza4Lmdi7AGudLIxv3u26C3Cu2kpUma8sMbKDnqQHsXRosGaH19AUBokBLhxgaEjZaYUgi1qP4vqyDV2h(GcZDZrzR84YaWlzgq21aPgkfVcIa4caEQLZDZrzR84YaWlzgq21aPgkfVYzm22Cu26MLCYd1qKIUgVOMsEKhfrTRXlQPuufhOznyn3nhLTYJldaVKzazxdKAOu8kUpcsR7LbGxYmGm3N7MJYw5XLWScYAtGuHleVOpx2jjiEOgIuuqQlaeJTBWsn1jEKhfH214f1ukQz5jTpmPQRB2QVOrE7Z2GMIabXsLdvpVjS4WbTRXlQPueVO0zbqvx3SvFrJjsTORul3oJmob66tjceelvou98MWIdh0UgVOMsrvCGM1GfoCUgVOMsr4faPP4W5A8IAkf1wfyN7MJYw5XLWScYAtGuHlehkfVYNl7KeepudrkY9viSUxBdrOZcCYJ8Oi0UgVOMsrnlpP9HjvDDZw9fnYBF2g0ueiiwQCOE7WIdh0UgVOMsr8IsNfavDDZw9fnMi1IUsTC7mY4eORpLiqqSu5q92HfhoODnErnLIQ4anRblC4CnErnLIWlastXHZ14f1ukQTkWo3nhLTYJlHzfK1MaPcxioukELpx2jjiEOgIuK3(mMquQLBGpKcEKhfH214f1ukQz5jTpmPQRB2QVOrE7Z2GMIabXsLdvyaS4WbTRXlQPueVO0zbqvx3SvFrJjsTORul3oJmob66tjceelvouHbWIdh0UgVOMsrvCGM1GfoCUgVOMsr4faPP4W5A8IAkf1wfyN7ZDZrzR84QPDnqQlALTwWJ8O4QPOv2AHiqqSu5qfgu11nB1x0i3hbP19YaWlzgqIabXsLdZvtrRS1crGGyPYN7MJYw5Xvt7AGudLIxXZ6Zw3S8q8ipkUAkYZ6Zw3S8qIabXsLdvyqvx3SvFrJCFeKw3ldaVKzajceelvomxnf5z9zRBwEirGGyPYN7MJYw5Xvt7AGudLIx5RCYGWKTDCWshLT6rEuC1u0x5KbHjB74GLokBnceelvouHbvDDZw9fnY9rqADVma8sMbKiqqSu5WC1u0x5KbHjB74GLokBnceelv(C3Cu2kpUAAxdKAOu8kxda(1u2Qh5rXvtrxda(1u2AeiiwQCOcdQ66MT6lAK7JG06Eza4LmdirGGyPYH5QPORba)AkBnceelv(CFUBokBLhtsqk6ZLDsccFUp3nhLTYJCP4P5R0C3Cu2kpYfOu8QfWsDZBFMhPsca4xt7swdXyfrXJujba8RPDEuCjq8poI8tB1x2cceG5KiNmhCywSsZDZrzR8ixGsXR4N2QVSH0mAUp3nhLTYJCYOnbsfUq8I(CzNKG4HAisXu5oGpzqyYgD4Bk5JSxc(0jZDZrzR8iNmAtGuHlehkfVYNl7KeepudrkMkNa(oQb89kXNQSHim2C3Cu2kpYjJ2eiv4cXHsXR85YojbXd1qKInEbCW6lPwUnnrSTZkL5U5OSvEKtgTjqQWfIdLIx5ZLDscIhQHifxgaos36Ejo47AFciCNOozUBokBLh5KrBcKkCH4qP4v(CzNKG4HAisreZzqaYMFkcTr85PBUBokBLh5KrBcKkCH4qP4v(CzNKG4HAisXdMHi7(ydXiIjZDZrzR8iNmAtGuHlehkfVYNl7KeepudrkEXGlQa47dqRR5U5OSvEKtgTjqQWfIdLIx5ZLDscIhQHifjdctODFSxcV2sWC3Cu2kpYjJ2eiv4cXHsXR85YojbXd1qKI8up8zBJxNatj(gITkLDFSpeq7sQWC3Cu2kpYjJ2eiv4cXHsXR85YojbXd1qKI8up8z7sMTsJAaFdXwLYUp2hcODjvyUBokBLh5KrBcKkCH4qP4vqyDV2h(GcZDZrzR8iNmAtGuHlehkfV6ibcew3R5U5OSvEKtgTjqQWfIdLIxbraCbap1Y5(C3Cu2kpsGuHl0MxZsA7ofh8I4nqAqyIhQHif51Iln2wqh(zDTS8aVX8LIqdn0c6WpRRLvuqQlaeJTBWsn1jJxsbD4N11YkMk3b8jdct2OdFtjFK9sWNob2XlPGo8Z6Azf5TpJjeLA5g4dPaSJxsbD4N11YkY9viSUxBdrOZcCc25U5OSvEKaPcxOnVML02Dko4qP4v4nqAqyIhQHifjqQWfA3Q4bEJ5lfHMaPcxOikXtJVRbTRkbsfUqruINgF76MT6lkSZDZrzR8ibsfUqBEnlPT7uCWHsXRWBG0GWepudrksGuHl0MU0EG3y(srOjqQWfk6z8047Aq7QsGuHlu0Z4PX3UUzR(Ic7C3Cu2kpsGuHl0MxZsA7ofhCOu8k8ginimXd1qKIldXkLnbsfUqEG3y(srOrn0eiv4cfrjEA8DnODvjqQWfkIs804Bx3SvFrHfwC4Gg1qtGuHlu0Z4PX31G2vLaPcxOONXtJVDDZw9ffwyXHtqh(zDTSILSc1N7(yBCEIKmJYwN7MJYw5rcKkCH28AwsB3P4GdLIxH3aPbHjEOgIuKaPcxOnVMLKh4nMVueA8ginimjsGuHl0UvPkEdKgeMexgIvkBcKkCHGfhoOXBG0GWKibsfUqB6sxfVbsdctIldXkLnbsfUqWIdh04nqAqysKaPcxODRY4LeVbsdctI8AXLgBlOd)SUwwWIdh04nqAqysKaPcxOnDPhVK4nqAqysKxlU0yBbD4N11Yc2agEbWZwdE75n9eLBIUEIEcyxmGMAjpGbdJo9IE7f8UYmQo)8vCkZNi1nGM)ObZJgbsfUqBEnlPT7uCWrBEGGo8tGSMN3iY8Mp1igjR5DNMwk84ChvsvM3tuD(B1kEbqYAE0iqQWfkIs0ROnp1ZJgbsfUqrcLOxrBEO9egHno3rLuL5ReQo)TAfVaiznpAeiv4cf9m6v0MN65rJaPcxOi5z0ROnp0EcJWgN7OsQY83avN)wTIxaKSMhncKkCHIOe9kAZt98OrGuHluKqj6v0MhApHryJZDujvz(BGQZFRwXlaswZJgbsfUqrpJEfT5PEE0iqQWfksEg9kAZdTNWiSX5(ChggD6f92l4DLzuD(5R4uMprQBan)rdMhnxJxutj0MhiOd)eiR55nImV5tnIrYAE3PPLcpo3rLuL5rbvN)wTIxaKSMhnYyIsrVI28uppAKXeLIEnkQbHjl0MhAuGryJZDujvzEuq15VvR4fajR5rZ16YpPOxrBEQNhnxRl)KIEnkQbHjl0MhAuGryJZDujvzEpr15VvR4fajR5rJmMOu0ROnp1ZJgzmrPOxJIAqyYcT5Hgfye24ChvsvMVsO683Qv8cGK18Orgtuk6v0MN65rJmMOu0RrrnimzH28qJcmcBCUJkPkZFduD(B1kEbqYAE0iJjkf9kAZt98Orgtuk61OOgeMSqBEOrbgHno3rLuL5VbQo)TAfVaiznpAUwx(jf9kAZt98O5AD5Nu0RrrnimzH28qJcmcBCUJkPkZJUO683Qv8cGK18Orgtuk6v0MN65rJmMOu0RrrnimzH28qJcmcBCUp3HHrNErV9cExzgvNF(koL5tK6gqZF0G5rBjhMpJqBEGGo8tGSMN3iY8Mp1igjR5DNMwk84ChvsvM)2r15VvR4fajR5rJmMOu0ROnp1ZJgzmrPOxJIAqyYcT5nAEVCVuuzEOrbgHno3rLuL5rpO683Qv8cGK18OrGuHlueLOxrBEQNhncKkCHIekrVI28qJcmcBCUJkPkZJEq15VvR4fajR5rJaPcxOONrVI28uppAeiv4cfjpJEfT5Hgfye24ChvsvMhgGQZFRwXlaswZJgbsfUqruIEfT5PEE0iqQWfksOe9kAZdnkWiSX5oQKQmpmavN)wTIxaKSMhncKkCHIEg9kAZt98OrGuHluK8m6v0MhAuGryJZDujvzEVmuD(B1kEbqYAE0iqQWfkIs0ROnp1ZJgbsfUqrcLOxrBEOrbgHno3rLuL59Yq15VvR4fajR5rJaPcxOONrVI28uppAeiv4cfjpJEfT5Hgfye24ChvsvMhLBIQZFRwXlaswZJgbsfUqruIEfT5PEE0iqQWfksOe9kAZdnkWiSX5oQKQmpk3evN)wTIxaKSMhncKkCHIEg9kAZt98OrGuHluK8m6v0MhAuGryJZDujvzEu8evN)wTIxaKSMhnYyIsrVI28uppAKXeLIEnkQbHjl0MhApHryJZDujvzEuQeQo)TAfVaiznpAKXeLIEfT5PEE0iJjkf9AuudctwOnp0OaJWgN7OsQY8OGUO683Qv8cGK18Orgtuk6v0MN65rJmMOu0RrrnimzH28qJcmcBCUJkPkZJYTJQZFRwXlaswZJgbsfUqrdIl66MT6lkAZt98O56MT6lA0G4qBEOrbgHno3rLuL5rb9GQZFRwXlaswZJgbsfUqrdIl66MT6lkAZt98O56MT6lA0G4qBEOrbgHno3rLuL5rbgGQZFRwXlaswZJgbsfUqrdIl66MT6lkAZt98O56MT6lA0G4qBEOrbgHno3rLuL59SsO683Qv8cGK18Orgtuk6v0MN65rJmMOu0RrrnimzH28qJcmcBCUJkPkZ75nq15VvR4fajR5rJmMOu0ROnp1ZJgzmrPOxJIAqyYcT5Hgfye24ChvsvM3tVmuD(B1kEbqYAE0iJjkf9kAZt98Orgtuk61OOgeMSqBEO9egHno3rLuL5RekO683Qv8cGK18Orgtuk6v0MN65rJmMOu0RrrnimzH28q7jmcBCUJkPkZxjpr15VvR4fajR5rJmMOu0ROnp1ZJgzmrPOxJIAqyYcT5Hgfye24ChvsvMVsvcvN)wTIxaKSMhnYyIsrVI28uppAKXeLIEnkQbHjl0MhAuGryJZDujvz(kD7O683Qv8cGK18Ob8v5ObLs0ROnp1ZJgWxLJgukrVgf1GWKfAZdnkWiSX5oQKQmFLqpO683Qv8cGK18Ob8v5ObLs0ROnp1ZJgWxLJgukrVgf1GWKfAZdnkWiSX5oQKQmFLGbO683Qv8cGK18Orgtuk6v0MN65rJmMOu0RrrnimzH28qJcmcBCUJkPkZxjyaQo)TAfVaiznpAaFvoAqPe9kAZt98Ob8v5ObLs0RrrnimzH28qJcmcBCUJkPkZFJBGQZFRwXlaswZJgzmrPOxrBEQNhnYyIsrVgf1GWKfAZdTNWiSX5(ChggD6f92l4DLzuD(5R4uMprQBan)rdMhnRf0MhiOd)eiR55nImV5tnIrYAE3PPLcpo3rLuL5ReQo)TAfVaiznpAKXeLIEfT5PEE0iJjkf9AuudctwOnp0EcJWgN7OsQY83avN)wTIxaKSMhnYyIsrVI28uppAKXeLIEnkQbHjl0MhAuGryJZDujvzE0fvN)wTIxaKSMhnYyIsrVI28uppAKXeLIEnkQbHjl0MhAuGryJZDujvzEu8evN)wTIxaKSMhnYyIsrVI28uppAKXeLIEnkQbHjl0Mh6kbJWgN7OsQY8OujuD(B1kEbqYAE0iJjkf9kAZt98Orgtuk61OOgeMSqBEOrbgHno3rLuL5rbgGQZFRwXlaswZJgzmrPOxrBEQNhnYyIsrVgf1GWKfAZB08E5EPOY8qJcmcBCUJkPkZ75nr15VvR4fajR5rJmMOu0ROnp1ZJgzmrPOxJIAqyYcT5nAEVCVuuzEOrbgHno3rLuL59efuD(B1kEbqYAE0iJjkf9kAZt98Orgtuk61OOgeMSqBEJM3l3lfvMhAuGryJZ95UxaPUbKSMhfpN3Cu268SKt84CpGXsoXdveWwgaEjZaYUgi1HkcEJsOIaM5OS1ag(KjBYsLcyIAqyYkCDGcE7zOIaM5OS1a2YaW382NfWe1GWKv46af8UsHkcyMJYwdy1nLTgWe1GWKv46af8(gHkcyMJYwdyhjqGW6EfWe1GWKv46af8gDdveWmhLTgWGW6ETp8bfcyIAqyYkCDGcEF7HkcyMJYwdyqeaxaWtTmGjQbHjRW1bk4n6juratudctwHRdyoqsciTagQN314f1ukQId0SgScyMJYwdyoJX2MJYw3SKtbmwYPTAisaZ14f1ukqbVHbHkcyMJYwdyCFeKw3ldaVKzajGjQbHjRW1bkqbmcKkCH28AwsB3P4GhQi4nkHkcyIAqyYkCDaRRdyCHcyMJYwdy4nqAqysadVX8Lag0Zd98qpVGo8Z6AzffK6caXy7gSutDsadVb2QHibmET4sJTf0HFwxlRaf82ZqfbmrnimzfUoG11bmUqbmZrzRbm8ginimjGH3y(sad65jqQWfksOepn(Ug0U5RopbsfUqrcL4PX3UUzR(IopSbm8gyRgIeWiqQWfA3QeOG3vkuratudctwHRdyDDaJluaZCu2AadVbsdctcy4nMVeWGEEcKkCHIKNXtJVRbTB(QZtGuHluK8mEA8TRB2QVOZdBadVb2QHibmcKkCH20LoqbVVrOIaMOgeMScxhW66agxOaM5OS1agEdKgeMeWWBmFjGb98OEEONNaPcxOiHs8047Aq7MV68eiv4cfjuINgF76MT6l68WopSZJd38qppQNh65jqQWfksEgpn(Ug0U5RopbsfUqrYZ4PX3UUzR(IopSZd784WnVGo8Z6AzflzfQp39X248ejzgLTgWWBGTAisaBziwPSjqQWfkqbVr3qfbmrnimzfUoG11bmUqbmZrzRbm8ginimjGH3y(sad65XBG0GWKibsfUq7wL5RopEdKgeMexgIvkBcKkCHMh25XHBEONhVbsdctIeiv4cTPl98vNhVbsdctIldXkLnbsfUqZd784Wnp0ZJ3aPbHjrcKkCH2Tkbm8gyRgIeWiqQWfAZRzjfOafWwgIvkBcKkCH4HkcEJsOIaMOgeMScxhWudrcy82NTZsnjbeWmhLTgW4TpBNLAsciqbV9muratudctwHRdyQHibSfqS1rcKnEHZfwaZCu2AaBbeBDKazJx4CHfOG3vkuratudctwHRdyQHibSswH6ZDFSnoprsMrzRbmZrzRbSswH6ZDFSnoprsMrzRbkqbSLWScYAtGuHlepurWBucveWe1GWKv46aM5OS1aMGuxaigB3GLAQtcyoqsciTag0Z7A8IAkf1S8K2hMmF15DDZw9fnYBF2g0ueiiwQ85H68EEZ5HDEC4Mh65DnErnLI4fLolaMV68UUzR(IgtKArxPwUDgzCc01NseiiwQ85H68EEZ5HDEC4Mh65DnErnLIQ4anRbR5XHBExJxutPi8cG005XHBExJxutPO2QmpSbm1qKaMGuxaigB3GLAQtcuWBpdveWe1GWKv46aM5OS1ag3xHW6ETneHolWPaMdKKaslGb98UgVOMsrnlpP9HjZxDEx3SvFrJ82NTbnfbcILkFEOo)TppSZJd38qpVRXlQPueVO0zbW8vN31nB1x0yIul6k1YTZiJtGU(uIabXsLppuN)2Nh25XHBEON314f1ukQId0SgSMhhU5DnErnLIWlastNhhU5DnErnLIARY8WgWudrcyCFfcR712qe6SaNcuW7kfQiGjQbHjRW1bmZrzRbmE7ZycrPwUb(qkeWCGKeqAbmON314f1ukQz5jTpmz(QZ76MT6lAK3(SnOPiqqSu5Zd15HbZd784Wnp0Z7A8IAkfXlkDwamF15DDZw9fnMi1IUsTC7mY4eORpLiqqSu5Zd15HbZd784Wnp0Z7A8IAkfvXbAwdwZJd38UgVOMsr4faPPZJd38UgVOMsrTvzEydyQHibmE7ZycrPwUb(qkeOafWCnErnLcve8gLqfbmrnimzfUoG5ajjG0cyOEEYyIsX6ttPgzZtT0NzGKkef1GWK18vNh65DDZw9fnY9rqADVma8sMbKiqqSu5Zd15r5MZJd38UUzR(Ig5(iiTUxgaEjZaseiiwQ85H58O7nNV68UUzR(Ig5(iiTUxgaEjZaseiiwQ85H58EIUZxDExRl)KIUga8RPul3mrarrnimznpSbmZrzRbSePw0vQLBNrgNaD9PeOG3EgQiGjQbHjRW1bmhijbKwaJmMOuS(0uQr28ul9zgiPcrrnimznF15xnfRpnLAKnp1sFMbsQqKsh8uldyMJYwdyjsTORul3oJmob66tjqbVRuOIaMOgeMScxhWCGKeqAbmx3SvFrJCFeKw3ldaVKzajceelv(8WCE0D(QZd98lbI)Xr808vkceelv(8WC(BmpoCZJ65jJjkfpnFLIIAqyYAEydyMJYwdylXLigLA5gsZOaf8(gHkcyIAqyYkCDaZbssaPfWq98KXeLI1NMsnYMNAPpZajvikQbHjR5Rop0Z76MT6lAK7JG06Eza4LmdirGGyPYNhQZJUZJd38UUzR(Ig5(iiTUxgaEjZaseiiwQ85H58O7nNhhU5DDZw9fnY9rqADVma8sMbKiqqSu5ZdZ59eDNV68Uwx(jfDna4xtPwUzIaIIAqyYAEydyMJYwdy82NTbnfOG3OBOIaMOgeMScxhWCGKeqAbmYyIsX6ttPgzZtT0NzGKkef1GWK18vNF1uS(0uQr28ul9zgiPcrkDWtTmGzokBnGXBF2g0uGcEF7HkcyMJYwdyCx7dsTCtjDkbmrnimzfUoqbkGTAAxdK6qfbVrjuratudctwHRdyoqsciTa2QPOv2AHiqqSu5Zd15HbZxDEx3SvFrJCFeKw3ldaVKzajceelv(8WC(vtrRS1crGGyPYdyMJYwdywzRfcuWBpdveWe1GWKv46aMdKKaslGTAkYZ6Zw3S8qIabXsLppuNhgmF15DDZw9fnY9rqADVma8sMbKiqqSu5ZdZ5xnf5z9zRBwEirGGyPYdyMJYwdy8S(S1nlpKaf8UsHkcyIAqyYkCDaZbssaPfWwnf9vozqyY2ooyPJYwJabXsLppuNhgmF15DDZw9fnY9rqADVma8sMbKiqqSu5ZdZ5xnf9vozqyY2ooyPJYwJabXsLhWmhLTgW8vozqyY2ooyPJYwduW7BeQiGjQbHjRW1bmhijbKwaB1u01aGFnLTgbcILkFEOopmy(QZ76MT6lAK7JG06Eza4LmdirGGyPYNhMZVAk6AaWVMYwJabXsLhWmhLTgWCna4xtzRbkqbSLCy(mkurWBucveWmhLTgW41cJTzTdEatudctwHRduWBpdveWmhLTgWwc(2hSrSY0fWe1GWKv46af8UsHkcyIAqyYkCDaZbssaPfWmhL4LTOcsk85H58vkGXjq6OG3OeWmhLTgWCgJTnhLTUzjNcySKtB1qKaM1sGcEFJqfbmrnimzfUoGTeUdK1u2AadD6OS15zjN4ZF0G5jqQWfAEiYPHpBqCEmYi(8gqMNB4L18hnyEiYrdK5XAF28EXMUYlGul6k1Y5VLrgNaD9PCf690uQrMhl1sFMbsQGhZ30PaUKCz(wN31nB1x0aM5OS1aMZyST5OS1nl5uaJtG0rbVrjG5ajjG0cyuIiZd15rjGXsoTvdrcyeiv4cT51SK2UtXbpqbVr3qfbmrnimzfUoGzokBnG5mgBBokBDZsofWyjN2QHibSLWScYAtGuHlepqbVV9qfbmrnimzfUoG5ajjG0cyqp)QPiV9zBqtrkDWtTCEC4MF1umrQfDLA52zKXjqxFk7vtrkDWtTCEC4MF1uS(0uQr28ul9zgiPcrkDWtTCEyNV6882NT5NgynpmNVsZJd38RMI4tMSjlvksPdEQLZJd38KXeLI8(YMoLnxKfpkQbHjRagNaPJcEJsaZCu2AaZzm22Cu26MLCkGXsoTvdrcyCYOnbsfUq8af8g9eQiGjQbHjRW1bmhijbKwaZ14f1ukQz5jTpmz(QZd98OEE8ginimjsGuHl0MxZsAEC4M31nB1x0iV9zBqtrGGyPYNhMZ75nNhhU5HEE8ginimjsGuHl0Uvz(QZ76MT6lAK3(SnOPiqqSu5Zd15jqQWfksOeDDZw9fnceelv(8WopoCZd984nqAqysKaPcxOnDPNV68UUzR(Ig5TpBdAkceelv(8qDEcKkCHIKNrx3SvFrJabXsLppSZdBaJtG0rbVrjGzokBnG5mgBBokBDZsofWyjN2QHibSLHyLYMaPcxiEGcEddcveWe1GWKv46aMdKKaslG5A8IAkfXlkDwamF15HEEuppEdKgeMejqQWfAZRzjnpoCZ76MT6lAmrQfDLA52zKXjqxFkrGGyPYNhMZ75nNhhU5HEE8ginimjsGuHl0Uvz(QZ76MT6lAmrQfDLA52zKXjqxFkrGGyPYNhQZtGuHluKqj66MT6lAeiiwQ85HDEC4Mh65XBG0GWKibsfUqB6spF15DDZw9fnMi1IUsTC7mY4eORpLiqqSu5Zd15jqQWfksEgDDZw9fnceelv(8WopSbmobshf8gLaM5OS1aMZyST5OS1nl5uaJLCARgIeWwgIvkBcKkCH4bk4TxwOIaMOgeMScxhWCGKeqAbmON314f1ukQId0SgSMhhU5DnErnLIWlastNhhU5DnErnLIARY8WoF15HEEuppEdKgeMejqQWfAZRzjnpoCZ76MT6lAS(0uQr28ul9zgiPcrGGyPYNhMZ75nNhhU5HEE8ginimjsGuHl0Uvz(QZ76MT6lAS(0uQr28ul9zgiPcrGGyPYNhQZtGuHluKqj66MT6lAeiiwQ85HDEC4Mh65XBG0GWKibsfUqB6spF15DDZw9fnwFAk1iBEQL(mdKuHiqqSu5Zd15jqQWfksEgDDZw9fnceelv(8WopSbmobshf8gLaM5OS1aMZyST5OS1nl5uaJLCARgIeWwgIvkBcKkCH4bk4nk3muratudctwHRdyoqsciTagQNNmMOuS(0uQr28ul9zgiPcrrnimznF15HEEuppEdKgeMejqQWfAZRzjnpoCZ76MT6lAK7JG06Eza4LmdirGGyPYNhMZ75nNhhU5HEE8ginimjsGuHl0Uvz(QZ76MT6lAK7JG06Eza4LmdirGGyPYNhQZtGuHluKqj66MT6lAeiiwQ85HDEC4Mh65XBG0GWKibsfUqB6spF15DDZw9fnY9rqADVma8sMbKiqqSu5Zd15jqQWfksEgDDZw9fnceelv(8WopSbmobshf8gLaM5OS1aMZyST5OS1nl5uaJLCARgIeWwgIvkBcKkCH4bk4nkOeQiGjQbHjRW1bmZrzRbmeJjhPBdSAYhibSLWDGSMYwdyx7d055TpBE(Pbw85ZJ5pYYtA(KpVXqAonFJxabmhijbKwadsZ5ZxD(JS8K2abXsLppuNxGrX5tYMsezEyONN3(Sn)0aR5Ro)QPOVYjdct22XblDu2AKsh8ulduWBu8muratudctwHRdylH7aznLTgW8chZ7A8IAkn)QPRqVNMsnY8yPw6ZmqsfMp5Zd8vn1spM3NlZFBgaEjZaY8upVaJKOR5PtzENpaiknpxOaM5OS1aMZyST5OS1nl5uaZbssaPfWGEExJxutPiErPZcG5Ro)QPyIul6k1YTZiJtGU(u2RMIu6GNA58vN31nB1x0i3hbP19YaWlzgqIabXsLppuN3Z5Rop0ZVAkwFAk1iBEQL(mdKuHiqqSu5ZdZ59CEC4Mh1ZtgtukwFAk1iBEQL(mdKuHOOgeMSMh25HDEC4Mh65DnErnLIAwEs7dtMV68RMI82NTbnfP0bp1Y5RoVRB2QVOrUpcsR7LbGxYmGebcILkFEOoVNZxDEONF1uS(0uQr28ul9zgiPcrGGyPYNhMZ7584WnpQNNmMOuS(0uQr28ul9zgiPcrrnimznpSZd784Wnp0Zd98UgVOMsrvCGM1G184WnVRXlQPueEbqA684WnVRXlQPuuBvMh25Ro)QPy9PPuJS5Pw6ZmqsfIu6GNA58vNF1uS(0uQr28ul9zgiPcrGGyPYNhQZ758WgWyjN2QHibSLbGxYmGSRbsDGcEJsLcveWe1GWKv46a2s4oqwtzRbmVOCae(58RM4ZlgGvy(8y(Yo1Y5tL65T55NgynpVw0vQLZxFACjGzokBnG5mgBBokBDZsofWCGKeqAbmON314f1ukQz5jTpmz(QZJ65xnf5TpBdAksPdEQLZxDEx3SvFrJ82NTbnfbcILkFEOo)nMh25XHBEON314f1ukIxu6Say(QZJ65xnftKArxPwUDgzCc01NYE1uKsh8ulNV68UUzR(IgtKArxPwUDgzCc01NseiiwQ85H683yEyNhhU5HEEON314f1ukQId0SgSMhhU5DnErnLIWlastNhhU5DnErnLIARY8WoF15jJjkfRpnLAKnp1sFMbsQquudctwZxDEup)QPy9PPuJS5Pw6ZmqsfIu6GNA58vN31nB1x0y9PPuJS5Pw6ZmqsfIabXsLppuN)gZdBaJLCARgIeWwnTRbsDGcEJYncveWe1GWKv46aM5OS1a2YaW382NfWwc3bYAkBnG5foMh9EAk1iZJLAPpZajvy(KppLo4Pw6X8jnFYNNBhY8upVpxM)2ma85XAFwaZbssaPfWwnfRpnLAKnp1sFMbsQqKsh8ulduWBuq3qfbmrnimzfUoG5ajjG0cyOEEYyIsX6ttPgzZtT0NzGKkef1GWK18vNh65xnf5TpBdAksPdEQLZJd38RMIjsTORul3oJmob66tzVAksPdEQLZdBaZCu2AaBza4BE7ZcuWBuU9qfbmrnimzfUoGzokBnGvFAk1iBEQL(mdKuHa2s4oqwtzRbmScQBE07PPuJmpwQL(mdKuH5VK058vMeLolaUY7S8KMhgktM314f1uA(vtEmFtNc4sYL595Y8ToVRB2QVOX59chZ7LJuxaigBEVuWsn1jZdX)4y(KpFQUgj1spM)SzR59vkzZNeA85bITkmp0OadMNlUwx85TdsaZ7ZfydyoqsciTaMRXlQPuuZYtAFyY8vNNsezEyop6oF15DDZw9fnYBF2g0ueiiwQ85H68OmF15HEEx3SvFrJcsDbGySDdwQPojceelv(8qDEuUDpNhhU5r98c6WpRRLvuqQlaeJTBWsn1jZdBGcEJc6juratudctwHRdyoqsciTaMRXlQPueVO0zbW8vNNsezEyop6oF15DDZw9fnMi1IUsTC7mY4eORpLiqqSu5Zd15rz(QZd98UUzR(IgfK6caXy7gSutDseiiwQ85H68OC7EopoCZJ65f0HFwxlROGuxaigB3GLAQtMh2aM5OS1aw9PPuJS5Pw6ZmqsfcuWBuGbHkcyIAqyYkCDaZbssaPfWGEExJxutPOkoqZAWAEC4M314f1ukcVainDEC4M314f1ukQTkZd78vNh65DDZw9fnki1faIX2nyPM6KiqqSu5Zd15r529CEC4Mh1ZlOd)SUwwrbPUaqm2Ubl1uNmpSbmZrzRbS6ttPgzZtT0NzGKkeOG3O4LfQiGjQbHjRW1bmhijbKwadsZ5ZxD(JS8K2abXsLppuNhLBpGzokBnGvFAk1iBEQL(mdKuHaf82ZBgQiGjQbHjRW1bSLWDGSMYwdyEHJ5rVNMsnY8yPw6ZmqsfMp5ZtPdEQLEmFsOXNNsezEQN3NlZ30PaMhX8s0G5xnXdyMJYwdyoJX2MJYw3SKtbmhijbKwaB1uS(0uQr28ul9zgiPcrkDWtTC(QZd98UgVOMsrnlpP9HjZJd38UgVOMsr8IsNfaZdBaJLCARgIeWCnErnLcuWBprjuratudctwHRdyMJYwdywzRfcyoqsciTa2QPOv2AHiqqSu5Zd15VraZvWXKnzGsH4bVrjqbV90ZqfbmZrzRbStZxPaMOgeMScxhOG3EwPqfbmrnimzfUoGzokBnGXfzT7JTRba)AkBnGTeUdK1u2AadRVmpDkZJjYIpFRZxP5jdukeF(8y(KMp5kA08oFaquIvy(uN)GLLN08ny(wNNoL5jdukuCEy4KoNhlRpBDEujpK5tcn(8gJ3ZdrisaZt98(CzEmrwZ34fW8iM6BmwH5T6AwHulNVsZFRga8RPSvEmG5ajjG0cyMJs8Ywubjf(8WCEpNV68KXeLI8(YMoLnxKfpkQbHjR5RopQNF1uKlYA3hBxda(1u2AKsh8ulNV68OE(u3hSS8KcuWBpVrOIaMOgeMScxhWCGKeqAbmZrjEzlQGKcFEyoVNZxDEYyIsrEwF26MLhsuudctwZxDEup)QPixK1Up2Uga8RPS1iLo4PwoF15r98PUpyz5jnF15xnfDna4xtzRrGGyPYNhQZFJaM5OS1agxK1Up2Uga8RPS1af82t0nuratudctwHRdyoqsciTag0ZZBF2MFAG18WCEuMhhU5nhL4LTOcsk85H58EopSZxDEx3SvFrJCFeKw3ldaVKzajceelv(8WCEu8mGzokBnGHpzYMSuPaf82ZBpuratudctwHRdyoqsciTaM5OeVSxnf9vozqyY2ooyPJYwNV483CEC4MNsh8ulNV68RMI(kNmimzBhhS0rzRrGGyPYNhQZFJaM5OS1aMVYjdct22XblDu2AGcE7j6juratudctwHRdyMJYwdy8S(S1nlpKaMdKKaslGTAkYZ6Zw3S8qIabXsLppuN)gbmxbht2KbkfIh8gLaf82tyqOIaMOgeMScxhWCGKeqAbmupVRXlQPuufhOznyfW4eiDuWBucyMJYwdyoJX2MJYw3SKtbmwYPTAisaZ14f1ukqbV90lluratudctwHRdyMJYwdyUga8RPS1aMRGJjBYaLcXdEJsaZbssaPfWmhL4LTOcsk85H683y(kFEONNmMOuK3x20PS5IS4rrnimznpoCZtgtukYZ6Zw3S8qIIAqyYAEyNV68RMIUga8RPS1iqqSu5Zd159mGTeUdK1u2AadDwxZkm)TAaWVMYwNhXuFJXkmFRZJsL758KbkfI7X8ny(wNVsZFjPZ5rNq4nZNK5Vvda(1u2AGcExPBgQiGjQbHjRW1bmZrzRbmeJjhPBdSAYhibSLWDGSMYwdyOZdsaZtNY8DTOcWJ551IUM3MNFAG18xofDEJMhDNV15RSgtos38ErRM8bY8upVHVZ18nEb4S66uldyoqsciTagV9zB(PbwZdZ5VX8vNNsezEyoVNOeOG3vcLqfbmrnimzfUoGTeUdK1u2Aadg(u051MMNxqDPwop690uQrMhl1sFMbsQW8upFLjrPZcGR8olpP5HHYepMhZhbP15VndaVKzaz(8yEJXMF1eFEdiZB11SuwbmZrzRbmNXyBZrzRBwYPaMdKKaslGb98UgVOMsr8IsNfaZxDEuppzmrPy9PPuJS5Pw6ZmqsfIIAqyYA(QZVAkMi1IUsTC7mY4eORpL9QPiLo4PwoF15DDZw9fnY9rqADVma8sMbKiqSvH5HDEC4Mh65DnErnLIAwEs7dtMV68OEEYyIsX6ttPgzZtT0NzGKkef1GWK18vNF1uK3(SnOPiLo4PwoF15DDZw9fnY9rqADVma8sMbKiqSvH5HDEC4Mh65HEExJxutPOkoqZAWAEC4M314f1ukcVainDEC4M314f1ukQTkZd78vN31nB1x0i3hbP19YaWlzgqIaXwfMh2agl50wnejGTma8sMbKDnqQduW7k5zOIaMOgeMScxhWmhLTgWwga(M3(Sa2s4oqwtzRbmyiCz(BZaWNhR9zZNhZFBgaEjZaY8xAfnAEiY8aXwfM3kTu9y(gmFEmpDkaz(ljJnpezEJMNjgNM3Z5rAGm)Tza4LmdiZ7ZfEaZbssaPfWG0C(8vN31nB1x0i3hbP19YaWlzgqIabXsLppmN)ilpPnqqSu5ZxDEONh1ZtgtukwFAk1iBEQL(mdKuHOOgeMSMhhU5DDZw9fnwFAk1iBEQL(mdKuHiqqSu5ZdZ5pYYtAdeelv(8WgOG3vQsHkcyIAqyYkCDaZbssaPfWG0C(8vNh1ZtgtukwFAk1iBEQL(mdKuHOOgeMSMV68UUzR(Ig5(iiTUxgaEjZaseiiwQ85HY8UUzR(Ig5(iiTUxgaEjZasC5dmkBDEOo)rwEsBGGyPYdyMJYwdyldaFZBFwGcExPBeQiGjQbHjRW1bSLWDGSMYwdy3Yi3zLBm28jjiZ7ZTsz(JgmVPfOZulNxBAEET4YJuwZlmUC5uasaZCu2AaZzm22Cu26MLCkGXsoTvdrcyjjibk4DLq3qfbmrnimzfUoG5ajjG0cymbVWMhMZJUON5Rop0ZVei(hhr(PT6lBbbcWCsKtMd(8qDEON3Z5R85nhLTg5N2QVSH0mkM6(GLLN08WopoCZVei(hhr(PT6lBbbcWCseiiwQ85H68vAEydyMJYwdyoJX2MJYw3SKtbmwYPTAisaJlbk4DLU9qfbmrnimzfUoGzokBnGHym5iDBGvt(ajGTeUdK1u2AadgcxMVYAm5iDZ7fTAYhiZF5u05rmVeny(vt85nGmVFThZ3G5ZJ5PtbiZFjzS5HiZZZsnpsNP08uIiZ7RuYMNoL5vbgP5rVNMsnY8yPw6ZmqsfIZ7foM3Nswwzi1Y5RSgtos38WWaJo9y(ZMTM3MNFAG18uppqoac)CE6uMhI)XraZbssaPfWGE(vtr8jt2KLkfP0bp1Y5XHB(vtXePw0vQLBNrgNaD9PSxnfP0bp1Y5XHB(vtrE7Z2GMIu6GNA58WoF15HEEuppWxLJgukreJjhPBFby0zuudctwZJd38q8poIigtos3(cWOZiNmh85H68vAEC4MN3(Sn)0aR5H58OmpSbk4DLqpHkcyIAqyYkCDaZCu2AadXyYr62aRM8bsaBjChiRPS1agmeUmFL1yYr6M3lA1KpqMN65rSujl15PtzEeJjhPB(laJoNhI)XX8(kLS55NgyXNxfznp1ZdrMVuubyKSM)ObZtNY8QaJ08q8bCA(lPU6lZdTN3CEU4ADXNp5ZJ0azE60055(hhPlfLMN65lfvagjZxP55NgyXHnG5ajjG0cyaFvoAqPermMCKU9fGrNrrnimznF15DDZw9fnYBF2g0ueiiwQ85H58EEZ5Rope)JJiIXKJ0TVam6mceelv(8qD(BeOG3vcgeQiGjQbHjRW1bmZrzRbmeJjhPBdSAYhibSLWDGSMYwdyWq4Y8vwJjhPBEVOvt(az(wNh9EAk1iZJLAPpZajvyENXjUhZJyWtTCEUpqMN655gEzEBE(PbwZt98CYCWNVYAm5iDZdddm6C(8yEFEQLZNuaZbssaPfWiJjkfRpnLAKnp1sFMbsQquudctwZxDEONF1uS(0uQr28ul9zgiPcrkDWtTCEC4M31nB1x0y9PPuJS5Pw6ZmqsfIabXsLppmN3t0DEC4MhsZ5ZxDEkrKn17vkZd15DDZw9fnwFAk1iBEQL(mdKuHiqqSu5Zd78vNh65r98aFvoAqPermMCKU9fGrNrrnimznpoCZdX)4iIym5iD7laJoJCYCWNhQZxP5XHBEE7Z28tdSMhMZJY8WgOG3vYlluratudctwHRdyMJYwdylGL6MLhsaBjChiRPS1a2TbSuNhvYdz(KpFRScZBZFBOxS5lTuN)ssNZ7fubFsgeMm)TjijxMxfdmpIbJZZjZbNhN3lCm)rwEsZN85niTpnp1Zl6A(vpV208ijNppVw0vQLZtNY8CYCW5bmhijbKwadI)XrmvbFsgeMSxcsYLiNmh85H5834MZJd38q8poIPk4tYGWK9sqsUe9RNV68qAoF(QZFKLN0giiwQ85H683iqbVVXndveWe1GWKv46aM5OS1aMZyST5OS1nl5uaJLCARgIeWCnErnLcuW7BGsOIaMOgeMScxhWmhLTgWSYwleWCGKeqAbmGCae(PbHjbmxbht2KbkfIh8gLaf8(gEgQiGjQbHjRW1bmhijbKwaZCuIx2RMI(kNmimzBhhS0rzRZxC(BopoCZtPdEQLZxDEGCae(PbHjbmZrzRbmFLtgeMSTJdw6OS1af8(gvkuratudctwHRdyMJYwdy8S(S1nlpKaMdKKaslGbKdGWpnimjG5k4yYMmqPq8G3OeOG334gHkcyIAqyYkCDaZCu2AaZ1aGFnLTgWCGKeqAbmGCae(PbHjZxDEZrjEzlQGKcFEOo)nMVYNh65jJjkf59LnDkBUilEuudctwZJd38KXeLI8S(S1nlpKOOgeMSMh2aMRGJjBYaLcXdEJsGcEFd0nuralvsaa)AkGHsaZCu2AaBbSu382NfWe1GWKv46af8(g3EOIaM5OS1ag)0w9LnKMrbmrnimzfUoqbkGvdexJaXOqfbVrjuratudctwHRdyoqsciTagLiY8WC(BoF15r981cfnwIxMV68OEEi(hhXsqI0jq29XMBoqEKoj6xhWmhLTgWoe2E1iPAu2AGcE7zOIaM5OS1ag3hbP19HWo9vsabmrnimzfUoqbVRuOIaMOgeMScxhWCGKeqAbmYyIsXsqI0jq29XMBoqEKojkQbHjRaM5OS1awjir6ei7(yZnhipsNeOG33iuratudctwHRdyDDaJluaZCu2AadVbsdctcy4nMVeWmhL4L9QPORba)AkBDEyo)nNV68MJs8YE1u0kBTW8WC(BoF15nhL4L9QPOVYjdct22XblDu268WC(BoF15HEEuppzmrPipRpBDZYdjkQbHjR5XHBEZrjEzVAkYZ6Zw3S8qMhMZFZ5HD(QZd98RMI1NMsnYMNAPpZajvisPdEQLZJd38OEEYyIsX6ttPgzZtT0NzGKkef1GWK18WgWWBGTAisaB1eFdeBviqbVr3qfbmrnimzfUoGPgIeWSkd8tdy89rR0Up219fbeWmhLTgWSkd8tdy89rR0Up219fbeOG33EOIaMOgeMScxhWmhLTgW4IS29X21aGFnLTgWCGKeqAbmETWyBYaLcXJCrw7(y7AaWVMYw3wlZdZIZxPaglvz7wbmuUzGcEJEcveWmhLTgWonFLcyIAqyYkCDGcEddcveWmhLTgW8vozqyY2ooyPJYwdyIAqyYkCDGcuaZAjurWBucveWmhLTgWQpnLAKnp1sFMbsQqatudctwHRduWBpdveWmhLTgWonFLcyIAqyYkCDGcExPqfbmrnimzfUoG5ajjG0cyqpVRXlQPueVO0zbW8vNF1umrQfDLA52zKXjqxFk7vtrkDWtTC(QZ76MT6lAK7JG06Eza4LmdirGyRcZxDEONF1uS(0uQr28ul9zgiPcrGGyPYNhMZ7584WnpQNNmMOuS(0uQr28ul9zgiPcrrnimznpSZd784Wnp0Z7A8IAkf1S8K2hMmF15xnf5TpBdAksPdEQLZxDEx3SvFrJCFeKw3ldaVKzajceBvy(QZd98RMI1NMsnYMNAPpZajviceelv(8WCEpNhhU5r98KXeLI1NMsnYMNAPpZajvikQbHjR5HDEyNV68qpp0Z7A8IAkfvXbAwdwZJd38UgVOMsr4faPPZJd38UgVOMsrTvzEyNV68RMI1NMsnYMNAPpZajvisPdEQLZxD(vtX6ttPgzZtT0NzGKkebcILkFEOoVNZdBaZCu2AaZzm22Cu26MLCkGXsoTvdrcyldaVKzazxdK6af8(gHkcyIAqyYkCDaZbssaPfWiJjkf59LnDkBUilEuudctwZxDENPBUiRaM5OS1agxK1Up2Uga8RPS1af8gDdveWe1GWKv46aMdKKaslGH65jJjkf59LnDkBUilEuudctwZxDEup)QPixK1Up2Uga8RPS1iLo4PwoF15r98PUpyz5jnF15xnfDna4xtzRrGCae(PbHjbmZrzRbmUiRDFSDna4xtzRbk49ThQiGjQbHjRW1bmZrzRbmRS1cbmhijbKwaZCuIx2RMIwzRfMhQZFJ5Ropqoac)0GWKaMRGJjBYaLcXdEJsGcEJEcveWe1GWKv46aM5OS1aMv2AHaMdKKaslGzokXl7vtrRS1cZdZIZFJ5Ropqoac)0GWK5Ro)QPOv2AHiLo4PwgWCfCmztgOuiEWBucuWByqOIaMOgeMScxhWCGKeqAbmZrjEzVAk6RCYGWKTDCWshLToFX5V584WnpLo4PwoF15bYbq4NgeMeWmhLTgW8vozqyY2ooyPJYwduWBVSqfbmrnimzfUoGzokBnG5RCYGWKTDCWshLTgWCGKeqAbmuppLo4PwoF15RXxtgtukcmKAtPTDCWshLTYJIAqyYA(QZBokXl7vtrFLtgeMSTJdw6OS15H68vkG5k4yYMmqPq8G3OeOG3OCZqfbmrnimzfUoG5ajjG0cy82NT5NgynpmNhLaM5OS1ag(KjBYsLcuWBuqjuratudctwHRdyoqsciTagQN314f1ukQId0SgScyCcKok4nkbmZrzRbmNXyBZrzRBwYPagl50wnejG5A8IAkfOG3O4zOIaMOgeMScxhWCGKeqAbmON314f1ukIxu6Say(QZd98UUzR(IgtKArxPwUDgzCc01Nsei2QW84Wn)QPyIul6k1YTZiJtGU(u2RMIu6GNA58WoF15DDZw9fnY9rqADVma8sMbKiqSvH5Rop0ZVAkwFAk1iBEQL(mdKuHiqqSu5ZdZ59CEC4Mh1ZtgtukwFAk1iBEQL(mdKuHOOgeMSMh25HD(QZd98qpVRXlQPuufhOznynpoCZ7A8IAkfHxaKMopoCZ7A8IAkf1wL5HD(QZ76MT6lAK7JG06Eza4LmdirGGyPYNhQZ758vNh65xnfRpnLAKnp1sFMbsQqeiiwQ85H58EopoCZJ65jJjkfRpnLAKnp1sFMbsQquudctwZd78WopoCZd98UgVOMsrnlpP9HjZxDEON31nB1x0iV9zBqtrGyRcZJd38RMI82NTbnfP0bp1Y5HD(QZ76MT6lAK7JG06Eza4LmdirGGyPYNhQZ758vNh65xnfRpnLAKnp1sFMbsQqeiiwQ85H58EopoCZJ65jJjkfRpnLAKnp1sFMbsQquudctwZd78WgWmhLTgWCgJTnhLTUzjNcySKtB1qKa2YaWlzgq21aPoqbVrPsHkcyIAqyYkCDaZbssaPfWG0C(8vN31nB1x0i3hbP19YaWlzgqIabXsLppmN)ilpPnqqSu5ZxDEONh1ZtgtukwFAk1iBEQL(mdKuHOOgeMSMhhU5DDZw9fnwFAk1iBEQL(mdKuHiqqSu5ZdZ5pYYtAdeelv(8WgWmhLTgWwga(M3(Saf8gLBeQiGjQbHjRW1bmhijbKwadsZ5ZxDEx3SvFrJCFeKw3ldaVKzajceelv(8qzEx3SvFrJCFeKw3ldaVKzajU8bgLTopuN)ilpPnqqSu5bmZrzRbSLbGV5TplqbVrbDdveWe1GWKv46aM5OS1aMZyST5OS1nl5uaJLCARgIeWssqcuWBuU9qfbmrnimzfUoGzokBnG5mgBBokBDZsofWyjN2QHibSLWScYAtGuHlepqbVrb9eQiGjQbHjRW1bmZrzRbmNXyBZrzRBwYPagl50wnejGTmeRu2eiv4cXduWBuGbHkcyIAqyYkCDaZbssaPfWwnfRpnLAKnp1sFMbsQqKsh8ulNhhU5r98KXeLI1NMsnYMNAPpZajvikQbHjRaM5OS1aMZyST5OS1nl5uaJLCARgIeW4KrBcKkCH4bk4nkEzHkcyIAqyYkCDaZbssaPfWwnfXNmztwQuKsh8uldyMJYwdyigtos3gy1KpqcuWBpVzOIaMOgeMScxhWCGKeqAbSvtrE7Z2GMIu6GNA58vNh1ZtgtukY7lB6u2Crw8OOgeMScyMJYwdyigtos3gy1KpqcuWBprjuratudctwHRdyoqsciTagQNNmMOueFYKnzPsrrnimzfWmhLTgWqmMCKUnWQjFGeOG3E6zOIaMOgeMScxhWCGKeqAbmE7Z28tdSMhMZFJaM5OS1agIXKJ0Tbwn5dKaf82ZkfQiGjQbHjRW1bmZrzRbmEwF26MLhsaZbssaPfWmhL4L9QPipRpBDZYdzEOwC(knF15bYbq4NgeMmF15r98RMI8S(S1nlpKiLo4PwgWCfCmztgOuiEWBucuWBpVrOIaMOgeMScxhWCGKeqAbmxJxutPOkoqZAWkGXjq6OG3OeWmhLTgWCgJTnhLTUzjNcySKtB1qKaMRXlQPuGcE7j6gQiGjQbHjRW1bmhijbKwadI)XrmvbFsgeMSxcsYLiNmh85HzX5r3BopoCZdP585Rope)JJyQc(KmimzVeKKlr)65Ro)rwEsBGGyPYNhQZJUZJd38q8poIPk4tYGWK9sqsUe5K5GppmloFLq35Ro)QPiV9zBqtrkDWtTmGzokBnGTawQBwEibk4TN3EOIawQKaa(1uadLaM5OS1a2cyPU5TplGjQbHjRW1bk4TNONqfbmZrzRbm(PT6lBinJcyIAqyYkCDGcualjbjurWBucveWmhLTgW85YojbHhWe1GWKv46afOagxcve8gLqfbmZrzRbStZxPaMOgeMScxhOG3EgQiGjQbHjRW1bSujba8RPDEeWwce)JJi)0w9LTGabyojYjZbhMfRuaZCu2AaBbSu382NfWsLeaWVM2LSgIXcyOeOG3vkuraZCu2AaJFAR(YgsZOaMOgeMScxhOafW4KrBcKkCH4HkcEJsOIaMOgeMScxhWudrcyPYDaFYGWKn6W3uYhzVe8PtcyMJYwdyPYDaFYGWKn6W3uYhzVe8PtcuWBpdveWe1GWKv46aMAisalvob8Dud47vIpvzdrySaM5OS1awQCc47OgW3ReFQYgIWybk4DLcveWe1GWKv46aMAisaRXlGdwFj1YTPjITDwPeWmhLTgWA8c4G1xsTCBAIyBNvkbk49ncveWe1GWKv46aMAisaBza4iDR7L4GVR9jGWDI6KaM5OS1a2YaWr6w3lXbFx7taH7e1jbk4n6gQiGjQbHjRW1bm1qKagI5miazZpfH2i(80fWmhLTgWqmNbbiB(Pi0gXNNUaf8(2dveWe1GWKv46aMAisa7GziYUp2qmIysaZCu2Aa7GziYUp2qmIysGcEJEcveWe1GWKv46aMAisa7IbxubW3hGwxbmZrzRbSlgCrfaFFaADfOG3WGqfbmrnimzfUoGPgIeWidctODFSxcV2sqaZCu2AaJmimH29XEj8Albbk4TxwOIaMOgeMScxhWudrcy8up8zBJxNatj(gITkLDFSpeq7sQqaZCu2AaJN6HpBB86eykX3qSvPS7J9HaAxsfcuWBuUzOIaMOgeMScxhWudrcy8up8z7sMTsJAaFdXwLYUp2hcODjviGzokBnGXt9WNTlz2knQb8neBvk7(yFiG2LuHaf8gfucveWmhLTgWGW6ETp8bfcyIAqyYkCDGcEJINHkcyMJYwdyhjqGW6EfWe1GWKv46af8gLkfQiGzokBnGbraCbap1YaMOgeMScxhOafOaM5tNniGHLi3kqbkeaa]] )


end