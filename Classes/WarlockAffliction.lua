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
                if soulbind.kevins_oozeling.enabled then applyBuff( "kevins_oozeling" ) end
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


    spec:RegisterPack( "Affliction", 20210818, [[da1LZcqiqvTivQi6rOOytQeFcfzuGItbsTkPOuVsLsZIQIBPsc7sOFPsQHPsLogOYYKc9mvsAAsr11OQeBtLk8nPOKXPsv15KIcTouuAEGsUNsX(av5GOOkluLIhQsvMOkvLlIIkAJsrb9ruubojvLuReK8suubzMGs5MOOQ2PuWpvPIAOOOslLQsYtrPPkf5QQurAROOc9vPOOXsvP2RG)QIbRQdtzXG4XuzYk5YiBwQ8zP0OvQoTOvlff41qYSH62qSBs)wYWLQoUkjA5aphvtN46uLTJcFxP04bLQZtv16vPIW8Hu3hfvqTFfhGl0uGDzcfAOX72iC39(H7(JnE3REh39ocSI)EkW2BouwlfyvdHcSmVUoC6KS0aBV5hx2k0uGLxEahfy3fPNZSxFDBk7EqIUc5AEI4Hnjl1bSo5AEI4UoWcXlXIVwdqcSltOqdnE3gH7U3pC3FSX7E174UnpWY7jxOHgVdFjWUNRfPbib2fXDbwMxxhoDsw68ntdGlhQbkO8W(NVz5Z8nE3gHBGAG6E7M2sCMDG6kMN5Tw0AE2EcJNh2khQ4a1vmpZBTO183hXO8aZZ8T20fhOUI5zERfTMhcGmuUDtvcppUAt38Dfy(7dyPopB5HJduxX8nTLmuZZ8nm1LU59vwV4bO5XvB6MxQ53wauZNDZ7V8ycqZJKCEQTZBZlgMuz(uNx2nzEqTnoqDfZZCQgemnVVYq6nvMN511HtNKLYNN5YG5oVyysL4a1vmFtBjdfFEPM3yu5AEi4ABQTZFFgavl2a08PopIhwYRqmqljZV96A(77o3eFEV(4a1vm)9kDrkNMNxi083Nbq1InanpZfq9Z7mmMpVuZdOLNJM3vi9EIjzPZljcfhOUI5zjzEEHqZ7mm(yojl9GtUmpPcij(8snpxaPtMxQ5ngvUM3TtouP2opo5cFEz3K53wktY8qO5bK52P18WyTwQWh64a1vm)DwX(NNLO18L6O57b0v07HXXbQRyEM3QzGhxM)ojepGo)9Up(8qOUcqZt6A(QB(USDxUtopUAt38snV13J9pFPy)Zl18qkoF(USDx4ZdJwY8cW47Z3BouCOJduxX8ndXeF3bSo5AMJf2KetZZwygKkZ7m1r4t2nVB30wAnVuZNQqaGxVCYUyGThuDjMcSmdZmpZRRdNojlD(MPbWLd1afZWmZdLh2)8nlFMVX72iCdudumdZm)92nTL4m7afZWmZFfZZ8wlAnpBpHXZdBLdvCGIzyM5VI5zERfTM)(igLhyEMV1MU4afZWmZFfZZ8wlAnpeazOC7MQeEEC1MU57kW83hWsDE2YdhhOygMz(Ry(M2sgQ5z(gM6s38(kRx8a084QnDZl18BlaQ5ZU59xEmbO5rsop125T5fdtQmFQZl7MmpO2ghOygMz(RyEMt1GGP59vgsVPY8mVUoC6KSu(8mxgm35fdtQehOygMz(Ry(M2sgk(8snVXOY18qW12uBN)(maQwSbO5tDEepSKxHyGwsMF711833DUj(8E9XbkMHzM)kM)ELUiLtZZleA(7ZaOAXgGMN5cO(5DggZNxQ5b0YZrZ7kKEpXKS05LeHIdumdZm)vmpljZZleAENHXhZjzPhCYL5jvajXNxQ55ciDY8snVXOY18UDYHk125Xjx4Zl7Mm)2szsMhcnpGm3oTMhgR1sf(qhhOygMz(Ry(7SI9pplrR5l1rZ3dORO3dJJdumdZm)vmpZB1mWJlZFNeIhqN)E3hFEiuxbO5jDnF1nFx2Ul3jNhxTPBEPM367X(NVuS)5LAEifNpFx2Ul85HrlzEby8957nhko0XbkMHzM)kMVziM47oG1jxZCSWMKyAE2cZGuzENPocFYU5D7M2sR5LA(ufca86Lt2fhOgOmNKLYJ9aYviqmzthHpRcjvtYs9j72ijcbV7Eb(9KenCYGUaFiEDDXwqIujGov3HBoq2Lok61pqzojlLh7bKRqGyYTBUM7HGu6PNKbkZjzP8ypGCfcetUDZ1EC6KcH4JAi0gPqOt1DqkLlGYJFCLYfGNtYs5duMtYs5XEa5keiMC7MR940jfcXh1qOn8ct2o)WjhGKJqUDnVspAGYCswkp2dixHaXKB3CDlirQeqNQ7Wnhi7sh5t2TrmmPsSfKivcOt1D4MdKDPJIKAqW0AGYCswkp2dixHaXKB3CDhM47oG1jduMtYs5XEa5keiMC7MRzyG0GGjFudH2SkHFaKT87ddd7rBmNKmOZQKORaaVEjlfE39I5KKbDwLeT2s9dV7EXCsYGoRsIEkxmiy6yDD40jzPW7UxGb(IHjvI8SFV0do7OiPgemTqJ2CsYGoRsI8SFV0do7i4DxOVaZQKy)UPsHC4P26Hnqk(Js6qLAlA0WxmmPsSF3uPqo8uB9Wgif)rsniyAb9aL5KSuEShqUcbIj3U5ApoDsHq8rneAJDNGVBaJF6kvov3PV2sGbkZjzP8ypGCfcetUDZ1CIwNQ74kaWRxYs9bNkDCRnWDxFYUn8EcJpIbAjHh5eTov3XvaGxVKLESIG3MRoqzojlLh7bKRqGyYTBUE38uzGYCswkp2dixHaXKB3CTNYfdcMowxhoDsw6a1afZWmZZCc7KZtO18edc4FEjrO5LDAEZjfy(KpVXWsSbbtXbkZjzP8n8EcJp4YHAGYCswk)2nxVigLh4GyTPBGYCswk)2nx7mm(yojl9GtU4JAi0gRiF4ciDYg48j72yojzqhsjKK4W7QdumZ8mpNKLopo5cF(UcmVasffjZdH2ngzbIZZkMWN3a08CJbTMVRaZdH6kanpB5HN3xvY1(AKEsxP2o)9mX4cO63PRzU7MkfY8SP26Hnqk(9z(s2jW2KtZx68UQWRARoqzojlLF7MRDggFmNKLEWjx8rneAJasffjhEpoLJBNCOgOmNKLYVDZ1odJpMtYsp4Kl(OgcTzryZpTocivuKWhOmNKLYVDZ1odJpMtYsp4Kl(OgcTHlMCeqQOiH7dxaPt2aNpz3gywLe5Lh(akjkPdvQTOrVkjMi9KUsT94mX4cO63PZQKOKouP2Ig9QKy)UPsHC4P26Hnqk(Js6qLAl0x4Lh(W3nWcExfn6vjrgjMoILQeL0Hk1w0OfdtQe512JSthorl(aL5KSu(TBU2zy8XCsw6bNCXh1qOnldXAPJasffjCFYUnUIbPMkrnB3LtNrxGb(mmqAqWuuaPIIKdVhNcA0UQWRARg5Lh(akjcielvo8A8UOrddddKgemffqQOi5ukDXvfEvB1iV8WhqjraHyPYHLasffjr4IUQWRARgbeILkhA0OHHHbsdcMIcivuKCKT1fxv4vTvJ8YdFaLebeILkhwcivuKeBm6QcVQTAeqiwQCOHgnAxXGutLidsLD)GlWaFgginiykkGurrYH3JtbnAxv4vTvJjspPRuBpotmUaQ(Dkcielvo8A8UOrddddKgemffqQOi5ukDXvfEvB1yI0t6k12JZeJlGQFNIacXsLdlbKkksIWfDvHx1wncielvo0OrddddKgemffqQOi5iBRlUQWRARgtKEsxP2ECMyCbu97ueqiwQCyjGurrsSXORk8Q2QraHyPYHgA0OHXvmi1ujQKdu4cSqJ2vmi1ujIYpinfnAxXGutLOwkb9fyGpddKgemffqQOi5W7XPGgTRk8Q2QX(DtLc5WtT1dBGu8hbeILkhEnEx0OHHHbsdcMIcivuKCkLU4QcVQTASF3uPqo8uB9Wgif)raHyPYHLasffjr4IUQWRARgbeILkhA0OHHHbsdcMIcivuKCKT1fxv4vTvJ97MkfYHNARh2aP4pcielvoSeqQOij2y0vfEvB1iGqSu5qdnA0WxmmPsSF3uPqo8uB9Wgif)rsniyADbg4ZWaPbbtrbKkkso8ECkOr7QcVQTAK7HGu6zzauTydqraHyPYHxJ3fnAyyyG0GGPOasffjNsPlUQWRARg5EiiLEwgavl2aueqiwQCyjGurrseUORk8Q2QraHyPYHgnAyyyG0GGPOasffjhzBDXvfEvB1i3dbP0ZYaOAXgGIacXsLdlbKkksIngDvHx1wncielvo0qpqXmZFJhqNNxE4557gyXNp7MVlB3L5t(8ggP4Y8fdcmqzojlLF7MRrmm1LUdW6fpa5t2TbsX5x6Y2D5aielvoSiyNCEcDKeHA28YdF47gyDzvs0t5IbbthRRdNojlnkPdvQTdumZ8(6U5DfdsnvMFvY1m3DtLczE2uB9Wgif)ZN85bEQMARpZ7XP5VpdGQfBaAEPMNGDH018YonVZdaivMNtYaL5KSu(TBU2zy8XCsw6bNCXh1qOnldGQfBa60dOEFYUnW4kgKAQezqQS7hCzvsmr6jDLA7XzIXfq1VtNvjrjDOsT9IRk8Q2QrUhcsPNLbq1InafbeILkhwnEbMvjX(DtLc5WtT1dBGu8hbeILkhEnIgn8fdtQe73nvkKdp1wpSbsXp0qJgnmUIbPMkrnB3LtNrxwLe5Lh(akjkPdvQTxCvHx1wnY9qqk9SmaQwSbOiGqSu5WQXlWSkj2VBQuihEQTEydKI)iGqSu5WRr0OHVyysLy)UPsHC4P26Hnqk(HgA0OHbgxXGutLOsoqHlWcnAxXGutLik)G0u0ODfdsnvIAPe0xwLe73nvkKdp1wpSbsXFushQuBVSkj2VBQuihEQTEydKI)iGqSu5WQrOhOyM59vuhG47ZVkHppzaS)5ZU5BRuBNpvPM3MNVBG188EsxP2oF)UXPbkZjzP8B3CTZW4J5KS0do5IpQHqBwLC6buVpz3gyCfdsnvIA2UlNoJUa)vjrE5HpGsIs6qLA7fxv4vTvJ8YdFaLebeILkhwnhA0OHXvmi1ujYGuz3p4c8xLetKEsxP2ECMyCbu970zvsushQuBV4QcVQTAmr6jDLA7XzIXfq1VtraHyPYHvZHgnAyGXvmi1ujQKdu4cSqJ2vmi1ujIYpinfnAxXGutLOwkb9fXWKkX(DtLc5WtT1dBGu8Fb(RsI97MkfYHNARh2aP4pkPdvQTxCvHx1wn2VBQuihEQTEydKI)iGqSu5WQ5qpqXmZ7R7MN5UBQuiZZMARh2aP4F(KpVKouP26Z8PmFYNNBD08snVhNM)(maQ5zlp8aL5KSu(TBUEzauhE5H9j72Skj2VBQuihEQTEydKI)OKouP2oqzojlLF7MRxga1HxEyFYUnWxmmPsSF3uPqo8uB9Wgif)xGzvsKxE4dOKOKouP2Ig9QKyI0t6k12JZeJlGQFNoRsIs6qLAl0dumZ8S(v38m3DtLczE2uB9Wgif)ZVnL95zosQS7hCDdz7UmFZqJM3vmi1uz(vj(mFj7eyBYP59408LoVRk8Q2QX591DZZCI07hqgE(7myPM6O5H411nFYNpvxHKARpZVx418EQK45tHj(8aYw(Nhg4U)55KR0fFERtiW8ECc6bkZjzP8B3CD)UPsHC4P26Hnqk(9j724kgKAQe1SDxoDgDrsecE(Yfxv4vTvJ8YdFaLebeILkhwWDbgbKkksIesVFaz4tbwQPok6QcVQTAeqiwQCyb3D0iA0WNUsVSVNwrcP3pGm8Pal1uhb9aL5KSu(TBUUF3uPqo8uB9Wgif)(KDBCfdsnvImiv29dUijcbpF5IRk8Q2QXePN0vQThNjgxav)ofbeILkhwWDbgbKkksIesVFaz4tbwQPok6QcVQTAeqiwQCyb3D0iA0WNUsVSVNwrcP3pGm8Pal1uhb9afZmFdKdu4cSMFBk7ZZ8nm1LU5BMat2N3zCHpF)UPsHmpp1wpSbsX)8PopovA(TPSp)9rUeXKuBN)MclduMtYs53U56(DtLc5WtT1dBGu87t2TXvmi1ujQKdu4cSUa8uQRaTueXWux6oBbMSFrsecE(Yfxv4vTvJlYLiMKA7bsHLiGqSu5W6QxGraPIIKiH07hqg(uGLAQJIUQWRARgbeILkhwWDhnIgn8PR0l77PvKq69didFkWsn1rqpqXmZFNLDcmVRyqQPcFEys1H9wP2oVw6vW8BMZ3a5af0Z7mUmpZLD(sN3vfEvB1bkZjzP8B3CD)UPsHC4P26Hnqk(9j72aJRyqQPseLFqAkA0UIbPMkrTucnAyCfdsnvIk5afUaRlWh4PuxbAPiIHPU0D2cmzhAOVaJasffjrcP3pGm8Pal1uhfDvHx1wncielvoSG7oAenA4txPx23tRiH07hqg(uGLAQJGEGYCswk)2nx3VBQuihEQTEydKIFFYUnqko)sx2UlhaHyPYHfC3XafZmVVUBEM7UPsHmpBQTEydKI)5t(8s6qLARpZNct85LeHMxQ59408LStG5rSMbfy(vj8bkZjzP8B3CTZW4J5KS0do5IpQHqBCfdsnv8j72Skj2VBQuihEQTEydKI)OKouP2EbgxXGutLOMT7YPZi0ODfdsnvImiv29dGEGYCswk)2nxBTL63hNFhMoIbAjHVboFYUnRsIwBP(JacXsLdRMpqzojlLF7MR3npvgOyM5zRTZl708SeT4Zx68xDEXaTKWNp7MpL5tUYKmVZdaivW(Np157Wz7UmFbMV05LDAEXaTKeNVzMY(8Sz)EPZdBzhnFkmXN3W8AEiKieyEPM3JtZZs0A(IbbMhXupdJ9pV13J9NA78xD(7vaGxVKLYJduMtYs53U5AorRt1DCfa41lzP(KDBmNKmOdPessC414fXWKkrET9i70Ht0IFb(RsICIwNQ74kaWRxYsJs6qLA7f4N6PdNT7YaL5KSu(TBUMt06uDhxbaE9swQpz3gZjjd6qkHKehEnErmmPsKN97LEWzhDb(RsICIwNQ74kaWRxYsJs6qLA7f4N6PdNT7YLvjrxbaE9swAeqiwQCy18bkZjzP8B3CnJethXsv8j72adV8Wh(UbwWdo0OnNKmOdPessC41i0xCvHx1wnY9qqk9SmaQwSbOiGqSu5WdUghOmNKLYVDZ1Ekxmiy6yDD40jzP(KDBmNKmOZQKONYfdcMowxhoDsw6M7IgTKouP2Ezvs0t5IbbthRRdNojlncielvoSA(aL5KSu(TBUMN97LEWzh5JZVdthXaTKW3aNpz3MvjrE2Vx6bNDueqiwQCy18bkZjzP8B3CTZW4J5KS0do5IpQHqBCfdsnv8HlG0jBGZNSBd8DfdsnvIk5afUaRbkMzEMxFp2)83RaaVEjlDEet9mm2)8LopCxrJZlgOLeUpZxG5lD(Ro)2u2NN5bHxypHM)Efa41lzPduMtYs53U5AxbaE9swQpo)omDed0scFdC(KDBmNKmOdPessCy18RagXWKkrET9i70Ht0IJgTyysLip73l9GZoc6lRsIUca86LS0iGqSu5WQXbkMzEMxNqG5LDA(QNuc4Z88EsxZBZZ3nWA(T7KoVjZ7lZx68mFdtDPBEFL1lEaAEPM3yu5A(IbbCwFFQTduMtYs53U5AedtDP7aSEXdq(KDB4Lh(W3nWcEn)IKie8AeUbkMz(M5oPZRLmp3V6sTDEM7UPsHmpBQTEydKI)5LAEMJKk7(bx3q2UlZ3m0iFMN1dbP05VpdGQfBaA(SBEdJNFvcFEdqZB994KwduMtYs53U5ANHXhZjzPhCYfFudH2SmaQwSbOtpG69j72aJRyqQPsKbPYUFWf4lgMuj2VBQuihEQTEydKI)lRsIjspPRuBpotmUaQ(D6SkjkPdvQTxCvHx1wnY9qqk9SmaQwSbOiGSLFOrJggxXGutLOMT7YPZOlWxmmPsSF3uPqo8uB9Wgif)xwLe5Lh(akjkPdvQTxCvHx1wnY9qqk9SmaQwSbOiGSLFOrJggyCfdsnvIk5afUal0ODfdsnvIO8dstrJ2vmi1ujQLsqFXvfEvB1i3dbP0ZYaOAXgGIaYw(HEGIzM)oLtZFFga18SLhE(SB(7ZaOAXgGMFBPmjZdHMhq2Y)8wRLQpZxG5ZU5LDcqZVnX45HqZBY8yY4Y8nopsbO5VpdGQfBaAEpoXhOmNKLYVDZ1ldG6WlpSpz3gifNFXvfEvB1i3dbP0ZYaOAXgGIacXsLdVUSDxoacXsLFbg4lgMuj2VBQuihEQTEydKIF0ODvHx1wn2VBQuihEQTEydKI)iGqSu5WRlB3LdGqSu5qpqzojlLF7MRxga1HxEyFYUnqko)c8fdtQe73nvkKdp1wpSbsX)fxv4vTvJCpeKspldGQfBakcielv(TUQWRARg5EiiLEwgavl2auC5bmjlfwDz7UCaeILkFGIzM)EM42VcdJNpfczEpU1sZ3vG5n1VSNA78AjZZ7jx2L0AEcZPT7eGgOmNKLYVDZ1odJpMtYsp4Kl(OgcTjfczGIzyM59vuhG47ZZUBRA78mNiqaMJMhc1vaAEEpPRuBNNVBGfF(sNN5ByQlDZ7RSEXdqduMtYs53U5ANHXhZjzPhCYfFudH2WjFYUnIHjvI8DBvBpeceG5OiPgemTUaZIG411f572Q2EieiaZrrUyouWcMgVcZjzPr(UTQThifwIPE6Wz7UanA0lcIxxxKVBRA7HqGamhfbeILkhwxf6bkMz(7uonpZ3Wux6M3xz9IhGMF7oPZJyndkW8Rs4ZBaAEVEFMVaZNDZl7eGMFBIXZdHMNNTA2LotL5LeHM3tLepVStZReSlZZC3nvkK5ztT1dBGu8hN3x3nVNK48orQTZZ8nm1LU5BMat29z(9cVM3MNVBG18snpG6aeFFEzNMhIxx3aL5KSu(TBUgXWux6oaRx8aKpz3gywLezKy6iwQsushQuBrJEvsmr6jDLA7XzIXfq1VtNvjrjDOsTfn6vjrE5HpGsIs6qLAl0xGb(apL6kqlfrmm1LUZwGj7OrdXRRlIyyQlDNTat2JCXCOG1vrJMxE4dF3al4bh0dumZ83PCAEMVHPU0nVVY6fpanVuZJyPkwQZl708igM6s38BbMSppeVUU59ujXZZ3nWIpVs0AEPMhcnFlPeWeAnFxbMx2P5vc2L5H4b4Y8BtDvBNhMgV78CYv6IpFYNhPa08YUPZZ966sxsQmVuZ3skbmHM)QZZ3nWId9aL5KSu(TBUgXWux6oaRx8aKpz3gGNsDfOLIigM6s3zlWK9lUQWRARg5Lh(akjcielvo8A8UxG411frmm1LUZwGj7raHyPYHvZhOyM5z(wQIL68mFdtDPB(MjWK95nzEdJNxseIpFxbMx2P5BGCGcxG18fyEMd5hKMoVRyqQPYaL5KSu(TBUgXWux6oaRx8aKpz3gGNsDfOLIigM6s3zlWK9lW4kgKAQevYbkCbwOr7kgKAQer5hKMc9fiEDDredtDP7SfyYEeqiwQCy18bkMz(7uonpZ3Wux6M3xz9IhGMV05zU7MkfY8SP26Hnqk(N3zCH7Z8igQuBNN7bO5LAEUXGM3MNVBG18snpxmhQ5z(gM6s38ntGj7ZNDZ7XtTD(ugOmNKLYVDZ1igM6s3by9IhG8j72igMuj2VBQuihEQTEydKI)lWSkj2VBQuihEQTEydKI)OKouP2IgTRk8Q2QX(DtLc5WtT1dBGu8hbeILkhEn6lOrdP48lsIqhPoRKGLRk8Q2QX(DtLc5WtT1dBGu8hbeILkh6lWaFGNsDfOLIigM6s3zlWKD0OH411frmm1LUZwGj7rUyouW6QOrZlp8HVBGf8Gd6bkZjzP8B3CnIHPU0DawV4biFYUnIHjvI8A7r2PdNOfFGIzM)(awQZdBzhnFYNVuS)5T5VpMl78TwQZVnL9591kXifdcMM)(iKKtZRKbMhXG955I5qXJZ7R7MVlB3L5t(8gKYtMxQ5jDn)QMxlzEKKZNN3t6k125LDAEUyou8bkZjzP8B3C9cyPEWzh5t2TbIxxxmvIrkgemDwesYPixmhk4187IgneVUUyQeJumiy6SiKKtrV(lqko)sx2UlhaHyPYHvZhOmNKLYVDZ1odJpMtYsp4Kl(OgcTXvmi1uzGYCswk)2nxBTL63hNFhMoIbAjHVboFYUnaQdq8DdcMgOmNKLYVDZ1Ekxmiy6yDD40jzP(KDBmNKmOZQKONYfdcMowxhoDsw6M7IgTKouP2EbqDaIVBqW0aL5KSu(TBUMN97LEWzh5JZVdthXaTKW3aNpz3ga1bi(UbbtduMtYs53U5AxbaE9swQpo)omDed0scFdC(KDBauhG47gemDXCsYGoKsijXHvZVcyedtQe512JSthorloA0IHjvI8SFV0do7iOhOmNKLYVDZ1DyIV7awN4t2THxEyiPUImkSjjMo8cZGuXNufca86Lt2TbIxxxKrHnjX0HxygKkrV(bkZjzP8B3C9cyPE4Lh2Nufca86LnWnqzojlLF7MR572Q2EGuyzGAGYCswkpAfTPF3uPqo8uB9Wgif)duMtYs5rROB3C9U5PYaL5KSuE0k62nx7mm(yojl9GtU4JAi0MLbq1InaD6buVpz3gxXGutLidsLD)GlRsIjspPRuBpotmUaQ(D6SkjkPdvQTxCvHx1wnY9qqk9SmaQwSbOiGSL)lWSkj2VBQuihEQTEydKI)iGqSu5WRr0OHVyysLy)UPsHC4P26Hnqk(HgnAxXGutLOMT7YPZOlRsI8YdFaLeL0Hk12lUQWRARg5EiiLEwgavl2aueq2Y)fywLe73nvkKdp1wpSbsXFeqiwQC41iA0WxmmPsSF3uPqo8uB9Wgif)qJgnmUIbPMkrLCGcxGfA0UIbPMkru(bPPOr7kgKAQe1sjOVSkj2VBQuihEQTEydKI)OKouP2EzvsSF3uPqo8uB9Wgif)raHyPYHvJduMtYs5rROB3CnNO1P6oUca86LSuFYUnIHjvI8A7r2PdNOf)IZ0dNO1aL5KSuE0k62nxZjADQUJRaaVEjl1NSBd8fdtQe512JSthorl(f4VkjYjADQUJRaaVEjlnkPdvQTxGFQNoC2UlxwLeDfa41lzPra1bi(UbbtduMtYs5rROB3CT1wQFFC(Dy6igOLe(g48j72yojzqNvjrRTu)WQ5xG)QKO1wQ)OKouP2oqzojlLhTIUDZ1wBP(9X53HPJyGws4BGZNSBJ5KKbDwLeT2s9dVnn)cG6aeF3GGPlRsIwBP(Js6qLA7aL5KSuE0k62nx7PCXGGPJ11HtNKL6t2TXCsYGoRsIEkxmiy6yDD40jzPBUlA0s6qLA7fa1bi(UbbtduMtYs5rROB3CTNYfdcMowxhoDswQpo)omDed0scFdC(KDBGVKouP2EPNrVyysLiWq6nvowxhoDswkpsQbbtRlMtsg0zvs0t5IbbthRRdNojlfwxDGYCswkpAfD7MRzKy6iwQIpz3gE5Hp8DdSGhCduMtYs5rROB3CTZW4J5KS0do5IpQHqBCfdsnv8HlG0jBGZNSBd8DfdsnvIk5afUaRbkZjzP8Ov0TBU2zy8XCsw6bNCXh1qOnldGQfBa60dOEFYUnW4kgKAQezqQS7hCbgxv4vTvJjspPRuBpotmUaQ(DkciB5hn6vjXePN0vQThNjgxav)oDwLeL0Hk1wOV4QcVQTAK7HGu6zzauTydqrazl)xGzvsSF3uPqo8uB9Wgif)raHyPYHxJOrdFXWKkX(DtLc5WtT1dBGu8dn0xGbgxXGutLOsoqHlWcnAxXGutLik)G0u0ODfdsnvIAPe0xCvHx1wnY9qqk9SmaQwSbOiGqSu5WQXlWSkj2VBQuihEQTEydKI)iGqSu5WRr0OHVyysLy)UPsHC4P26Hnqk(HgA0OHXvmi1ujQz7UC6m6cmUQWRARg5Lh(akjciB5hn6vjrE5HpGsIs6qLAl0xCvHx1wnY9qqk9SmaQwSbOiGqSu5WQXlWSkj2VBQuihEQTEydKI)iGqSu5WRr0OHVyysLy)UPsHC4P26Hnqk(Hg6bkZjzP8Ov0TBUEzauhE5H9j72aP48lUQWRARg5EiiLEwgavl2aueqiwQC41LT7YbqiwQ8lWaFXWKkX(DtLc5WtT1dBGu8JgTRk8Q2QX(DtLc5WtT1dBGu8hbeILkhEDz7UCaeILkh6bkZjzP8Ov0TBUEzauhE5H9j72aP48lUQWRARg5EiiLEwgavl2aueqiwQ8BDvHx1wnY9qqk9SmaQwSbO4YdyswkS6Y2D5aielv(aL5KSuE0k62nx7mm(yojl9GtU4JAi0MuiKbkZjzP8Ov0TBU2zy8XCsw6bNCXh1qOnlcB(P1raPIIe(aL5KSuE0k62nx7mm(yojl9GtU4JAi0MLHyT0raPIIe(aL5KSuE0k62nx7mm(yojl9GtU4JAi0gUyYraPIIeUpz3MvjX(DtLc5WtT1dBGu8hL0Hk1w0OHVyysLy)UPsHC4P26Hnqk(hOmNKLYJwr3U5AedtDP7aSEXdq(KDBwLezKy6iwQsushQuBhOmNKLYJwr3U5AedtDP7aSEXdq(KDBwLe5Lh(akjkPdvQTxGVyysLiV2EKD6WjAXhOmNKLYJwr3U5AedtDP7aSEXdq(KDBGVyysLiJethXsvgOmNKLYJwr3U5AedtDP7aSEXdq(KDB4Lh(W3nWcEnFGYCswkpAfD7MR5z)EPhC2r(487W0rmqlj8nW5t2TXCsYGoRsI8SFV0do7iyT5QxauhG47gemDb(RsI8SFV0do7OOKouP2oqzojlLhTIUDZ1odJpMtYsp4Kl(OgcTXvmi1uXhUasNSboFYUnUIbPMkrLCGcxG1aL5KSuE0k62nxVawQhC2r(KDBG411ftLyKIbbtNfHKCkYfZHcEB8L7IgnKIZVaXRRlMkXifdcMolcj5u0R)sx2UlhaHyPYHLVGgneVUUyQeJumiy6SiKKtrUyouWBZv9LlRsI8YdFaLeL0Hk12bkZjzP8Ov0TBUUdt8DhW6eFYUn8Yddj1vKrHnjX0HxygKk(KQqaGxVCYUnq866ImkSjjMo8cZGuj61pqzojlLhTIUDZ1lGL6HxEyFsviaWRx2a3aL5KSuE0k62nxZ3TvT9aPWYa1aL5KSuE0vmi1uztI0t6k12JZeJlGQFN8j72aFXWKkX(DtLc5WtT1dBGu8Fbgxv4vTvJCpeKspldGQfBakcielvoSG7UOr7QcVQTAK7HGu6zzauTydqraHyPYHNVCx0ODvHx1wnY9qqk9SmaQwSbOiGqSu5WRrF5IR0LxkrxbaE9sQThmraOhOmNKLYJUIbPMk3U56ePN0vQThNjgxav)o5t2TrmmPsSF3uPqo8uB9Wgif)xwLe73nvkKdp1wpSbsXFushQuBhOmNKLYJUIbPMk3U56f5setsT9aPWIpz3gxv4vTvJCpeKspldGQfBakcielvo88LlWSiiEDDXDZtLiGqSu5WR5OrdFXWKkXDZtfOhOmNKLYJUIbPMk3U5AE5HpGs8j72aFXWKkX(DtLc5WtT1dBGu8Fbgxv4vTvJCpeKspldGQfBakcielvoS8f0ODvHx1wnY9qqk9SmaQwSbOiGqSu5WZxUlA0UQWRARg5EiiLEwgavl2aueqiwQC41OVCXv6YlLORaaVEj12dMia0duMtYs5rxXGutLB3CnV8Whqj(KDBedtQe73nvkKdp1wpSbsX)LvjX(DtLc5WtT1dBGu8hL0Hk12bkZjzP8ORyqQPYTBUM7kpqQThjLDAGAGYCswkpUmeRLocivuKW34XPtkeIpQHqB4Lh(KTAkeyGYCswkpUmeRLocivuKWVDZ1EC6KcH4JAi0MfGSvxcOddIZj8aL5KSuECziwlDeqQOiHF7MR940jfcXh1qOnTy)97NQ7yCEIKytYshOmNKLYJldXAPJasffj8B3CThNoPqi(OgcTXtD7wQ060ITvAsb4h(U5qHj(aL5KSuECziwlDeqQOiHF7MR940jfcXh1qOneKs5Lh(WiD0a1aL5KSuECzauTydqNEa1VHrIPJyPkduMtYs5XLbq1InaD6bu)TBUEzauhE5HhOmNKLYJldGQfBa60dO(B3CDFjzPduMtYs5XLbq1InaD6bu)TBUUlbeeCvRbkZjzP84YaOAXgGo9aQ)2nxdbx1605b8pqzojlLhxgavl2a0Phq93U5AieGtauP2oqzojlLhxgavl2a0Phq93U5ANHXhZjzPhCYfFudH24kgKAQ4t2Tb(UIbPMkrLCGcxG1aL5KSuECzauTydqNEa1F7MR5EiiLEwgavl2a0a1aL5KSuECryZpTocivuKW34XPtkeIpQHqBiKE)aYWNcSutDKpz3gyCfdsnvIA2UlNoJU4QcVQTAKxE4dOKiGqSu5WQX7cnA0W4kgKAQezqQS7hCXvfEvB1yI0t6k12JZeJlGQFNIacXsLdRgVl0OrdJRyqQPsujhOWfyHgTRyqQPseLFqAkA0UIbPMkrTuc6bkZjzP84IWMFADeqQOiHF7MR940jfcXh1qOnCpfcUQ1Xqiz3px8j72aJRyqQPsuZ2D50z0fxv4vTvJ8YdFaLebeILkhw3b0OrdJRyqQPsKbPYUFWfxv4vTvJjspPRuBpotmUaQ(DkcielvoSUdOrJggxXGutLOsoqHlWcnAxXGutLik)G0u0ODfdsnvIAPe0duMtYs5XfHn)06iGurrc)2nx7XPtkeIpQHqB4LhgtIKA7b4bXVpz3gyCfdsnvIA2UlNoJU4QcVQTAKxE4dOKiGqSu5W6(HgnAyCfdsnvImiv29dU4QcVQTAmr6jDLA7XzIXfq1VtraHyPYH19dnA0W4kgKAQevYbkCbwOr7kgKAQer5hKMIgTRyqQPsulLGEGYCswkpUiS5NwhbKkks43U5ApoDsHq8rneAdF3w1wADkaKt1DKcGqQ4t2TbgxXGutLOMT7YPZOlUQWRARg5Lh(akjcielvoSAo0OrdJRyqQPsKbPYUFWfxv4vTvJjspPRuBpotmUaQ(DkcielvoSAo0OrdJRyqQPsujhOWfyHgTRyqQPseLFqAkA0UIbPMkrTuc6bQbkZjzP84QKtpG63yTL63NSBZQKO1wQ)iGqSu5W6(V4QcVQTAK7HGu6zzauTydqraHyPYH3QKO1wQ)iGqSu5duMtYs5XvjNEa1F7MR5z)EPhC2r(KDBwLe5z)EPhC2rraHyPYH19FXvfEvB1i3dbP0ZYaOAXgGIacXsLdVvjrE2Vx6bNDueqiwQ8bkZjzP84QKtpG6VDZ1Ekxmiy6yDD40jzP(KDBwLe9uUyqW0X66WPtYsJacXsLdR7)IRk8Q2QrUhcsPNLbq1InafbeILkhERsIEkxmiy6yDD40jzPraHyPYhOmNKLYJRso9aQ)2nx7kaWRxYs9j72Skj6kaWRxYsJacXsLdR7)IRk8Q2QrUhcsPNLbq1InafbeILkhERsIUca86LS0iGqSu5duduMtYs5XuiKnEC6KcHWhOgOmNKLYJCAZU5PYaL5KSuEKt3U56fWs9WlpSpPkea41lNwCbXWBGZNufca86Lt2Tzrq866I8DBvBpeceG5Oixmhk4T5QduMtYs5roD7MR572Q2EGuyzGAGYCswkpYftocivuKW34XPtkeIpQHqBsL7aEIbbtNR0ZuXd5SigPJgOmNKLYJCXKJasffj8B3CThNoPqi(OgcTjvUa8Csb4NvYiv6aHW4bkZjzP8ixm5iGurrc)2nx7XPtkeIpQHqBkgeOdxBtT9yAIyhN1sduMtYs5rUyYraPIIe(TBU2JtNuieFudH2SmakKQ0ZICOo9EcG4osD0aL5KSuEKlMCeqQOiHF7MR940jfcXh1qOniMZGaOdFNi5G4Xt3aL5KSuEKlMCeqQOiHF7MR940jfcXh1qOnDydHov3bIjcMgOmNKLYJCXKJasffj8B3CThNoPqi(OgcTzRHIucWpDGsxduMtYs5rUyYraPIIe(TBU2JtNuieFudH2igemjNQ7SiEVLGbkZjzP8ixm5iGurrc)2nx7XPtkeIpQHqB4P25HpgVpbMk8deB1sNQ70rGYLI)bkZjzP8ixm5iGurrc)2nx7XPtkeIpQHqB4P25HpTyBLMua(bITAPt1D6iq5sX)aL5KSuEKlMCeqQOiHF7MRHGRAD68a(hOmNKLYJCXKJasffj8B3CDxcii4QwduMtYs5rUyYraPIIe(TBUgcb4eavQTdudumZ8ntA(vPmjZZ967lGm)WC45n(8((o7RMp15HnpZN5518(AMyqZ7kLbbeAnVSN85LAEdKYocjPloqzojlLhfqQOi5W7XPCC7Kd1ggginiyYh1qOn8EYLg(qxPx23tlFyyypAdmWaxZMUsVSVNwrcP3pGm8Pal1uhb9TWaxZMUsVSVNwXu5oGNyqW05k9mv8qolIr6iOVfg4A20v6L990kYlpmMej12dWdIFOVfg4A20v6L990kY9ui4QwhdHKD)CbAO3a3aL5KSuEuaPIIKdVhNYXTtou3U5AgginiyYh1qOncivuKCkL8HHH9OnWiGurrseU4UXp9GYDraPIIKiCXDJFCvHx1wf6bkZjzP8OasffjhEpoLJBNCOUDZ1mmqAqWKpQHqBeqQOi5iBlFyyypAdmcivuKeBmUB8tpOCxeqQOij2yC34hxv4vTvHEGYCswkpkGurrYH3Jt542jhQB3CnddKgem5JAi0MLHyT0raPIIeFyyypAdmWhgbKkksIWf3n(PhuUlcivuKeHlUB8JRk8Q2QqdnA0WaFyeqQOij2yC34NEq5UiGurrsSX4UXpUQWRARcn0OrtxPx23tRyl2F)(P6ogNNij2KS0bkZjzP8OasffjhEpoLJBNCOUDZ1mmqAqWKpQHqBeqQOi5W7XP4ddd7rBGHHbsdcMIcivuKCkLUWWaPbbtXLHyT0raPIIeOrJgggginiykkGurrYr2wxyyG0GGP4YqSw6iGurrc0OrddCnBgginiykkGurrYPuc6BHbUMnddKgemf59Kln8HUsVSVNwqVbo0OHbUMnddKgemffqQOi5iBlOVfg4A2mmqAqWuK3tU0Wh6k9Y(EAb9g4cSmiapln0qJ3Tr4UBZ6UnRa7wdOP2YdSntMNVQbFDdmhWSZpFt708jsFbK57kW8mjGurrYH3Jt542jhkMMhqxPxcO188cHM38KcXeAnVB30wIhhOGTuP5BKzN)ELYGacTMNjbKkksIWf9ntZl18mjGurrsuGl6BMMhMgHDOJduWwQ08xLzN)ELYGacTMNjbKkksIng9ntZl18mjGurrsuAm6BMMhMgHDOJduWwQ08nNzN)ELYGacTMNjbKkksIWf9ntZl18mjGurrsuGl6BMMhMgHDOJduWwQ08nNzN)ELYGacTMNjbKkksIng9ntZl18mjGurrsuAm6BMMhMgHDOJduduntMNVQbFDdmhWSZpFt708jsFbK57kW8m5kgKAQW08a6k9saTMNxi08MNuiMqR5D7M2s84afSLknpCm783RugeqO18mjgMuj6BMMxQ5zsmmPs03rsniyAX08WahSdDCGc2sLMhoMD(7vkdci0AEMCLU8sj6BMMxQ5zYv6YlLOVJKAqW0IP5Hboyh64afSLknFJm783RugeqO18mjgMuj6BMMxQ5zsmmPs03rsniyAX08WahSdDCGc2sLM)Qm783RugeqO18mjgMuj6BMMxQ5zsmmPs03rsniyAX08WahSdDCGc2sLMV5m783RugeqO18mjgMuj6BMMxQ5zsmmPs03rsniyAX08WahSdDCGc2sLMV5m783RugeqO18m5kD5Ls03mnVuZZKR0LxkrFhj1GGPftZddCWo0XbkylvAEFHzN)ELYGacTMNjXWKkrFZ08snptIHjvI(osQbbtlMMhg4GDOJduduntMNVQbFDdmhWSZpFt708jsFbK57kW8mTOoZdlmnpGUsVeqR55fcnV5jfIj0AE3UPTepoqbBPsZFhm783RugeqO18mjgMuj6BMMxQ5zsmmPs03rsniyAX08MmpZ5Dg2Mhg4GDOJduWwQ08nlMD(7vkdci0AEMeqQOijcx03mnVuZZKasffjrbUOVzAEyAoSdDCGc2sLMVzXSZFVszqaHwZZKasffjXgJ(MP5LAEMeqQOijkng9ntZdtZHDOJduWwQ08nJm783RugeqO18mjgMuj6BMMxQ5zsmmPs03rsniyAX08W0iSdDCGc2sLMhU7YSZFVszqaHwZZKyysLOVzAEPMNjXWKkrFhj1GGPftZddCWo0XbkylvAE4AKzN)ELYGacTMNjXWKkrFZ08snptIHjvI(osQbbtlMMhg4GDOJduWwQ08WDvMD(7vkdci0AEMeqQOijAqCrxv4vTvzAEPMNjxv4vTvJgehtZddCWo0XbkylvAE4AoZo)9kLbbeAnptcivuKeniUORk8Q2QmnVuZZKRk8Q2QrdIJP5Hboyh64afSLknpC(cZo)9kLbbeAnptapL6kqlf9ntZl18mb8uQRaTu03rsniyAX08WahSdDCGc2sLMhoFHzN)ELYGacTMNjbKkksIgex0vfEvBvMMxQ5zYvfEvB1ObXX08WahSdDCGc2sLMhU7GzN)ELYGacTMNjGNsDfOLI(MP5LAEMaEk1vGwk67iPgemTyAEyGd2HooqbBPsZd3DWSZFVszqaHwZZKasffjrdIl6QcVQTktZl18m5QcVQTA0G4yAEyGd2HooqbBPsZ3iCm783RugeqO18mjgMuj6BMMxQ5zsmmPs03rsniyAX08WahSdDCGc2sLMVXgz25VxPmiGqR5zsmmPs03mnVuZZKyysLOVJKAqW0IP5Hboyh64afSLknFJnlMD(7vkdci0AEMedtQe9ntZl18mjgMuj67iPgemTyAEyAe2HooqbBPsZ3yZiZo)9kLbbeAnptIHjvI(MP5LAEMedtQe9DKudcMwmnpmnc7qhhOGTuP5V6Dz25VxPmiGqR5zsmmPs03mnVuZZKyysLOVJKAqW0IP5Hboyh64afSLkn)vHJzN)ELYGacTMNjXWKkrFZ08snptIHjvI(osQbbtlMMhg4GDOJduWwQ08xT5m783RugeqO18mb8uQRaTu03mnVuZZeWtPUc0srFhj1GGPftZddCWo0XbkylvA(R6lm783RugeqO18mb8uQRaTu03mnVuZZeWtPUc0srFhj1GGPftZddCWo0XbkylvA(REhm783RugeqO18mb8uQRaTu03mnVuZZeWtPUc0srFhj1GGPftZddCWo0XbkylvA(R2Sy25VxPmiGqR5zsmmPs03mnVuZZKyysLOVJKAqW0IP5Hboyh64afSLkn)vBwm783RugeqO18mb8uQRaTu03mnVuZZeWtPUc0srFhj1GGPftZddCWo0XbkylvA(RE)m783RugeqO18mjgMuj6BMMxQ5zsmmPs03rsniyAX08MmpZ5Dg2Mhg4GDOJduWwQ08nV5m783RugeqO18mjgMuj6BMMxQ5zsmmPs03rsniyAX08W0iSdDCGc2sLMV5(cZo)9kLbbeAnpt8Yddj1v03mnVuZZeV8WqsDf9DKudcMwmnVjZZCENHT5Hboyh64a1avZK55RAWx3aZbm78Z30onFI0xaz(UcmptwrmnpGUsVeqR55fcnV5jfIj0AE3UPTepoqbBPsZFvMD(7vkdci0AEMedtQe9ntZl18mjgMuj67iPgemTyAEyAe2HooqbBPsZ3CMD(7vkdci0AEMedtQe9ntZl18mjgMuj67iPgemTyAEyGd2HooqbBPsZ7lm783RugeqO18mjgMuj6BMMxQ5zsmmPs03rsniyAX08WahSdDCGc2sLMhUgz25VxPmiGqR5zsmmPs03mnVuZZKyysLOVJKAqW0IP5H5QWo0XbkylvAE4UkZo)9kLbbeAnptIHjvI(MP5LAEMedtQe9DKudcMwmnpmWb7qhhOGTuP5H7(z25VxPmiGqR5zsmmPs03mnVuZZKyysLOVJKAqW0IP5nzEMZ7mSnpmWb7qhhOGTuP5B8Um783RugeqO18mjgMuj6BMMxQ5zsmmPs03rsniyAX08MmpZ5Dg2Mhg4GDOJduWwQ08nchZo)9kLbbeAnptIHjvI(MP5LAEMedtQe9DKudcMwmnVjZZCENHT5Hboyh64afSLknFJ3bZo)9kLbbeAnpt8Yddj1v03mnVuZZeV8WqsDf9DKudcMwmnVjZZCENHT5Hboyh64a1aLVgPVacTMhUgN3Csw684Kl84avGfNCHhAkWUmaQwSbOtpG6dnfAaUqtbwZjzPbwgjMoILQeyj1GGPv4MGeAOXqtbwZjzPb2LbqD4LhoWsQbbtRWnbj0WvdnfynNKLgy7ljlnWsQbbtRWnbj0qZdnfynNKLgy7sabbx1kWsQbbtRWnbj0GVeAkWAojlnWcbx1605b8hyj1GGPv4MGeA4ocnfynNKLgyHqaobqLABGLudcMwHBcsOHMvOPalPgemTc3eyDGuiqAbw4pVRyqQPsujhOWfyfynNKLgyDggFmNKLEWjxcS4Klh1qOaRRyqQPsqcnC)HMcSMtYsdSCpeKspldGQfBakWsQbbtRWnbjibwbKkkso8ECkh3o5qfAk0aCHMcSKAqW0kCtGT6dSCscSMtYsdSmmqAqWuGLHH9OalmZdZ8WnFZEE6k9Y(EAfjKE)aYWNcSutD08qp)TZdZ8WnFZEE6k9Y(EAftL7aEIbbtNR0ZuXd5SigPJMh65VDEyMhU5B2ZtxPx23tRiV8WysKuBpapi(Nh65VDEyMhU5B2ZtxPx23tRi3tHGRADmes29ZL5HEEONFZ8Wfyxe3bYEjlnW2mP5xLYKmp3RVVaY8bwgg4Ogcfy59Kln8HUsVSVNwbj0qJHMcSKAqW0kCtGT6dSCscSMtYsdSmmqAqWuGLHH9OalmZlGurrsuGlUB8tpOCZFzEbKkksIcCXDJFCvHx1wDEOdSmmWrnekWkGurrYPukiHgUAOPalPgemTc3eyR(alNKaR5KS0alddKgemfyzyypkWcZ8civuKeLgJ7g)0dk38xMxaPIIKO0yC34hxv4vTvNh6alddCudHcScivuKCKTvqcn08qtbwsniyAfUjWw9bwojbwZjzPbwgginiykWYWWEuGfM5H)8WmVasffjrbU4UXp9GYn)L5fqQOijkWf3n(XvfEvB15HEEONhn65HzE4ppmZlGurrsuAmUB8tpOCZFzEbKkksIsJXDJFCvHx1wDEONh65rJEE6k9Y(EAfBX(73pv3X48ejXMKLgyzyGJAiuGDziwlDeqQOijiHg8LqtbwsniyAfUjWw9bwojbwZjzPbwgginiykWYWWEuGfM5zyG0GGPOasffjNsP5VmpddKgemfxgI1shbKkksMh65rJEEyMNHbsdcMIcivuKCKT18xMNHbsdcMIldXAPJasffjZd98OrppmZd38n75zyG0GGPOasffjNsP5HE(BNhM5HB(M98mmqAqWuK3tU0Wh6k9Y(EAnp0ZVzE4Mhn65HzE4MVzppddKgemffqQOi5iBR5HE(BNhM5HB(M98mmqAqWuK3tU0Wh6k9Y(EAnp0ZVzE4cSmmWrnekWkGurrYH3JtjibjWUmeRLocivuKWdnfAaUqtbwsniyAfUjWQgcfy5Lh(KTAkeiWAojlnWYlp8jB1uiqqcn0yOPalPgemTc3eyvdHcSlazRUeqhgeNt4aR5KS0a7cq2Qlb0HbX5eoiHgUAOPalPgemTc3eyvdHcSTy)97NQ7yCEIKytYsdSMtYsdSTy)97NQ7yCEIKytYsdsOHMhAkWsQbbtRWnbw1qOaRN62TuP1PfBR0KcWp8DZHct8aR5KS0aRN62TuP1PfBR0KcWp8DZHct8GeAWxcnfyj1GGPv4MaRAiuGLGukV8WhgPJcSMtYsdSeKs5Lh(WiDuqcsGDryZpTocivuKWdnfAaUqtbwsniyAfUjWAojlnWsi9(bKHpfyPM6OaRdKcbslWcZ8UIbPMkrnB3LtNrZFzExv4vTvJ8YdFaLebeILkFEynFJ3DEONhn65HzExXGutLidsLD)G5VmVRk8Q2QXePN0vQThNjgxav)ofbeILkFEynFJ3DEONhn65HzExXGutLOsoqHlWAE0ON3vmi1ujIYpinDE0ON3vmi1ujQLsZdDGvnekWsi9(bKHpfyPM6OGeAOXqtbwsniyAfUjWAojlnWY9ui4QwhdHKD)CjW6aPqG0cSWmVRyqQPsuZ2D50z08xM3vfEvB1iV8WhqjraHyPYNhwZFhZd98OrppmZ7kgKAQezqQS7hm)L5DvHx1wnMi9KUsT94mX4cO63PiGqSu5ZdR5VJ5HEE0ONhM5DfdsnvIk5afUaR5rJEExXGutLik)G005rJEExXGutLOwknp0bw1qOal3tHGRADmes29ZLGeA4QHMcSKAqW0kCtG1CswAGLxEymjsQThGhe)bwhifcKwGfM5DfdsnvIA2UlNoJM)Y8UQWRARg5Lh(akjcielv(8WA(7FEONhn65HzExXGutLidsLD)G5VmVRk8Q2QXePN0vQThNjgxav)ofbeILkFEyn)9pp0ZJg98WmVRyqQPsujhOWfynpA0Z7kgKAQer5hKMopA0Z7kgKAQe1sP5HoWQgcfy5LhgtIKA7b4bXFqcn08qtbwsniyAfUjWAojlnWY3TvTLwNca5uDhPaiKkbwhifcKwGfM5DfdsnvIA2UlNoJM)Y8UQWRARg5Lh(akjcielv(8WA(Mpp0ZJg98WmVRyqQPsKbPYUFW8xM3vfEvB1yI0t6k12JZeJlGQFNIacXsLppSMV5Zd98OrppmZ7kgKAQevYbkCbwZJg98UIbPMkru(bPPZJg98UIbPMkrTuAEOdSQHqbw(UTQT06uaiNQ7ifaHujibjW6kgKAQeAk0aCHMcSKAqW0kCtG1bsHaPfyH)8IHjvI97MkfYHNARh2aP4psQbbtR5VmpmZ7QcVQTAK7HGu6zzauTydqraHyPYNhwZd3DNhn65DvHx1wnY9qqk9SmaQwSbOiGqSu5ZdV59L7opA0Z7QcVQTAK7HGu6zzauTydqraHyPYNhEZ3OVm)L5DLU8sj6kaWRxsT9Gjcej1GGP18qhynNKLgytKEsxP2ECMyCbu97uqcn0yOPalPgemTc3eyDGuiqAbwXWKkX(DtLc5WtT1dBGu8hj1GGP18xMFvsSF3uPqo8uB9Wgif)rjDOsTnWAojlnWMi9KUsT94mX4cO63PGeA4QHMcSKAqW0kCtG1bsHaPfyDvHx1wnY9qqk9SmaQwSbOiGqSu5ZdV59L5VmpmZViiEDDXDZtLiGqSu5ZdV5B(8Orpp8NxmmPsC38ujsQbbtR5HoWAojlnWUixIysQThifwcsOHMhAkWsQbbtRWnbwhifcKwGf(ZlgMuj2VBQuihEQTEydKI)iPgemTM)Y8WmVRk8Q2QrUhcsPNLbq1InafbeILkFEynVVmpA0Z7QcVQTAK7HGu6zzauTydqraHyPYNhEZ7l3DE0ON3vfEvB1i3dbP0ZYaOAXgGIacXsLpp8MVrFz(lZ7kD5Ls0vaGxVKA7bteisQbbtR5HoWAojlnWYlp8busqcn4lHMcSKAqW0kCtG1bsHaPfyfdtQe73nvkKdp1wpSbsXFKudcMwZFz(vjX(DtLc5WtT1dBGu8hL0Hk12aR5KS0alV8Whqjbj0WDeAkWAojlnWYDLhi12JKYofyj1GGPv4MGeKa7QKtpG6dnfAaUqtbwsniyAfUjW6aPqG0cSRsIwBP(JacXsLppSM)(N)Y8UQWRARg5EiiLEwgavl2aueqiwQ85H38RsIwBP(JacXsLhynNKLgyT2s9hKqdngAkWsQbbtRWnbwhifcKwGDvsKN97LEWzhfbeILkFEyn)9p)L5DvHx1wnY9qqk9SmaQwSbOiGqSu5ZdV5xLe5z)EPhC2rraHyPYdSMtYsdS8SFV0do7OGeA4QHMcSKAqW0kCtG1bsHaPfyxLe9uUyqW0X66WPtYsJacXsLppSM)(N)Y8UQWRARg5EiiLEwgavl2aueqiwQ85H38RsIEkxmiy6yDD40jzPraHyPYdSMtYsdSEkxmiy6yDD40jzPbj0qZdnfyj1GGPv4MaRdKcbslWUkj6kaWRxYsJacXsLppSM)(N)Y8UQWRARg5EiiLEwgavl2aueqiwQ85H38RsIUca86LS0iGqSu5bwZjzPbwxbaE9swAqcsGDrDMhwcnfAaUqtbwZjzPbwEpHXhC5qfyj1GGPv4MGeAOXqtbwZjzPb2fXO8aheRnDbwsniyAfUjiHgUAOPalPgemTc3eyDGuiqAbwZjjd6qkHKeFE4n)vdSCbKoj0aCbwZjzPbwNHXhZjzPhCYLalo5YrnekWAffKqdnp0uGLudcMwHBcSlI7azVKLgyzEojlDECYf(8DfyEbKkksMhcTBmYceNNvmHpVbO55gdAnFxbMhc1vaAE2YdpVVQKR91i9KUsTD(7zIXfq1VtxZC3nvkK5ztT1dBGu87Z8LStGTjNMV05DvHx1wnWAojlnW6mm(yojl9GtUeyXjxoQHqbwbKkkso8ECkh3o5qfKqd(sOPalPgemTc3eynNKLgyDggFmNKLEWjxcS4Klh1qOa7IWMFADeqQOiHhKqd3rOPalPgemTc3eyDGuiqAbwyMFvsKxE4dOKOKouP2opA0ZVkjMi9KUsT94mX4cO63PZQKOKouP2opA0ZVkj2VBQuihEQTEydKI)OKouP2op0ZFzEE5Hp8DdSMhEZF15rJE(vjrgjMoILQeL0Hk125rJEEXWKkrET9i70Ht0Ihj1GGPvGLlG0jHgGlWAojlnW6mm(yojl9GtUeyXjxoQHqbwUyYraPIIeEqcn0Scnfyj1GGPv4MaRdKcbslW6kgKAQe1SDxoDgn)L5HzE4ppddKgemffqQOi5W7XPmpA0Z7QcVQTAKxE4dOKiGqSu5ZdV5B8UZJg98WmpddKgemffqQOi5ukn)L5DvHx1wnYlp8buseqiwQ85H18civuKef4IUQWRARgbeILkFEONhn65HzEgginiykkGurrYr2wZFzExv4vTvJ8YdFaLebeILkFEynVasffjrPXORk8Q2QraHyPYNh65HEE0ON3vmi1ujYGuz3py(lZdZ8WFEgginiykkGurrYH3JtzE0ON3vfEvB1yI0t6k12JZeJlGQFNIacXsLpp8MVX7opA0ZdZ8mmqAqWuuaPIIKtP08xM3vfEvB1yI0t6k12JZeJlGQFNIacXsLppSMxaPIIKOax0vfEvB1iGqSu5Zd98OrppmZZWaPbbtrbKkksoY2A(lZ7QcVQTAmr6jDLA7XzIXfq1VtraHyPYNhwZlGurrsuAm6QcVQTAeqiwQ85HEEONhn65HzExXGutLOsoqHlWAE0ON3vmi1ujIYpinDE0ON3vmi1ujQLsZd98xMhM5H)8mmqAqWuuaPIIKdVhNY8OrpVRk8Q2QX(DtLc5WtT1dBGu8hbeILkFE4nFJ3DE0ONhM5zyG0GGPOasffjNsP5VmVRk8Q2QX(DtLc5WtT1dBGu8hbeILkFEynVasffjrbUORk8Q2QraHyPYNh65rJEEyMNHbsdcMIcivuKCKT18xM3vfEvB1y)UPsHC4P26Hnqk(JacXsLppSMxaPIIKO0y0vfEvB1iGqSu5Zd98qppA0Zd)5fdtQe73nvkKdp1wpSbsXFKudcMwZFzEyMh(ZZWaPbbtrbKkkso8ECkZJg98UQWRARg5EiiLEwgavl2aueqiwQ85H38nE35rJEEyMNHbsdcMIcivuKCkLM)Y8UQWRARg5EiiLEwgavl2aueqiwQ85H18civuKef4IUQWRARgbeILkFEONhn65HzEgginiykkGurrYr2wZFzExv4vTvJCpeKspldGQfBakcielv(8WAEbKkksIsJrxv4vTvJacXsLpp0ZdDG1CswAG1zy8XCsw6bNCjWItUCudHcSldXAPJasffj8GeA4(dnfyj1GGPv4MaR5KS0alIHPU0DawV4bOa7I4oq2lzPb2B8a688YdppF3al(8z38Dz7UmFYN3WifxMVyqGaRdKcbslWcP485VmFx2UlhaHyPYNhwZtWo58e6ijcnFZEEE5Hp8DdSM)Y8RsIEkxmiy6yDD40jzPrjDOsTniHgAgdnfyj1GGPv4Ma7I4oq2lzPbwFD38UIbPMkZVk5AM7UPsHmpBQTEydKI)5t(8apvtT1N594083Nbq1InanVuZtWUq6AEzNM35baKkZZjjWAojlnW6mm(yojl9GtUeyDGuiqAbwyM3vmi1ujYGuz3py(lZVkjMi9KUsT94mX4cO63PZQKOKouP2o)L5DvHx1wnY9qqk9SmaQwSbOiGqSu5ZdR5BC(lZdZ8RsI97MkfYHNARh2aP4pcielv(8WB(gNhn65H)8IHjvI97MkfYHNARh2aP4psQbbtR5HEEONhn65HzExXGutLOMT7YPZO5Vm)QKiV8WhqjrjDOsTD(lZ7QcVQTAK7HGu6zzauTydqraHyPYNhwZ348xMhM5xLe73nvkKdp1wpSbsXFeqiwQ85H38nopA0Zd)5fdtQe73nvkKdp1wpSbsXFKudcMwZd98qppA0ZdZ8WmVRyqQPsujhOWfynpA0Z7kgKAQer5hKMopA0Z7kgKAQe1sP5HE(lZVkj2VBQuihEQTEydKI)OKouP2o)L5xLe73nvkKdp1wpSbsXFeqiwQ85H18nop0bwCYLJAiuGDzauTydqNEa1hKqdWD3qtbwsniyAfUjWUiUdK9swAG1xrDaIVp)Qe(8KbW(Np7MVTsTD(uLAEBE(UbwZZ7jDLA7897gNcSMtYsdSodJpMtYsp4KlbwhifcKwGfM5DfdsnvIA2UlNoJM)Y8WF(vjrE5HpGsIs6qLA78xM3vfEvB1iV8WhqjraHyPYNhwZ385HEE0ONhM5DfdsnvImiv29dM)Y8WF(vjXePN0vQThNjgxav)oDwLeL0Hk125VmVRk8Q2QXePN0vQThNjgxav)ofbeILkFEynFZNh65rJEEyMhM5DfdsnvIk5afUaR5rJEExXGutLik)G005rJEExXGutLOwknp0ZFzEXWKkX(DtLc5WtT1dBGu8hj1GGP18xMh(ZVkj2VBQuihEQTEydKI)OKouP2o)L5DvHx1wn2VBQuihEQTEydKI)iGqSu5ZdR5B(8qhyXjxoQHqb2vjNEa1hKqdWbxOPalPgemTc3eynNKLgyxga1HxE4a7I4oq2lzPbwFD38m3DtLczE2uB9Wgif)ZN85L0Hk1wFMpL5t(8CRJMxQ594083NbqnpB5HdSoqkeiTa7QKy)UPsHC4P26Hnqk(Js6qLABqcnaxJHMcSKAqW0kCtG1bsHaPfyH)8IHjvI97MkfYHNARh2aP4psQbbtR5VmpmZVkjYlp8busushQuBNhn65xLetKEsxP2ECMyCbu970zvsushQuBNh6aR5KS0a7YaOo8YdhKqdWD1qtbwsniyAfUjWAojlnW2VBQuihEQTEydKI)a7I4oq2lzPbww)QBEM7UPsHmpBQTEydKI)53MY(8mhjv29dUUHSDxMVzOrZ7kgKAQm)QeFMVKDcSn508ECA(sN3vfEvB148(6U5zor69didp)DgSutD08q866Mp5ZNQRqsT1N53l8AEpvs88PWeFEazl)ZddC3)8CYv6IpV1jeyEpobDG1bsHaPfyDfdsnvIA2UlNoJM)Y8sIqZdV59L5VmVRk8Q2QrE5HpGsIacXsLppSMhU5VmpmZ7QcVQTAKq69didFkWsn1rraHyPYNhwZd3D048Orpp8NNUsVSVNwrcP3pGm8Pal1uhnp0bj0aCnp0uGLudcMwHBcSoqkeiTaRRyqQPsKbPYUFW8xMxseAE4nVVm)L5DvHx1wnMi9KUsT94mX4cO63PiGqSu5ZdR5HB(lZdZ8UQWRARgjKE)aYWNcSutDueqiwQ85H18WDhnopA0Zd)5PR0l77PvKq69didFkWsn1rZdDG1CswAGTF3uPqo8uB9Wgif)bj0aC(sOPalPgemTc3eynNKLgy73nvkKdp1wpSbsXFGDrChi7LS0aBdKdu4cSMFBk7ZZ8nm1LU5BMat2N3zCHpF)UPsHmpp1wpSbsX)8PopovA(TPSp)9rUeXKuBN)MclbwhifcKwG1vmi1ujQKdu4cSM)Y8apL6kqlfrmm1LUZwGj7rsniyAn)L5LeHMhEZ7lZFzExv4vTvJlYLiMKA7bsHLiGqSu5ZdR5V68xMhM5DvHx1wnsi9(bKHpfyPM6OiGqSu5ZdR5H7oACE0ONh(ZtxPx23tRiH07hqg(uGLAQJMh6GeAaU7i0uGLudcMwHBcSMtYsdS97MkfYHNARh2aP4pWUiUdK9swAG9ol7eyExXGutf(8WKQd7TsTDET0RG53mNVbYbkON3zCzEMl78LoVRk8Q2QbwhifcKwGfM5DfdsnvIO8dstNhn65DfdsnvIAP08OrppmZ7kgKAQevYbkCbwZFzE4ppWtPUc0sredtDP7SfyYEKudcMwZd98qp)L5HzExv4vTvJesVFaz4tbwQPokcielv(8WAE4UJgNhn65H)80v6L990ksi9(bKHpfyPM6O5HoiHgGRzfAkWsQbbtRWnbwhifcKwGfsX5ZFz(USDxoacXsLppSMhU7iWAojlnW2VBQuihEQTEydKI)GeAaU7p0uGLudcMwHBcSlI7azVKLgy91DZZC3nvkK5ztT1dBGu8pFYNxshQuB9z(uyIpVKi08snVhNMVKDcmpI1mOaZVkHhynNKLgyDggFmNKLEWjxcSoqkeiTa7QKy)UPsHC4P26Hnqk(Js6qLA78xMhM5DfdsnvIA2UlNoJMhn65DfdsnvImiv29dMh6alo5YrnekW6kgKAQeKqdW1mgAkWsQbbtRWnbwZjzPbwRTu)bwhifcKwGDvs0Al1FeqiwQ85H18npW687W0rmqlj8qdWfKqdnE3qtbwZjzPb2DZtLalPgemTc3eKqdncxOPalPgemTc3eynNKLgy5eTov3XvaGxVKLgyxe3bYEjlnWYwBNx2P5zjAXNV05V68IbAjHpF2nFkZNCLjzENhaqQG9pFQZ3HZ2Dz(cmFPZl708IbAjjoFZmL95zZ(9sNh2YoA(uyIpVH518qiriW8snVhNMNLO18fdcmpIPEgg7FERVh7p125V683RaaVEjlLhdSoqkeiTaR5KKbDiLqsIpp8MVX5VmVyysLiV2EKD6WjAXJKAqW0A(lZd)5xLe5eTov3XvaGxVKLgL0Hk125Vmp8Np1thoB3LGeAOXgdnfyj1GGPv4MaRdKcbslWAojzqhsjKK4ZdV5BC(lZlgMujYZ(9sp4SJIKAqW0A(lZd)5xLe5eTov3XvaGxVKLgL0Hk125Vmp8Np1thoB3L5Vm)QKORaaVEjlncielv(8WA(MhynNKLgy5eTov3XvaGxVKLgKqdnE1qtbwsniyAfUjW6aPqG0cSWmpV8Wh(UbwZdV5HBE0ON3CsYGoKsijXNhEZ348qp)L5DvHx1wnY9qqk9SmaQwSbOiGqSu5ZdV5HRXaR5KS0alJethXsvcsOHgBEOPalPgemTc3eyDGuiqAbwZjjd6Skj6PCXGGPJ11HtNKLo)M5V78OrpVKouP2o)L5xLe9uUyqW0X66WPtYsJacXsLppSMV5bwZjzPbwpLlgemDSUoC6KS0GeAOrFj0uGLudcMwHBcSMtYsdS8SFV0do7OaRdKcbslWUkjYZ(9sp4SJIacXsLppSMV5bwNFhMoIbAjHhAaUGeAOX7i0uGLudcMwHBcSoqkeiTal8N3vmi1ujQKdu4cScSCbKoj0aCbwZjzPbwNHXhZjzPhCYLalo5YrnekW6kgKAQeKqdn2Scnfyj1GGPv4MaR5KS0aRRaaVEjlnW687W0rmqlj8qdWfyDGuiqAbwZjjd6qkHKeFEynFZN)kMhM5fdtQe512JSthorlEKudcMwZJg98IHjvI8SFV0do7OiPgemTMh65Vm)QKORaaVEjlncielv(8WA(gdSlI7azVKLgyzE99y)ZFVca86LS05rm1ZWy)Zx68WDfnoVyGws4(mFbMV05V68BtzFEMheEH9eA(7vaGxVKLgKqdnE)HMcSKAqW0kCtG1CswAGfXWux6oaRx8auGDrChi7LS0alZRtiW8YonF1tkb8zEEpPR5T557gyn)2DsN3K59L5lDEMVHPU0nVVY6fpanVuZBmQCnFXGaoRVp12aRdKcbslWYlp8HVBG18WB(Mp)L5LeHMhEZ3iCbj0qJnJHMcSKAqW0kCtGDrChi7LS0aBZCN051sMN7xDP2opZD3uPqMNn1wpSbsX)8snpZrsLD)GRBiB3L5BgAKpZZ6HGu683Nbq1InanF2nVHXZVkHpVbO5T(ECsRaR5KS0aRZW4J5KS0do5sG1bsHaPfyHzExXGutLidsLD)G5Vmp8NxmmPsSF3uPqo8uB9Wgif)rsniyAn)L5xLetKEsxP2ECMyCbu970zvsushQuBN)Y8UQWRARg5EiiLEwgavl2aueq2Y)8qppA0ZdZ8UIbPMkrnB3LtNrZFzE4pVyysLy)UPsHC4P26Hnqk(JKAqW0A(lZVkjYlp8busushQuBN)Y8UQWRARg5EiiLEwgavl2aueq2Y)8qppA0ZdZ8WmVRyqQPsujhOWfynpA0Z7kgKAQer5hKMopA0Z7kgKAQe1sP5HE(lZ7QcVQTAK7HGu6zzauTydqrazl)ZdDGfNC5Ogcfyxgavl2a0Phq9bj0WvVBOPalPgemTc3eynNKLgyxga1HxE4a7I4oq2lzPb27uon)9zauZZwE45ZU5VpdGQfBaA(TLYKmpeAEazl)ZBTwQ(mFbMp7Mx2jan)2eJNhcnVjZJjJlZ348ifGM)(maQwSbO594epW6aPqG0cSqkoF(lZ7QcVQTAK7HGu6zzauTydqraHyPYNhEZ3LT7YbqiwQ85VmpmZd)5fdtQe73nvkKdp1wpSbsXFKudcMwZJg98UQWRARg73nvkKdp1wpSbsXFeqiwQ85H38Dz7UCaeILkFEOdsOHRcxOPalPgemTc3eyDGuiqAbwifNp)L5H)8IHjvI97MkfYHNARh2aP4psQbbtR5VmVRk8Q2QrUhcsPNLbq1InafbeILkF(BN3vfEvB1i3dbP0ZYaOAXgGIlpGjzPZdR57Y2D5aielvEG1CswAGDzauhE5HdsOHR2yOPalPgemTc3eyxe3bYEjlnWEptC7xHHXZNcHmVh3AP57kW8M6x2tTDETK559Kl7sAnpH502DcqbwZjzPbwNHXhZjzPhCYLalo5YrnekWMcHeKqdx9QHMcSKAqW0kCtG1bsHaPfyfdtQe572Q2EieiaZrrsniyAn)L5Hz(fbXRRlY3TvT9qiqaMJICXCOMhwZdZ8no)vmV5KS0iF3w12dKclXupD4SDxMh65rJE(fbXRRlY3TvT9qiqaMJIacXsLppSM)QZdDG1CswAG1zy8XCsw6bNCjWItUCudHcSCkiHgUAZdnfyj1GGPv4MaR5KS0alIHPU0DawV4bOa7I4oq2lzPb27uonpZ3Wux6M3xz9IhGMF7oPZJyndkW8Rs4ZBaAEVEFMVaZNDZl7eGMFBIXZdHMNNTA2LotL5LeHM3tLepVStZReSlZZC3nvkK5ztT1dBGu8hN3x3nVNK48orQTZZ8nm1LU5BMat29z(9cVM3MNVBG18snpG6aeFFEzNMhIxxxG1bsHaPfyHz(vjrgjMoILQeL0Hk125rJE(vjXePN0vQThNjgxav)oDwLeL0Hk125rJE(vjrE5HpGsIs6qLA78qp)L5HzE4ppWtPUc0sredtDP7SfyYEKudcMwZJg98q866IigM6s3zlWK9ixmhQ5H18xDE0ONNxE4dF3aR5H38Wnp0bj0Wv9LqtbwsniyAfUjWAojlnWIyyQlDhG1lEakWUiUdK9swAG9oLtZZ8nm1LU59vwV4bO5LAEelvXsDEzNMhXWux6MFlWK95H411nVNkjEE(Ubw85vIwZl18qO5BjLaMqR57kW8YonVsWUmpepaxMFBQRA78W04DNNtUsx85t(8ifGMx2nDEUxxx6ssL5LA(wsjGj08xDE(UbwCOdSoqkeiTalWtPUc0sredtDP7SfyYEKudcMwZFzExv4vTvJ8YdFaLebeILkFE4nFJ3D(lZdXRRlIyyQlDNTat2JacXsLppSMV5bj0WvVJqtbwsniyAfUjWAojlnWIyyQlDhG1lEakWUiUdK9swAGL5BPkwQZZ8nm1LU5BMat2N3K5nmEEjri(8DfyEzNMVbYbkCbwZxG5zoKFqA68UIbPMkbwhifcKwGf4PuxbAPiIHPU0D2cmzpsQbbtR5VmpmZ7kgKAQevYbkCbwZJg98UIbPMkru(bPPZd98xMhIxxxeXWux6oBbMShbeILkFEynFZdsOHR2Scnfyj1GGPv4MaR5KS0alIHPU0DawV4bOa7I4oq2lzPb27uonpZ3Wux6M3xz9IhGMV05zU7MkfY8SP26Hnqk(N3zCH7Z8igQuBNN7bO5LAEUXGM3MNVBG18snpxmhQ5z(gM6s38ntGj7ZNDZ7XtTD(ucSoqkeiTaRyysLy)UPsHC4P26Hnqk(JKAqW0A(lZdZ8RsI97MkfYHNARh2aP4pkPdvQTZJg98UQWRARg73nvkKdp1wpSbsXFeqiwQ85H38n6lZJg98qkoF(lZljcDK6SsAEynVRk8Q2QX(DtLc5WtT1dBGu8hbeILkFEON)Y8Wmp8Nh4PuxbAPiIHPU0D2cmzpsQbbtR5rJEEiEDDredtDP7SfyYEKlMd18WA(RopA0ZZlp8HVBG18WBE4Mh6GeA4Q3FOPalPgemTc3eyDGuiqAbwXWKkrET9i70Ht0Ihj1GGPvG1CswAGfXWux6oaRx8auqcnC1MXqtbwsniyAfUjWAojlnWUawQhC2rb2fXDGSxYsdS3hWsDEyl7O5t(8LI9pVn)9XCzNV1sD(TPSpVVwjgPyqW083hHKCAELmW8igSppxmhkECEFD38Dz7UmFYN3GuEY8snpPR5x18AjZJKC(88EsxP2oVStZZfZHIhyDGuiqAbwiEDDXujgPyqW0zrijNICXCOMhEZ387opA0ZdXRRlMkXifdcMolcj5u0RF(lZdP485VmFx2UlhaHyPYNhwZ38GeAO53n0uGLudcMwHBcSMtYsdSodJpMtYsp4KlbwCYLJAiuG1vmi1ujiHgAoCHMcSKAqW0kCtG1CswAG1Al1FG1bsHaPfybuhG47gemfyD(Dy6igOLeEOb4csOHM3yOPalPgemTc3eyDGuiqAbwZjjd6Skj6PCXGGPJ11HtNKLo)M5V78OrpVKouP2o)L5buhG47gemfynNKLgy9uUyqW0X66WPtYsdsOHMF1qtbwsniyAfUjWAojlnWYZ(9sp4SJcSoqkeiTalG6aeF3GGPaRZVdthXaTKWdnaxqcn08MhAkWsQbbtRWnbwZjzPbwxbaE9swAG1bsHaPfybuhG47gemn)L5nNKmOdPess85H18nF(RyEyMxmmPsKxBpYoD4eT4rsniyAnpA0ZlgMujYZ(9sp4SJIKAqW0AEOdSo)omDed0scp0aCbj0qZ9LqtbwsniyAfUjWAojlnW2Hj(UdyDsG1bsHaPfy5LhgsQRiJcBsIPdVWmivIKAqW0kWMQqaGxVCYUaleVUUiJcBsIPdVWmivIE9bj0qZVJqtb2ufca86LalCbwZjzPb2fWs9WlpCGLudcMwHBcsOHM3ScnfynNKLgy572Q2EGuyjWsQbbtRWnbjib2Ea5keiMeAk0aCHMcSKAqW0kCtG1bsHaPfyLeHMhEZF35Vmp8NVNKOHtg08xMh(ZdXRRl2csKkb0P6oCZbYU0rrV(aR5KS0aBhHpRcjvtYsdsOHgdnfynNKLgy5EiiLE6i8UNkeiWsQbbtRWnbj0Wvdnfyj1GGPv4MaRAiuGvke6uDhKs5cO84hxPCb45KSuEG1CswAGvke6uDhKs5cO84hxPCb45KSuEqcn08qtbwsniyAfUjWQgcfy5fMSD(HtoajhHC7AELEuG1CswAGLxyY25ho5aKCeYTR5v6rbj0GVeAkWsQbbtRWnbwhifcKwGvmmPsSfKivcOt1D4MdKDPJIKAqW0kWAojlnW2csKkb0P6oCZbYU0rbj0WDeAkWAojlnW2Hj(UdyDsGLudcMwHBcsOHMvOPalPgemTc3eyR(alNKaR5KS0alddKgemfyzyypkWAojzqNvjrxbaE9sw68WB(7o)L5nNKmOZQKO1wQ)5H383D(lZBojzqNvjrpLlgemDSUoC6KS05H383D(lZdZ8WFEXWKkrE2Vx6bNDuKudcMwZJg98Mtsg0zvsKN97LEWzhnp8M)UZd98xMhM5xLe73nvkKdp1wpSbsXFushQuBNhn65H)8IHjvI97MkfYHNARh2aP4psQbbtR5HoWYWah1qOa7Qe(bq2YFqcnC)HMcSKAqW0kCtGvnekWA3j47gW4NUsLt1D6RTeiWAojlnWA3j47gW4NUsLt1D6RTeiiHgAgdnfyj1GGPv4MaR5KS0alNO1P6oUca86LS0aRdKcbslWY7jm(igOLeEKt06uDhxbaE9sw6XkAE4Tz(RgyXPsh3kWc3DdsOb4UBOPaR5KS0a7U5PsGLudcMwHBcsOb4Gl0uG1CswAG1t5IbbthRRdNojlnWsQbbtRWnbjibwROqtHgGl0uG1CswAGTF3uPqo8uB9Wgif)bwsniyAfUjiHgAm0uG1CswAGD38ujWsQbbtRWnbj0Wvdnfyj1GGPv4MaRdKcbslW6kgKAQezqQS7hm)L5xLetKEsxP2ECMyCbu970zvsushQuBN)Y8UQWRARg5EiiLEwgavl2aueq2Y)8xMhM5xLe73nvkKdp1wpSbsXFeqiwQ85H38nopA0Zd)5fdtQe73nvkKdp1wpSbsXFKudcMwZd98OrpVRyqQPsuZ2D50z08xMFvsKxE4dOKOKouP2o)L5DvHx1wnY9qqk9SmaQwSbOiGSL)5VmpmZVkj2VBQuihEQTEydKI)iGqSu5ZdV5BCE0ONh(ZlgMuj2VBQuihEQTEydKI)iPgemTMh65rJEEyM3vmi1ujQKdu4cSMhn65DfdsnvIO8dstNhn65DfdsnvIAP08qp)L5xLe73nvkKdp1wpSbsXFushQuBN)Y8RsI97MkfYHNARh2aP4pcielv(8WA(gdSMtYsdSodJpMtYsp4KlbwCYLJAiuGDzauTydqNEa1hKqdnp0uGLudcMwHBcSoqkeiTaRyysLiV2EKD6WjAXJKAqW0A(lZ7m9WjAfynNKLgy5eTov3XvaGxVKLgKqd(sOPalPgemTc3eyDGuiqAbw4pVyysLiV2EKD6WjAXJKAqW0A(lZd)5xLe5eTov3XvaGxVKLgL0Hk125Vmp8Np1thoB3L5Vm)QKORaaVEjlncOoaX3niykWAojlnWYjADQUJRaaVEjlniHgUJqtbwsniyAfUjWAojlnWATL6pW6aPqG0cSMtsg0zvs0Al1)8WA(Mp)L5H)8RsIwBP(Js6qLABG153HPJyGws4HgGliHgAwHMcSKAqW0kCtG1CswAG1Al1FG1bsHaPfynNKmOZQKO1wQ)5H3M5B(8xMhqDaIVBqW08xMFvs0Al1FushQuBdSo)omDed0scp0aCbj0W9hAkWsQbbtRWnbwhifcKwG1CsYGoRsIEkxmiy6yDD40jzPZVz(7opA0ZlPdvQTZFzEa1bi(UbbtbwZjzPbwpLlgemDSUoC6KS0GeAOzm0uGLudcMwHBcSMtYsdSEkxmiy6yDD40jzPbwhifcKwGf(ZlPdvQTZFz(Eg9IHjvIadP3u5yDD40jzP8iPgemTM)Y8Mtsg0zvs0t5IbbthRRdNojlDEyn)vdSo)omDed0scp0aCbj0aC3n0uGLudcMwHBcSoqkeiTalV8Wh(UbwZdV5HlWAojlnWYiX0rSuLGeAao4cnfyj1GGPv4MaRdKcbslWc)5DfdsnvIk5afUaRalxaPtcnaxG1CswAG1zy8XCsw6bNCjWItUCudHcSUIbPMkbj0aCngAkWsQbbtRWnbwhifcKwGfM5DfdsnvImiv29dM)Y8WmVRk8Q2QXePN0vQThNjgxav)ofbKT8ppA0ZVkjMi9KUsT94mX4cO63PZQKOKouP2op0ZFzExv4vTvJCpeKspldGQfBakciB5F(lZdZ8RsI97MkfYHNARh2aP4pcielv(8WB(gNhn65H)8IHjvI97MkfYHNARh2aP4psQbbtR5HEEON)Y8WmpmZ7kgKAQevYbkCbwZJg98UIbPMkru(bPPZJg98UIbPMkrTuAEON)Y8UQWRARg5EiiLEwgavl2aueqiwQ85H18no)L5Hz(vjX(DtLc5WtT1dBGu8hbeILkFE4nFJZJg98WFEXWKkX(DtLc5WtT1dBGu8hj1GGP18qpp0ZJg98WmVRyqQPsuZ2D50z08xMhM5DvHx1wnYlp8buseq2Y)8Orp)QKiV8WhqjrjDOsTDEON)Y8UQWRARg5EiiLEwgavl2aueqiwQ85H18no)L5Hz(vjX(DtLc5WtT1dBGu8hbeILkFE4nFJZJg98WFEXWKkX(DtLc5WtT1dBGu8hj1GGP18qpp0bwZjzPbwNHXhZjzPhCYLalo5YrnekWUmaQwSbOtpG6dsOb4UAOPalPgemTc3eyDGuiqAbwifNp)L5DvHx1wnY9qqk9SmaQwSbOiGqSu5ZdV57Y2D5aielv(8xMhM5H)8IHjvI97MkfYHNARh2aP4psQbbtR5rJEExv4vTvJ97MkfYHNARh2aP4pcielv(8WB(USDxoacXsLpp0bwZjzPb2LbqD4LhoiHgGR5HMcSKAqW0kCtG1bsHaPfyHuC(8xM3vfEvB1i3dbP0ZYaOAXgGIacXsLp)TZ7QcVQTAK7HGu6zzauTydqXLhWKS05H18Dz7UCaeILkpWAojlnWUmaQdV8Wbj0aC(sOPalPgemTc3eynNKLgyDggFmNKLEWjxcS4Klh1qOaBkesqcna3DeAkWsQbbtRWnbwZjzPbwNHXhZjzPhCYLalo5YrnekWUiS5NwhbKkks4bj0aCnRqtbwsniyAfUjWAojlnW6mm(yojl9GtUeyXjxoQHqb2LHyT0raPIIeEqcna39hAkWsQbbtRWnbwhifcKwGDvsSF3uPqo8uB9Wgif)rjDOsTDE0ONh(ZlgMuj2VBQuihEQTEydKI)iPgemTcSMtYsdSodJpMtYsp4KlbwCYLJAiuGLlMCeqQOiHhKqdW1mgAkWsQbbtRWnbwhifcKwGDvsKrIPJyPkrjDOsTnWAojlnWIyyQlDhG1lEakiHgA8UHMcSKAqW0kCtG1bsHaPfyxLe5Lh(akjkPdvQTZFzE4pVyysLiV2EKD6WjAXJKAqW0kWAojlnWIyyQlDhG1lEakiHgAeUqtbwsniyAfUjW6aPqG0cSWFEXWKkrgjMoILQej1GGPvG1CswAGfXWux6oaRx8auqcn0yJHMcSKAqW0kCtG1bsHaPfy5Lh(W3nWAE4nFZdSMtYsdSigM6s3by9IhGcsOHgVAOPalPgemTc3eynNKLgy5z)EPhC2rbwhifcKwG1CsYGoRsI8SFV0do7O5H1M5V68xMhqDaIVBqW08xMh(ZVkjYZ(9sp4SJIs6qLABG153HPJyGws4HgGliHgAS5HMcSKAqW0kCtG1bsHaPfyDfdsnvIk5afUaRalxaPtcnaxG1CswAG1zy8XCsw6bNCjWItUCudHcSUIbPMkbj0qJ(sOPalPgemTc3eyDGuiqAbwiEDDXujgPyqW0zrijNICXCOMhEBM3xU78OrppKIZN)Y8q866IPsmsXGGPZIqsof96N)Y8Dz7UCaeILkFEynVVmpA0ZdXRRlMkXifdcMolcj5uKlMd18WBZ8x1xM)Y8RsI8YdFaLeL0Hk12aR5KS0a7cyPEWzhfKqdnEhHMcSKAqW0kCtG1CswAGTdt8DhW6KaRdKcbslWYlpmKuxrgf2KethEHzqQej1GGPvGnvHaaVE5KDbwiEDDrgf2KethEHzqQe96dsOHgBwHMcSPkea41lbw4cSMtYsdSlGL6HxE4alPgemTc3eKqdnE)HMcSMtYsdS8DBvBpqkSeyj1GGPv4MGeKaBkesOPqdWfAkWAojlnW6XPtkecpWsQbbtRWnbjibwofAk0aCHMcSMtYsdS7MNkbwsniyAfUjiHgAm0uGLudcMwHBcSPkea41lNSlWUiiEDDr(UTQThcbcWCuKlMdf82C1aR5KS0a7cyPE4LhoWMQqaGxVCAXfedhyHliHgUAOPaR5KS0alF3w12dKclbwsniyAfUjibjWYftocivuKWdnfAaUqtbwsniyAfUjWQgcfytL7aEIbbtNR0ZuXd5SigPJcSMtYsdSPYDapXGGPZv6zQ4HCweJ0rbj0qJHMcSKAqW0kCtGvnekWMkxaEoPa8ZkzKkDGqyCG1CswAGnvUa8Csb4NvYiv6aHW4GeA4QHMcSKAqW0kCtGvnekWwmiqhU2MA7X0eXooRLcSMtYsdSfdc0HRTP2EmnrSJZAPGeAO5HMcSKAqW0kCtGvnekWUmakKQ0ZICOo9EcG4osDuG1CswAGDzauivPNf5qD69eaXDK6OGeAWxcnfyj1GGPv4MaRAiuGfXCgeaD47ejhepE6cSMtYsdSiMZGaOdFNi5G4XtxqcnChHMcSKAqW0kCtGvnekW2Hne6uDhiMiykWAojlnW2Hne6uDhiMiykiHgAwHMcSKAqW0kCtGvnekWU1qrkb4NoqPRaR5KS0a7wdfPeGF6aLUcsOH7p0uGLudcMwHBcSQHqbwXGGj5uDNfX7TeeynNKLgyfdcMKt1DweV3sqqcn0mgAkWsQbbtRWnbw1qOalp1op8X49jWuHFGyRw6uDNocuUu8hynNKLgy5P25HpgVpbMk8deB1sNQ70rGYLI)GeAaU7gAkWsQbbtRWnbw1qOalp1op8PfBR0KcWpqSvlDQUthbkxk(dSMtYsdS8u78WNwSTstka)aXwT0P6oDeOCP4piHgGdUqtbwZjzPbwi4QwNopG)alPgemTc3eKqdW1yOPaR5KS0aBxcii4QwbwsniyAfUjiHgG7QHMcSMtYsdSqiaNaOsTnWsQbbtRWnbjibjWAEYEbcSSjY9csqcba]] )


end