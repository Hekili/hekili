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


    spec:RegisterPack( "Affliction", 20210701, [[dafCWcqiiPweOKGhrOWMKQ6teQgfO4uGuRskk5vQuAwuvClLQKDj0VuQQHPsfhdsSmPqptkQMMsvCnQkX2uPs9nPOuJJqPCocLQwhHIMNkvDpPk7dsYbjuIfQsXdbLyIQujxukkYgLIIQpckj0jPQKALGKxsOurMjOuUjHsANsb)eusAOGsQLsvj5PemvPixfus0wjuQWxLIcJLQsTxb)vfdwvhMYIbXJPYKvYLr2Ss5ZsPrRsoTOvtOuPxdQMnu3gIDt63sgUu54kvPwoWZjA6OUovz7eY3vQmEqP68uvTEPOOmFi19juQO2VIdOeAkiSmMcn04DAeL70SVdkXgBEZVJV0yqG93rbHoZb3APGGAiuqqSSTHthNLge6m)4YwHMccYYd4OGWfZDsXC)9Bt(Yds0vi7ltepSXzPoGTX7lte3(bbiEjM91AasqyzmfAOX70ik3PzFhuIn28MFN9i2heKDKl0qJ3TVeeUY1I0aKGWIKUGGyzBdNoolD(MHbWLd(afuEy)ZJIpZ34DAeLbQbky5Y0wskMdu718IL1IwZl0ry88Ww5GhhO2R5flRfTM)UirLhyEXQ1MU4a1EnVyzTO18qaKb3DzQs45XvB6MFRaZFxal15fkpCCGAVMVPDKbFEXQHPT0nVVY6ypanpUAt38Cn)UcaF(CBE)LN4aAEKuktTDEBE2WKYZN688LXZdQDXbQ9A(Mj1GGP59vgsNP88ILTnC64Su58WArW65zdtkhhO2R5BAhzWLZZ18MOkxZdbx7sTD(7YaWBXgGMp15r8WCUxSbAjE(D7xZFxWQnjN3RloqTxZdlLUivsZlleA(7YaWBXgGMhwdOU5DgglNNR5b0YZrZ7kKop24S055eHIdu718cepVSqO5DggFmhNLEWPKNNugKKCEUMxYG0XZZ18MOkxZ7Uih8uBNhNswopFz887kvCEEi08aYCx0AEySwlvudDCGAVMhwvX(NxGO18L6O57a0E15HXXbQ9AEXYsSRNKNhwbiEaDEy5UKZdH2kanpPR5RT53Y2lgwH5XvB6MNR5TUoS)5lf7FEUMhsjLZVLTxSCEy0INNbM8A(oZbxcDmi0bQTetbbXqmMxSSTHthNLoFZWa4YbFGsmeJ5HYd7FEu8z(gVtJOmqnqjgIX8WYLPTKumhOedXy(9AEXYArR5f6imEEyRCWJduIHym)EnVyzTO183fjQ8aZlwT20fhOedXy(9AEXYArR5HaidU7YuLWZJR20n)wbM)UawQZluE44aLyigZVxZ30oYGpVy1W0w6M3xzDShGMhxTPBEUMFxbGpFUnV)YtCanpskLP2oVnpBys55tDE(Y45b1U4aLyigZVxZ3mPgemnVVYq6mLNxSSTHthNLkNhwlcwppBys54aLyigZVxZ30oYGlNNR5nrvUMhcU2LA783LbG3InanFQZJ4H5CVyd0s8872VM)UGvBsoVxxCGsmeJ53R5HLsxKkP5Lfcn)Dza4TydqZdRbu38odJLZZ18aA55O5DfsNhBCw68CIqXbkXqmMFVMxG45LfcnVZW4J54S0doL88KYGKKZZ18sgKoEEUM3ev5AE3f5GNA784uYY55lJNFxPIZZdHMhqM7IwZdJ1APIAOJduIHym)EnpSQI9pVarR5l1rZ3bO9QZdJJduIHym)EnVyzj21tYZdRaepGopSCxY5HqBfGMN018128Bz7fdRW84QnDZZ18wxh2)8LI9ppxZdPKY53Y2lwopmAXZZatEnFN5GlHooqnqzoolvg7aKRqGyCVncFwfsQgNL6tU1Jtecv3PpQ7ioA4ue1h1q822ITGePsaDQTJ0CGClDu0RBGYCCwQm2bixHaX4B7TV0dbP0thXduMJZsLXoa5keigFBV99K0jzcXh1qOECHqNA7GuQKbLN84kvYaphNLkhOmhNLkJDaYviqm(2E77jPtYeIpQHq9KfMSl5rsoaXhMCxAU3E0aL54SuzSdqUcbIX32B)wqIujGo12rAoqULoYNCRhBys5ylirQeqNA7inhi3shfj1GGP1aL54SuzSdqUcbIX32BFrginiyYh1qOERILhazl)(iYWEupZXPi6Sko6kaWRJZsr1D6BoofrNvXrRTu)O6o9nhNIOZQ4ONkzdcMo22goDCwkQUtFyqnBys5Om7Uk9GZnksQbbtl0OnhNIOZQ4Om7Uk9GZncv3b6(WSko2DzkxihzQTEydKS)iNo4P2IgnQzdtkh7UmLlKJm1wpSbs2FKudcMwqpqzoolvg7aKRqGy8T923tsNKjeFudH6znZKxgWKNTs5tTD6QDeyGYCCwQm2bixHaX4B7TVKO1P2oUca864SuFWPsh3Qhk3XNCRNSJW4dBGwILrjrRtTDCfa41XzPhRiu1R5duMJZsLXoa5keigFBV9VmpLhOmhNLkJDaYviqm(2E77Ps2GGPJTTHthNLoqnqjgIX8ntWo58yAnpjIa(NNteAE(IM3CCbMpLZBISeBqWuCGYCCwQSNSJW4dUCWhOmhNLkVT3(lsu5boiwB6gOmhNLkVT3(odJpMJZsp4uY(Ogc1ZkYhjdsh3dfFYTEMJtr0HucjjjQA(aLymVyXXzPZJtjlNFRaZZGuHt88qOltuwG48cSXY5nanV0erR53kW8qOTcqZluE459vfVVVgPJ0vQTZdlgBsguDx0(W6lt5czEHuB9Wgiz)(mFXxeyxkP5lDExv4vTthOmhNLkVT3(odJpMJZsp4uY(Ogc1JbPcN4JSdN8XDro4duMJZsL32BFNHXhZXzPhCkzFudH6TiS5NwhgKkCILduMJZsL32BFNHXhZXzPhCkzFudH6jzJpmiv4el9rYG0X9qXNCRhmRIJYYdFafh50bp1w0OxfhtKosxP2ECgBsguDx0zvCKth8uBrJEvCS7YuUqoYuB9Wgiz)roDWtTf6(YYdFKxgyHQMJg9Q4OOeth2sLJC6GNAlA0SHjLJYA3HVOJKOLCGYCCwQ82E77mm(yool9Gtj7JAiuVLHyT0HbPcNyPp5wpxjIut5OMTx8zZO(WGArginiykYGuHt8r2HtgnAxv4vTtJYYdFafhbeILQevnEh0OHrKbsdcMImiv4eFkL67QcVQDAuwE4dO4iGqSuL3ZGuHtCeLORk8Q2PraHyPkHgnAyezG0GGPidsfoXhEx13vfEv70OS8WhqXraHyPkVNbPcN4yJrxv4vTtJacXsvcn0Or7krKAkhfrkF5h0hgulYaPbbtrgKkCIpYoCYOr7QcVQDAmr6iDLA7XzSjzq1DrraHyPkrvJ3bnAyezG0GGPidsfoXNsP(UQWRANgtKosxP2ECgBsguDxueqiwQY7zqQWjoIs0vfEv70iGqSuLqJgnmImqAqWuKbPcN4dVR67QcVQDAmr6iDLA7XzSjzq1DrraHyPkVNbPcN4yJrxv4vTtJacXsvcn0OrdJRerQPCujhOWfyHgTRerQPCeUFqAkA0UsePMYrTuc6(WGArginiykYGuHt8r2HtgnAxv4vTtJDxMYfYrMARh2aj7pcielvjQA8oOrdJidKgemfzqQWj(uk13vfEv70y3LPCHCKP26HnqY(JacXsvEpdsfoXruIUQWRANgbeILQeA0OHrKbsdcMImiv4eF4DvFxv4vTtJDxMYfYrMARh2aj7pcielv59miv4ehBm6QcVQDAeqiwQsOHgnAuZgMuo2DzkxihzQTEydKS)iPgemT6ddQfzG0GGPidsfoXhzhoz0ODvHx1onk9qqk9Sma8wSbOiGqSuLOQX7GgnmImqAqWuKbPcN4tPuFxv4vTtJspeKspldaVfBakcielv59miv4ehrj6QcVQDAeqiwQsOrJggrginiykYGuHt8H3v9DvHx1onk9qqk9Sma8wSbOiGqSuL3ZGuHtCSXORk8Q2PraHyPkHg6bkXy(B8a68YYdpV8Yal58528Bz7fpFkN3WiLKNVerGbkZXzPYB7TpIHPT0Dawh7biFYTEqkPS)w2EXhaHyPkVNGDY5X0HteQzjlp8rEzGv)vXrpvYgemDSTnC64S0iNo4P2oqjgZ7R3M3vIi1uE(vX7dRVmLlK5fsT1dBGK9pFkNh4PAQT(mVNKM)Uma8wSbO55AEc2zsxZZx08opaGuEEjXduMJZsL32BFNHXhZXzPhCkzFudH6Tma8wSbOthG68j36bJRerQPCueP8LFq)vXXePJ0vQThNXMKbv3fDwfh50bp12(UQWRANgLEiiLEwgaEl2aueqiwQY7BSpmRIJDxMYfYrMARh2aj7pcielvjQAenAuZgMuo2DzkxihzQTEydKSFOHgnAyCLisnLJA2EXNnJ6Vkoklp8buCKth8uB77QcVQDAu6HGu6zza4TydqraHyPkVVX(WSko2DzkxihzQTEydKS)iGqSuLOQr0OrnBys5y3LPCHCKP26HnqY(HgA0OHbgxjIut5OsoqHlWcnAxjIut5iC)G0u0ODLisnLJAPe09xfh7UmLlKJm1wpSbs2FKth8uB7Vko2DzkxihzQTEydKS)iGqSuL33i0duIX8(kAdqYR5xflNNma2)8528TvQTZNkxZBZlVmWAEzhPRuBNV7YK0aL54Su5T923zy8XCCw6bNs2h1qOERIpDaQZNCRhmUsePMYrnBV4ZMr9r9Q4OS8WhqXroDWtTTVRk8Q2Prz5HpGIJacXsvE)EGgnAyCLisnLJIiLV8d6J6vXXePJ0vQThNXMKbv3fDwfh50bp12(UQWRANgtKosxP2ECgBsguDxueqiwQY73d0OrddmUsePMYrLCGcxGfA0UsePMYr4(bPPOr7krKAkh1sjO7ZgMuo2DzkxihzQTEydKS)(OEvCS7YuUqoYuB9Wgiz)roDWtTTVRk8Q2PXUlt5c5itT1dBGK9hbeILQ8(9a9aLymVVEBEy9LPCHmVqQTEydKS)5t58C6GNARpZN88PCEPTrZZ18EsA(7YaWNxO8WduMJZsL32B)LbGFKLh2NCR3Q4y3LPCHCKP26HnqY(JC6GNA7aL54Su5T92Fza4hz5H9j36HA2WKYXUlt5c5itT1dBGK93hMvXrz5HpGIJC6GNAlA0RIJjshPRuBpoJnjdQUl6SkoYPdEQTqpqjgZl4xDZdRVmLlK5fsT1dBGK9p)UKVMxSds5l)G9BiBV45BMB08UsePMYZVk2N5l(Ia7sjnVNKMV05DvHx1onoVVEB(MjKo)aYWZdRcwQPoAEiEBBZNY5t1viP26Z8xfEnVNYjE(KfxopGSL)5HbfX28sYv6soVTXeyEpjb9aL54Su5T92V7YuUqoYuB9Wgiz)(KB9CLisnLJA2EXNnJ6ZjcHkFPVRk8Q2Prz5HpGIJacXsvEpk9HHbPcN4iH05hqg(uGLAQJIUQWRANgbeILQ8EuU7grJg10E7LDD0ksiD(bKHpfyPM6iOhOmhNLkVT3(DxMYfYrMARh2aj73NCRNRerQPCueP8LFqForiu5l9DvHx1onMiDKUsT94m2KmO6UOiGqSuL3JsFyyqQWjosiD(bKHpfyPM6OORk8Q2PraHyPkVhL7Ur0OrnT3EzxhTIesNFaz4tbwQPoc6bkXy(gihOWfyn)UKVMxSAyAlDZ3magFnVZKSC(Ult5czEzQTEydKS)5tDECQ087s(A(7ICjIXP2o)nfMhOmhNLkVT3(DxMYfYrMARh2aj73NCRNRerQPCujhOWfy1h4P0wbAPiIHPT0D2bm(QpNieQ8L(UQWRANgxKlrmo12dKcZraHyPkVV59HHbPcN4iH05hqg(uGLAQJIUQWRANgbeILQ8EuU7grJg10E7LDD0ksiD(bKHpfyPM6iOhOeJ5Hv5lcmVRerQPSCEys1H9wP2oVw6EjwBgZ3a5af0Z7mjppSwy(sN3vfEv70bkZXzPYB7TF3LPCHCKP26HnqY(9j36bJRerQPCeUFqAkA0UsePMYrTucnAyCLisnLJk5afUaR(Og4P0wbAPiIHPT0D2bm(cAO7dddsfoXrcPZpGm8Pal1uhfDvHx1oncielv59OC3nIgnQP92l76OvKq68didFkWsn1rqpqzoolvEBV97UmLlKJm1wpSbs2Vp5wpiLu2FlBV4dGqSuL3JYDpqjgZ7R3MhwFzkxiZlKARh2aj7F(uopNo4P26Z8jlUCEorO55AEpjnFXxeyEetSBbMFvSCGYCCwQ82E77mm(yool9Gtj7JAiupxjIutzFYTERIJDxMYfYrMARh2aj7pYPdEQT9HXvIi1uoQz7fF2mcnAxjIut5Ois5l)aOhOmhNLkVT3(wBP(9X53HPdBGwIL9qXNCR3Q4O1wQ)iGqSuL3VNbkZXzPYB7T)L5P8aLymVqTBE(IMxGOLC(sNV5ZZgOLy58528jpFkvX55DEaaPm2)8Po)goBV45lW8LopFrZZgOL448nJKVMxi7UkDEyl3O5twC58gwwZdHyMaZZ18EsAEbIwZxIiW8iM6zyS)5TUoS)uBNV5Zdlfa41XzPY4aL54Su5T92xs06uBhxbaEDCwQp5wpZXPi6qkHKKevn2NnmPCuw7o8fDKeTK9r9Q4OKO1P2oUca864S0iNo4P22h1PE2Wz7fpqzoolvEBV9LeTo12XvaGxhNL6tU1ZCCkIoKsijjrvJ9zdtkhLz3vPhCUr9r9Q4OKO1P2oUca864S0iNo4P22h1PE2Wz7f3FvC0vaGxhNLgbeILQ8(9mqzoolvEBV9fLy6WwQSp5wpyKLh(iVmWcvOGgT54ueDiLqssIQgHUVRk8Q2PrPhcsPNLbG3InafbeILQevO04aL54Su5T923tLSbbthBBdNool1NCRN54ueDwfh9ujBqW0X22WPJZs7Dh0O50bp12(RIJEQKniy6yBB40XzPraHyPkVFpduMJZsL32BFz2Dv6bNBKpo)omDyd0sSShk(KB9wfhLz3vPhCUrraHyPkVFpduMJZsL32BFNHXhZXzPhCkzFudH65krKAk7JKbPJ7HIp5wpu7krKAkhvYbkCbwduIX8ILUoS)5HLca864S05rm1ZWy)Zx68OSxnopBGwIL(mFbMV05B(87s(AEXcezH9yAEyPaaVoolDGYCCwQ82E77kaWRJZs9X53HPdBGwIL9qXNCRN54ueDiLqssE)E2lyydtkhL1UdFrhjrljA0SHjLJYS7Q0do3iO7Vko6kaWRJZsJacXsvEFJduIX8ILnMaZZx08vhPeWN5LDKUM3MxEzG187UiDEJN3xMV05fRgM2s38(kRJ9a08CnVjQY18Lic4SUUuBhOmhNLkVT3(igM2s3byDShG8j36jlp8rEzGfQ2tForiu1ikduIX8nJlsNxlEEPF1LA78W6lt5czEHuB9Wgiz)ZZ18IDqkF5hSFdz7fpFZCJ8zEbpeKsN)Uma8wSbO5ZT5nmE(vXY5nanV11HtAnqzoolvEBV9DggFmhNLEWPK9rneQ3YaWBXgGoDaQZNCRhmUsePMYrrKYx(b9rnBys5y3LPCHCKP26HnqY(7VkoMiDKUsT94m2KmO6UOZQ4iNo4P223vfEv70O0dbP0ZYaWBXgGIaYw(HgnAyCLisnLJA2EXNnJ6JA2WKYXUlt5c5itT1dBGK93FvCuwE4dO4iNo4P223vfEv70O0dbP0ZYaWBXgGIaYw(HgnAyGXvIi1uoQKdu4cSqJ2vIi1uoc3pinfnAxjIut5OwkbDFxv4vTtJspeKspldaVfBakciB5h6bkXyEyLsA(7YaWNxO8WZNBZFxgaEl2a087kvCEEi08aYw(N3ATu9z(cmFUnpFraA(DjgppeAEJNhtMKNVX5rkan)Dza4TydqZ7jj5aL54Su5T92Fza4hz5H9j36bPKY(UQWRANgLEiiLEwgaEl2aueqiwQsuTLTx8bqiwQY(WGA2WKYXUlt5c5itT1dBGK9JgTRk8Q2PXUlt5c5itT1dBGK9hbeILQevBz7fFaeILQe6bkZXzPYB7T)YaWpYYd7tU1dsjL9rnBys5y3LPCHCKP26HnqY(77QcVQDAu6HGu6zza4TydqraHyPkV1vfEv70O0dbP0ZYaWBXgGIlpGXzP3VLTx8bqiwQYbkXyEyXy31Ezy88jtiZ7jTwA(TcmVP(5RuBNxlEEzh5YTKwZtyjT7Ia0aL54Su5T923zy8XCCw6bNs2h1qOEjtiduIHymVVI2aK8AEHlBv7MVzcbcWC08qOTcqZl7iDLA78YldSKZx68IvdtBPBEFL1XEaAGYCCwQ82E77mm(yool9Gtj7JAiupj5tU1JnmPCuEzRA3HqGamhfj1GGPvFyweeVTTO8Yw1UdHabyokkzZb)EyACVmhNLgLx2Q2DGuyoM6zdNTxm0OrViiEBBr5LTQDhcbcWCueqiwQY7Bo0duIX8WkL08IvdtBPBEFL1XEaA(DxKopIj2TaZVkwoVbO5968z(cmFUnpFraA(DjgppeAEz2Q5w6mLNNteAEpLt888fnVsWoppS(YuUqMxi1wpSbs2FCEF928ECIZMzP2oVy1W0w6MVzam(YN5Vk8AEBE5LbwZZ18aAdqYR55lAEiEBBduMJZsL32BFedtBP7aSo2dq(KB9GzvCuuIPdBPYroDWtTfn6vXXePJ0vQThNXMKbv3fDwfh50bp1w0OxfhLLh(akoYPdEQTq3hgud8uARaTueXW0w6o7agFHgneVTTiIHPT0D2bm(kkzZb)(MJgTS8Wh5LbwOcfOhOeJ5HvkP5fRgM2s38(kRJ9a08CnpILkBPopFrZJyyAlDZVdy818q822M3t5epV8Yal58krR55AEi08TKsaJP18BfyE(IMxjyNNhIhqYZVl1vTBEyA8oZljxPl58PCEKcqZZxMoV0BBlDjP88CnFlPeWyA(MpV8Yalj0duMJZsL32BFedtBP7aSo2dq(KB9aEkTvGwkIyyAlDNDaJV67QcVQDAuwE4dO4iGqSuLOQX70hI32weXW0w6o7agFfbeILQ8(9mqjgZlwTuzl15fRgM2s38ndGXxZB88ggppNiKC(TcmpFrZ3a5afUaR5lW8IDYpinDExjIut5bkZXzPYB7TpIHPT0Dawh7biFYTEapL2kqlfrmmTLUZoGXx9HXvIi1uoQKdu4cSqJ2vIi1uoc3pinf6(q822IigM2s3zhW4RiGqSuL3VNbkXyEyLsAEXQHPT0nVVY6ypanFPZdRVmLlK5fsT1dBGK9pVZKS0N5rm4P2oV0dqZZ18stenVnV8YaR55AEjBo4ZlwnmTLU5BgaJVMp3M3tMA78jpqzoolvEBV9rmmTLUdW6ypa5tU1JnmPCS7YuUqoYuB9Wgiz)9HzvCS7YuUqoYuB9Wgiz)roDWtTfnAxv4vTtJDxMYfYrMARh2aj7pcielvjQA0xqJgsjL95eHoCDwjDVRk8Q2PXUlt5c5itT1dBGK9hbeILQe6(WGAGNsBfOLIigM2s3zhW4l0OH4TTfrmmTLUZoGXxrjBo433C0OLLh(iVmWcvOa9aL54Su5T92hXW0w6oaRJ9aKp5wp2WKYrzT7Wx0rs0soqjgZFxal15HTCJMpLZxk2)8283fSwy(wl153L818(ALeLSbbtZFxeskP5vYaZJyW(8s2CWLX591BZVLTx88PCEds5XZZ18KUMFvZRfppskLZl7iDLA788fnVKnhC5aL54Su5T92FbSup4CJ8j36bXBBlMkjkzdcMolcjLuuYMdoQ2ZDqJgI32wmvsuYgemDweskPOxxFiLu2FlBV4dGqSuL3VNbkZXzPYB7TVZW4J54S0doLSpQHq9CLisnLhOmhNLkVT3(wBP(9X53HPdBGwIL9qXNCRhG2aK8YGGPbkZXzPYB7TVNkzdcMo22goDCwQp5wpZXPi6Sko6Ps2GGPJTTHthNL27oOrZPdEQT9b0gGKxgemnqzoolvEBV9Lz3vPhCUr(487W0HnqlXYEO4tU1dqBasEzqW0aL54Su5T923vaGxhNL6JZVdth2aTel7HIp5wpaTbi5Lbbt9nhNIOdPessY73ZEbdBys5OS2D4l6ijAjrJMnmPCuMDxLEW5gb9aL54Su5T92FbSupYYd7tQmbaEDCpugOmhNLkVT3(YlBv7oqkmpqnqzoolvgTI61DzkxihzQTEydKS)bkZXzPYOv0T92)Y8uEGYCCwQmAfDBV9DggFmhNLEWPK9rneQ3YaWBXgGoDaQZNCRNRerQPCueP8LFq)vXXePJ0vQThNXMKbv3fDwfh50bp12(UQWRANgLEiiLEwgaEl2aueq2YFFywfh7UmLlKJm1wpSbs2FeqiwQsu1iA0OMnmPCS7YuUqoYuB9Wgiz)qJgTRerQPCuZ2l(Szu)vXrz5HpGIJC6GNABFxv4vTtJspeKspldaVfBakciB5VpmRIJDxMYfYrMARh2aj7pcielvjQAenAuZgMuo2DzkxihzQTEydKSFOrJggxjIut5OsoqHlWcnAxjIut5iC)G0u0ODLisnLJAPe09xfh7UmLlKJm1wpSbs2FKth8uB7Vko2DzkxihzQTEydKS)iGqSuL334aL54Suz0k62E7ljADQTJRaaVool1NCRhBys5OS2D4l6ijAj77m9ijAnqzoolvgTIUT3(sIwNA74kaWRJZs9j36HA2WKYrzT7Wx0rs0s2h1RIJsIwNA74kaWRJZsJC6GNABFuN6zdNTxC)vXrxbaEDCwAeqBasEzqW0aL54Suz0k62E7BTL63hNFhMoSbAjw2dfFYTEMJtr0zvC0Al1)97PpQxfhT2s9h50bp12bkZXzPYOv0T923Al1Vpo)omDyd0sSShk(KB9mhNIOZQ4O1wQFu1Bp9b0gGKxgem1FvC0Al1FKth8uBhOmhNLkJwr32BFpvYgemDSTnC64SuFYTEMJtr0zvC0tLSbbthBBdNoolT3DqJMth8uB7dOnajVmiyAGYCCwQmAfDBV99ujBqW0X22WPJZs9X53HPdBGwIL9qXNCRhQ50bp12(DI6ydtkhbgsNP8X22WPJZsLrsniyA13CCkIoRIJEQKniy6yBB40XzP338bkZXzPYOv0T92xuIPdBPY(KB9KLh(iVmWcvOmqzoolvgTIUT3(odJpMJZsp4uY(Ogc1ZvIi1u2hjdsh3dfFYTEO2vIi1uoQKdu4cSgOmhNLkJwr32BFNHXhZXzPhCkzFudH6Tma8wSbOthG68j36bJRerQPCueP8LFqFyCvHx1onMiDKUsT94m2KmO6UOiGSLF0OxfhtKosxP2ECgBsguDx0zvCKth8uBHUVRk8Q2PrPhcsPNLbG3InafbKT83hMvXXUlt5c5itT1dBGK9hbeILQevnIgnQzdtkh7UmLlKJm1wpSbs2p0q3hgyCLisnLJk5afUal0ODLisnLJW9dstrJ2vIi1uoQLsq33vfEv70O0dbP0ZYaWBXgGIacXsvEFJ9HzvCS7YuUqoYuB9Wgiz)raHyPkrvJOrJA2WKYXUlt5c5itT1dBGK9dn0OrdJRerQPCuZ2l(SzuFyCvHx1onklp8buCeq2YpA0RIJYYdFafh50bp1wO77QcVQDAu6HGu6zza4TydqraHyPkVVX(WSko2DzkxihzQTEydKS)iGqSuLOQr0OrnBys5y3LPCHCKP26HnqY(Hg6bkZXzPYOv0T92Fza4hz5H9j36bPKY(UQWRANgLEiiLEwgaEl2aueqiwQsuTLTx8bqiwQY(WGA2WKYXUlt5c5itT1dBGK9JgTRk8Q2PXUlt5c5itT1dBGK9hbeILQevBz7fFaeILQe6bkZXzPYOv0T92Fza4hz5H9j36bPKY(UQWRANgLEiiLEwgaEl2aueqiwQYBDvHx1onk9qqk9Sma8wSbO4YdyCw69Bz7fFaeILQCGYCCwQmAfDBV9DggFmhNLEWPK9rneQxYeYaL54Suz0k62E77mm(yool9Gtj7JAiuVfHn)06WGuHtSCGYCCwQmAfDBV9DggFmhNLEWPK9rneQ3YqSw6WGuHtSCGYCCwQmAfDBV9DggFmhNLEWPK9rneQNKn(WGuHtS0NCR3Q4y3LPCHCKP26HnqY(JC6GNAlA0OMnmPCS7YuUqoYuB9Wgiz)duMJZsLrROB7TpIHPT0Dawh7biFYTERIJIsmDylvoYPdEQTduMJZsLrROB7TpIHPT0Dawh7biFYTERIJYYdFafh50bp12(OMnmPCuw7o8fDKeTKduMJZsLrROB7TpIHPT0Dawh7biFYTEOMnmPCuuIPdBPYduMJZsLrROB7TpIHPT0Dawh7biFYTEYYdFKxgyHQ9mqzoolvgTIUT3(YS7Q0do3iFC(Dy6WgOLyzpu8j36zoofrNvXrz2Dv6bNB099AEFaTbi5Lbbt9r9Q4Om7Uk9GZnkYPdEQTduMJZsLrROB7TVZW4J54S0doLSpQHq9CLisnL9rYG0X9qXNCRNRerQPCujhOWfynqzoolvgTIUT3(lGL6bNBKp5wpiEBBXujrjBqW0zriPKIs2CWrvpF5oOrdPKY(q822IPsIs2GGPZIqsjf966VLTx8bqiwQY79f0OH4TTftLeLSbbtNfHKskkzZbhv9AUV0FvCuwE4dO4iNo4P2oqzoolvgTIUT3(lGL6rwEyFsLjaWRJ7HYaL54Suz0k62E7lVSvT7aPW8a1aL54Suz0vIi1uUxI0r6k12JZytYGQ7I8j36HA2WKYXUlt5c5itT1dBGK93hgxv4vTtJspeKspldaVfBakcielv59OCh0ODvHx1onk9qqk9Sma8wSbOiGqSuLOYxUtFxv4vTtJspeKspldaVfBakcielvjQA0x67kD5LC0vaGxhNA7btea6bkZXzPYORerQP8T92pr6iDLA7XzSjzq1Dr(KB9ydtkh7UmLlKJm1wpSbs2F)vXXUlt5c5itT1dBGK9h50bp12bkZXzPYORerQP8T92FrUeX4uBpqkm7tU1ZvfEv70O0dbP0ZYaWBXgGIacXsvIkFPpmlcI32w8Y8uocielvjQ2dA0OMnmPC8Y8ug6bkZXzPYORerQP8T92xwE4dOyFYTEOMnmPCS7YuUqoYuB9Wgiz)9HXvfEv70O0dbP0ZYaWBXgGIacXsvEVVGgTRk8Q2PrPhcsPNLbG3InafbeILQev(YDqJ2vfEv70O0dbP0ZYaWBXgGIacXsvIQg9L(UsxEjhDfa41XP2EWebGEGYCCwQm6krKAkFBV9LLh(ak2NCRhBys5y3LPCHCKP26HnqY(7Vko2DzkxihzQTEydKS)iNo4P2oqzoolvgDLisnLVT3(sx5bsT9WjFrduduMJZsLXLHyT0HbPcNyzppjDsMq8rneQNS8WNSvtMaduMJZsLXLHyT0HbPcNy5T923tsNKjeFudH6TaKT2saDersjHhOmhNLkJldXAPddsfoXYB7TVNKojti(Ogc1Rf7V76uBhtktKeBCw6aL54SuzCziwlDyqQWjwEBV99K0jzcXh1qOEEQ7YsLwNwSTsJlG8iVmhCmjhOmhNLkJldXAPddsfoXYB7TVNKojti(Ogc1JGuQS8WhrPJgOgOmhNLkJldaVfBa60bOUEIsmDylvEGYCCwQmUma8wSbOthG6UT3(lda)ilp8aL54SuzCza4TydqNoa1DBV97kolDGYCCwQmUma8wSbOthG6UT3(BjGGGRAnqzoolvgxgaEl2a0PdqD32BFi4QwNnpG)bkZXzPY4YaWBXgGoDaQ72E7dHascap12bkZXzPY4YaWBXgGoDaQ72E77mm(yool9Gtj7JAiupxjIutzFYTEO2vIi1uoQKdu4cSgOmhNLkJldaVfBa60bOUB7TV0dbP0ZYaWBXgGgOgOmhNLkJlcB(P1HbPcNyzppjDsMq8rneQhH05hqg(uGLAQJ8j36bJRerQPCuZ2l(SzuFxv4vTtJYYdFafhbeILQ8(gVd0OrdJRerQPCueP8LFqFxv4vTtJjshPRuBpoJnjdQUlkcielv59nEhOrJggxjIut5OsoqHlWcnAxjIut5iC)G0u0ODLisnLJAPe0duMJZsLXfHn)06WGuHtS82E77jPtYeIpQHq9KEkeCvRJHq8LFj7tU1dgxjIut5OMTx8zZO(UQWRANgLLh(akocielv593n0OrdJRerQPCueP8LFqFxv4vTtJjshPRuBpoJnjdQUlkcielv593n0OrdJRerQPCujhOWfyHgTRerQPCeUFqAkA0UsePMYrTuc6bkZXzPY4IWMFADyqQWjwEBV99K0jzcXh1qOEYYdJjMtT9a8G43NCRhmUsePMYrnBV4ZMr9DvHx1onklp8buCeqiwQY7fBqJgnmUsePMYrrKYx(b9DvHx1onMiDKUsT94m2KmO6UOiGqSuL3l2GgnAyCLisnLJk5afUal0ODLisnLJW9dstrJ2vIi1uoQLsqpqzoolvgxe28tRddsfoXYB7TVNKojti(Ogc1tEzRAhTofaYP2oCbqiL9j36bJRerQPCuZ2l(SzuFxv4vTtJYYdFafhbeILQ8(9anA0W4krKAkhfrkF5h03vfEv70yI0r6k12JZytYGQ7IIacXsvE)EGgnAyCLisnLJk5afUal0ODLisnLJW9dstrJ2vIi1uoQLsqpqnqzoolvgxfF6auxpRTu)(KB9wfhT2s9hbeILQ8EXwFxv4vTtJspeKspldaVfBakcielvjQwfhT2s9hbeILQCGYCCwQmUk(0bOUB7TVm7Uk9GZnYNCR3Q4Om7Uk9GZnkcielv59IT(UQWRANgLEiiLEwgaEl2aueqiwQsuTkokZURsp4CJIacXsvoqzoolvgxfF6au3T923tLSbbthBBdNool1NCR3Q4ONkzdcMo22goDCwAeqiwQY7fB9DvHx1onk9qqk9Sma8wSbOiGqSuLOAvC0tLSbbthBBdNoolncielv5aL54SuzCv8PdqD32BFxbaEDCwQp5wVvXrxbaEDCwAeqiwQY7fB9DvHx1onk9qqk9Sma8wSbOiGqSuLOAvC0vaGxhNLgbeILQCGAGYCCwQmMmH0ZtsNKje5a1aL54Suzus9UmpLhOmhNLkJs62E7VawQhz5H9jvMaaVo(0IligUhk(KktaGxhFYTElcI32wuEzRA3HqGamhfLS5GJQEnFGYCCwQmkPB7TV8Yw1UdKcZduduMJZsLrjB8HbPcNyzppjDsMq8rneQxQshWJniy6S3EMYEiNfjkD0aL54SuzuYgFyqQWjwEBV99K0jzcXh1qOEPkzGNJlG8SsrPshiegpqzoolvgLSXhgKkCIL32BFpjDsMq8rneQxjIaB4AxQThtte74SwAGYCCwQmkzJpmiv4elVT3(Es6KmH4JAiuVLbGJuLEwKd(PZJbK0rQJgOmhNLkJs24ddsfoXYB7TVNKojti(Ogc1dXCgeaDKxeXhepz6gOmhNLkJs24ddsfoXYB7TVNKojti(Ogc1BdBi0P2oqmMX0aL54SuzuYgFyqQWjwEBV99K0jzcXh1qOE7m4Ksa5zdu6AGYCCwQmkzJpmiv4elVT3(Es6KmH4JAiup2GGj(uBNfj7SemqzoolvgLSXhgKkCIL32BFpjDsMq8rneQNm1np8XKDjWuwEGyRw6uBNncuUK9pqzoolvgLSXhgKkCIL32BFpjDsMq8rneQNm1np8PfBR04cipqSvlDQTZgbkxY(hOmhNLkJs24ddsfoXYB7TpeCvRZMhW)aL54SuzuYgFyqQWjwEBV93sabbx1AGYCCwQmkzJpmiv4elVT3(qiGKaWtTDGAGsmMVzqZVkvCEEPxxxb45hXopVjN33WQ(Q5tDEyZZ8zEznVVwCr08UsfraMwZZxPCEUM3ajFHqC6IduMJZsLrgKkCIpYoCYh3f5G3tKbsdcM8rneQNSJCPHp0E7LDD0Yhrg2J6bdmO0SO92l76OvKq68didFkWsn1rqFlmO0SO92l76OvmvPd4XgemD2BptzpKZIeLoc6BHbLMfT3EzxhTIYYdJjMtT9a8G4h6BHbLMfT3EzxhTIspfcUQ1Xqi(YVKHg6EOmqzoolvgzqQWj(i7WjFCxKd(T92xKbsdcM8rneQhdsfoXNsjFezypQhmmiv4ehrjEzYthOC9zqQWjoIs8YKhxv4vTtHEGYCCwQmYGuHt8r2Ht(4Uih8B7TVidKgem5JAiupgKkCIp8UYhrg2J6bddsfoXXgJxM80bkxFgKkCIJngVm5XvfEv7uOhOmhNLkJmiv4eFKD4KpUlYb)2E7lYaPbbt(Ogc1BziwlDyqQWj2hrg2J6bdQHHbPcN4ikXltE6aLRpdsfoXruIxM84QcVQDk0qJgnmOgggKkCIJngVm5PduU(miv4ehBmEzYJRk8Q2PqdnA00E7LDD0k2I93DDQTJjLjsInolDGYCCwQmYGuHt8r2Ht(4Uih8B7TVidKgem5JAiupgKkCIpYoCY(iYWEupyezG0GGPidsfoXNsP(ImqAqWuCziwlDyqQWjgA0OHrKbsdcMImiv4eF4DvFrginiykUmeRLomiv4ednA0WGsZsKbsdcMImiv4eFkLG(wyqPzjYaPbbtrzh5sdFO92l76Of09qbnAyqPzjYaPbbtrgKkCIp8Uc6BHbLMLidKgemfLDKln8H2BVSRJwq3dLGGiciZsdn04DAeL70SVdkbHDgqtTvgeAgIfFvd(6gGvumNF(MUO5tKUcWZVvG5fNbPcN4JSdN8XDro4IppG2BVeqR5LfcnV5XfIX0AE3LPTKmoqbBPsZ3OyopSuQicW0AEXzqQWjoIs03IppxZlodsfoXrgLOVfFEyAe2HooqbBPsZ3CXCEyPureGP18IZGuHtCSXOVfFEUMxCgKkCIJCJrFl(8W0iSdDCGc2sLMFpI58WsPIiatR5fNbPcN4ikrFl(8CnV4miv4ehzuI(w85HPryh64afSLkn)EeZ5HLsfraMwZlodsfoXXgJ(w855AEXzqQWjoYng9T4ZdtJWo0XbQbQMHyXx1GVUbyffZ5NVPlA(ePRa88BfyEXDLisnLfFEaT3EjGwZlleAEZJleJP18UltBjzCGc2sLMhfXCEyPureGP18IZgMuo6BXNNR5fNnmPC03rsniyAj(8WGcSdDCGc2sLMhfXCEyPureGP18I7kD5LC03IppxZlUR0LxYrFhj1GGPL4ZddkWo0XbkylvA(gfZ5HLsfraMwZloBys5OVfFEUMxC2WKYrFhj1GGPL4ZddkWo0XbkylvA(MlMZdlLkIamTMxC2WKYrFl(8CnV4SHjLJ(osQbbtlXNhguGDOJduWwQ087rmNhwkvebyAnV4SHjLJ(w855AEXzdtkh9DKudcMwIppmOa7qhhOGTuP53JyopSuQicW0AEXDLU8so6BXNNR5f3v6Yl5OVJKAqW0s85Hbfyh64afSLknVViMZdlLkIamTMxC2WKYrFl(8CnV4SHjLJ(osQbbtlXNhguGDOJdudundXIVQbFDdWkkMZpFtx08jsxb453kW8IVOnZdZIppG2BVeqR5LfcnV5XfIX0AE3LPTKmoqbBPsZF3I58WsPIiatR5fNnmPC03IppxZloBys5OVJKAqW0s85nE(MjyvyBEyqb2HooqbBPsZ3SfZ5HLsfraMwZlodsfoXruI(w855AEXzqQWjoYOe9T4ZdZEGDOJduWwQ08nBXCEyPureGP18IZGuHtCSXOVfFEUMxCgKkCIJCJrFl(8WShyh64afSLknVyVyopSuQicW0AEXzdtkh9T4ZZ18IZgMuo67iPgemTeFEyAe2HooqbBPsZJYDeZ5HLsfraMwZloBys5OVfFEUMxC2WKYrFhj1GGPL4ZddkWo0XbkylvAEuAumNhwkvebyAnV4SHjLJ(w855AEXzdtkh9DKudcMwIppmOa7qhhOGTuP5rP5I58WsPIiatR5fNbPcN4ObXfDvHx1ov855AEXDvHx1onAqCIppmOa7qhhOGTuP5rzpI58WsPIiatR5fNbPcN4ObXfDvHx1ov855AEXDvHx1onAqCIppmOa7qhhOGTuP5rXxeZ5HLsfraMwZloWtPTc0srFl(8CnV4apL2kqlf9DKudcMwIppmOa7qhhOGTuP5rXxeZ5HLsfraMwZlodsfoXrdIl6QcVQDQ4ZZ18I7QcVQDA0G4eFEyqb2HooqbBPsZJYDlMZdlLkIamTMxCGNsBfOLI(w855AEXbEkTvGwk67iPgemTeFEyqb2HooqbBPsZJYDlMZdlLkIamTMxCgKkCIJgex0vfEv7uXNNR5f3vfEv70ObXj(8WGcSdDCGc2sLMVrueZ5HLsfraMwZloBys5OVfFEUMxC2WKYrFhj1GGPL4ZddkWo0XbkylvA(gBumNhwkvebyAnV4SHjLJ(w855AEXzdtkh9DKudcMwIppmOa7qhhOGTuP5BSzlMZdlLkIamTMxC2WKYrFl(8CnV4SHjLJ(osQbbtlXNhMgHDOJduWwQ08nk2lMZdlLkIamTMxC2WKYrFl(8CnV4SHjLJ(osQbbtlXNhMgHDOJduWwQ08n)oI58WsPIiatR5fNnmPC03IppxZloBys5OVJKAqW0s85Hbfyh64afSLknFZrrmNhwkvebyAnV4SHjLJ(w855AEXzdtkh9DKudcMwIppmOa7qhhOGTuP5B(EeZ5HLsfraMwZloWtPTc0srFl(8CnV4apL2kqlf9DKudcMwIppmOa7qhhOGTuP5BUViMZdlLkIamTMxCGNsBfOLI(w855AEXbEkTvGwk67iPgemTeFEyqb2HooqbBPsZ387wmNhwkvebyAnV4apL2kqlf9T4ZZ18Id8uARaTu03rsniyAj(8WGcSdDCGc2sLMV5nBXCEyPureGP18IZgMuo6BXNNR5fNnmPC03rsniyAj(8WGcSdDCGc2sLMV5nBXCEyPureGP18Id8uARaTu03IppxZloWtPTc0srFhj1GGPL4ZddkWo0XbkylvA(Ml2eZ5HLsfraMwZloBys5OVfFEUMxC2WKYrFhj1GGPL4ZB88ntWQW28WGcSdDCGc2sLMFp7rmNhwkvebyAnV4SHjLJ(w855AEXzdtkh9DKudcMwIppmnc7qhhOgOAgIfFvd(6gGvumNF(MUO5tKUcWZVvG5f3ks85b0E7LaAnVSqO5npUqmMwZ7UmTLKXbkylvA(MlMZdlLkIamTMxC2WKYrFl(8CnV4SHjLJ(osQbbtlXNhMgHDOJduWwQ087rmNhwkvebyAnV4SHjLJ(w855AEXzdtkh9DKudcMwIppmOa7qhhOGTuP59fXCEyPureGP18IZgMuo6BXNNR5fNnmPC03rsniyAj(8WGcSdDCGc2sLMhLgfZ5HLsfraMwZloBys5OVfFEUMxC2WKYrFhj1GGPL4ZdtZHDOJduWwQ08O0CXCEyPureGP18IZgMuo6BXNNR5fNnmPC03rsniyAj(8WGcSdDCGc2sLMhfXMyopSuQicW0AEXzdtkh9T4ZZ18IZgMuo67iPgemTeFEJNVzcwf2MhguGDOJduWwQ08nEhXCEyPureGP18IZgMuo6BXNNR5fNnmPC03rsniyAj(8gpFZeSkSnpmOa7qhhOGTuP5BefXCEyPureGP18IZgMuo6BXNNR5fNnmPC03rsniyAj(8gpFZeSkSnpmOa7qhhOgO81iDfGP18O048MJZsNhNswghOcc4uYYqtbHLbG3InaD6auxOPqdOeAkiyoolniikX0HTu5GaPgemTc3e4qdngAkiyoolniSma8JS8WbbsniyAfUjWHgAEOPGG54S0GqxXzPbbsniyAfUjWHg2tOPGG54S0GWwcii4QwbbsniyAfUjWHg8LqtbbZXzPbbi4QwNnpG)GaPgemTc3e4qd3DOPGG54S0Gaecija8uBdcKAqW0kCtGdn0Sdnfei1GGPv4MGGdKmbsliG65DLisnLJk5afUaRGG54S0GGZW4J54S0doLCqaNs(OgcfeCLisnLdCObXwOPGG54S0GG0dbP0ZYaWBXgGccKAqW0kCtGdCqGbPcN4JSdN8XDro4HMcnGsOPGaPgemTc3eeQUGGK4GG54S0GGidKgemfeezypkiaZ8WmpkZ3SMN2BVSRJwrcPZpGm8Pal1uhnp0ZF78WmpkZ3SMN2BVSRJwXuLoGhBqW0zV9mL9qolsu6O5HE(BNhM5rz(M180E7LDD0kklpmMyo12dWdI)5HE(BNhM5rz(M180E7LDD0kk9ui4QwhdH4l)sEEONh657npkbHfjDGSJZsdcndA(vPIZZl966kapFqqKboQHqbbzh5sdFO92l76OvGdn0yOPGaPgemTc3eeQUGGK4GG54S0GGidKgemfeezypkiaZ8miv4ehzuIxM80bk389NNbPcN4iJs8YKhxv4vTtNh6GGidCudHccmiv4eFkLcCOHMhAkiqQbbtRWnbHQliijoiyoolniiYaPbbtbbrg2JccWmpdsfoXrUX4LjpDGYnF)5zqQWjoYngVm5XvfEv705HoiiYah1qOGadsfoXhExf4qd7j0uqGudcMwHBccvxqqsCqWCCwAqqKbsdcMccImShfeGzEuppmZZGuHtCKrjEzYthOCZ3FEgKkCIJmkXltECvHx1oDEONh65rJEEyMh1ZdZ8miv4eh5gJxM80bk389NNbPcN4i3y8YKhxv4vTtNh65HEE0ONN2BVSRJwXwS)URtTDmPmrsSXzPbbrg4OgcfewgI1shgKkCIdCObFj0uqGudcMwHBccvxqqsCqWCCwAqqKbsdcMccImShfeGzErginiykYGuHt8PuA((ZlYaPbbtXLHyT0HbPcN45HEE0ONhM5fzG0GGPidsfoXhExnF)5fzG0GGP4YqSw6WGuHt88qppA0ZdZ8OmFZAErginiykYGuHt8PuAEON)25HzEuMVznVidKgemfLDKln8H2BVSRJwZd989MhL5rJEEyMhL5BwZlYaPbbtrgKkCIp8UAEON)25HzEuMVznVidKgemfLDKln8H2BVSRJwZd989MhLGGidCudHccmiv4eFKD4KdCGdcldXAPddsfoXYqtHgqj0uqGudcMwHBccQHqbbz5HpzRMmbccMJZsdcYYdFYwnzce4qdngAkiqQbbtRWnbb1qOGWcq2Alb0rejLeoiyoolniSaKT2saDersjHdCOHMhAkiqQbbtRWnbb1qOGql2F31P2oMuMij24S0GG54S0Gql2F31P2oMuMij24S0ahAypHMccKAqW0kCtqqneki4PUllvADAX2knUaYJ8YCWXKmiyoolni4PUllvADAX2knUaYJ8YCWXKmWHg8LqtbbsniyAfUjiOgcfeiiLklp8ru6OGG54S0GabPuz5HpIshf4ahewe28tRddsfoXYqtHgqj0uqGudcMwHBccMJZsdcesNFaz4tbwQPoki4ajtG0ccWmVRerQPCuZ2l(Sz089N3vfEv70OS8WhqXraHyPkN)(5B8oZd98OrppmZ7krKAkhfrkF5hmF)5DvHx1onMiDKUsT94m2KmO6UOiGqSuLZF)8nEN5HEE0ONhM5DLisnLJk5afUaR5rJEExjIut5iC)G005rJEExjIut5Owknp0bb1qOGaH05hqg(uGLAQJcCOHgdnfei1GGPv4MGG54S0GG0tHGRADmeIV8l5GGdKmbsliaZ8UsePMYrnBV4ZMrZ3FExv4vTtJYYdFafhbeILQC(7N)UNh65rJEEyM3vIi1uokIu(Ypy((Z7QcVQDAmr6iDLA7XzSjzq1DrraHyPkN)(5V75HEE0ONhM5DLisnLJk5afUaR5rJEExjIut5iC)G005rJEExjIut5Owknp0bb1qOGG0tHGRADmeIV8l5ahAO5HMccKAqW0kCtqWCCwAqqwEymXCQThGhe)bbhizcKwqaM5DLisnLJA2EXNnJMV)8UQWRANgLLh(akocielv583pVyBEONhn65HzExjIut5Ois5l)G57pVRk8Q2PXePJ0vQThNXMKbv3ffbeILQC(7NxSnp0ZJg98WmVRerQPCujhOWfynpA0Z7krKAkhH7hKMopA0Z7krKAkh1sP5HoiOgcfeKLhgtmNA7b4bXFGdnSNqtbbsniyAfUjiyoolniiVSvTJwNca5uBhUaiKYbbhizcKwqaM5DLisnLJA2EXNnJMV)8UQWRANgLLh(akocielv583p)EMh65rJEEyM3vIi1uokIu(Ypy((Z7QcVQDAmr6iDLA7XzSjzq1DrraHyPkN)(53Z8qppA0ZdZ8UsePMYrLCGcxG18OrpVRerQPCeUFqA68OrpVRerQPCulLMh6GGAiuqqEzRAhTofaYP2oCbqiLdCGdcUsePMYHMcnGsOPGaPgemTc3eeCGKjqAbbuppBys5y3LPCHCKP26HnqY(JKAqW0A((ZdZ8UQWRANgLEiiLEwgaEl2aueqiwQY5VFEuUZ8OrpVRk8Q2PrPhcsPNLbG3InafbeILQCEunVVCN57pVRk8Q2PrPhcsPNLbG3InafbeILQCEunFJ(Y89N3v6Yl5ORaaVoo12dMiqKudcMwZdDqWCCwAqir6iDLA7XzSjzq1Drbo0qJHMccKAqW0kCtqWbsMaPfeydtkh7UmLlKJm1wpSbs2FKudcMwZ3F(vXXUlt5c5itT1dBGK9h50bp12GG54S0GqI0r6k12JZytYGQ7IcCOHMhAkiqQbbtRWnbbhizcKwqWvfEv70O0dbP0ZYaWBXgGIacXsvopQM3xMV)8Wm)IG4TTfVmpLJacXsvopQMFpZJg98OEE2WKYXlZt5iPgemTMh6GG54S0GWICjIXP2EGuyoWHg2tOPGaPgemTc3eeCGKjqAbbuppBys5y3LPCHCKP26HnqY(JKAqW0A((ZdZ8UQWRANgLEiiLEwgaEl2aueqiwQY5VFEFzE0ON3vfEv70O0dbP0ZYaWBXgGIacXsvopQM3xUZ8OrpVRk8Q2PrPhcsPNLbG3InafbeILQCEunFJ(Y89N3v6Yl5ORaaVoo12dMiqKudcMwZdDqWCCwAqqwE4dO4ahAWxcnfei1GGPv4MGGdKmbsliWgMuo2DzkxihzQTEydKS)iPgemTMV)8RIJDxMYfYrMARh2aj7pYPdEQTbbZXzPbbz5HpGIdCOH7o0uqWCCwAqq6kpqQTho5lkiqQbbtRWnboWbHvXNoa1fAk0akHMccKAqW0kCtqWbsMaPfewfhT2s9hbeILQC(7NxSnF)5DvHx1onk9qqk9Sma8wSbOiGqSuLZJQ5xfhT2s9hbeILQmiyoolniyTL6pWHgAm0uqGudcMwHBccoqYeiTGWQ4Om7Uk9GZnkcielv583pVyB((Z7QcVQDAu6HGu6zza4TydqraHyPkNhvZVkokZURsp4CJIacXsvgemhNLgeKz3vPhCUrbo0qZdnfei1GGPv4MGGdKmbsliSko6Ps2GGPJTTHthNLgbeILQC(7NxSnF)5DvHx1onk9qqk9Sma8wSbOiGqSuLZJQ5xfh9ujBqW0X22WPJZsJacXsvgemhNLge8ujBqW0X22WPJZsdCOH9eAkiqQbbtRWnbbhizcKwqyvC0vaGxhNLgbeILQC(7NxSnF)5DvHx1onk9qqk9Sma8wSbOiGqSuLZJQ5xfhDfa41XzPraHyPkdcMJZsdcUca864S0ah4GWI2mpmhAk0akHMccMJZsdcYocJp4YbpiqQbbtRWnbo0qJHMccMJZsdclsu5boiwB6ccKAqW0kCtGdn08qtbbsniyAfUji4ajtG0ccMJtr0Hucjj58OA(MheKmiDCObuccMJZsdcodJpMJZsp4uYbbCk5JAiuqWkkWHg2tOPGaPgemTc3eewK0bYoolniiwCCw684uYY53kW8miv4eppe6YeLfioVaBSCEdqZlnr0A(TcmpeARa08cLhEEFvX77Rr6iDLA78WIXMKbv3fTpS(YuUqMxi1wpSbs2VpZx8fb2LsA(sN3vfEv70GG54S0GGZW4J54S0doLCqaNs(OgcfeyqQWj(i7WjFCxKdEGdn4lHMccKAqW0kCtqWCCwAqWzy8XCCw6bNsoiGtjFudHcclcB(P1HbPcNyzGdnC3HMccKAqW0kCtqWbsMaPfeGz(vXrz5HpGIJC6GNA78Orp)Q4yI0r6k12JZytYGQ7IoRIJC6GNA78Orp)Q4y3LPCHCKP26HnqY(JC6GNA78qpF)5LLh(iVmWAEunFZNhn65xfhfLy6WwQCKth8uBNhn65zdtkhL1UdFrhjrlzKudcMwbbjdshhAaLGG54S0GGZW4J54S0doLCqaNs(OgcfeKSXhgKkCILbo0qZo0uqGudcMwHBccoqYeiTGGRerQPCuZ2l(Sz089NhM5r98ImqAqWuKbPcN4JSdN88OrpVRk8Q2Prz5HpGIJacXsvopQMVX7mpA0ZdZ8ImqAqWuKbPcN4tP089N3vfEv70OS8WhqXraHyPkN)(5zqQWjoYOeDvHx1oncielv58qppA0ZdZ8ImqAqWuKbPcN4dVRMV)8UQWRANgLLh(akocielv583ppdsfoXrUXORk8Q2PraHyPkNh65HEE0ON3vIi1uokIu(Ypy((ZdZ8OEErginiykYGuHt8r2HtEE0ON3vfEv70yI0r6k12JZytYGQ7IIacXsvopQMVX7mpA0ZdZ8ImqAqWuKbPcN4tP089N3vfEv70yI0r6k12JZytYGQ7IIacXsvo)9ZZGuHtCKrj6QcVQDAeqiwQY5HEE0ONhM5fzG0GGPidsfoXhExnF)5DvHx1onMiDKUsT94m2KmO6UOiGqSuLZF)8miv4eh5gJUQWRANgbeILQCEONh65rJEEyM3vIi1uoQKdu4cSMhn65DLisnLJW9dstNhn65DLisnLJAP08qpF)5HzEupVidKgemfzqQWj(i7WjppA0Z7QcVQDAS7YuUqoYuB9Wgiz)raHyPkNhvZ34DMhn65HzErginiykYGuHt8PuA((Z7QcVQDAS7YuUqoYuB9Wgiz)raHyPkN)(5zqQWjoYOeDvHx1oncielv58qppA0ZdZ8ImqAqWuKbPcN4dVRMV)8UQWRANg7UmLlKJm1wpSbs2FeqiwQY5VFEgKkCIJCJrxv4vTtJacXsvop0Zd98OrppQNNnmPCS7YuUqoYuB9Wgiz)rsniyAnF)5HzEupVidKgemfzqQWj(i7WjppA0Z7QcVQDAu6HGu6zza4TydqraHyPkNhvZ34DMhn65HzErginiykYGuHt8PuA((Z7QcVQDAu6HGu6zza4TydqraHyPkN)(5zqQWjoYOeDvHx1oncielv58qppA0ZdZ8ImqAqWuKbPcN4dVRMV)8UQWRANgLEiiLEwgaEl2aueqiwQY5VFEgKkCIJCJrxv4vTtJacXsvop0ZdDqWCCwAqWzy8XCCw6bNsoiGtjFudHccldXAPddsfoXYahAqSfAkiqQbbtRWnbbZXzPbbedtBP7aSo2dqbHfjDGSJZsdc34b05LLhEE5LbwY5ZT53Y2lE(uoVHrkjpFjIabbhizcKwqasjLZ3F(TS9IpacXsvo)9ZtWo58y6WjcnFZAEz5HpYldSMV)8RIJEQKniy6yBB40XzProDWtTnWHge7dnfei1GGPv4MGWIKoq2XzPbbF928UsePMYZVkEFy9LPCHmVqQTEydKS)5t58apvtT1N59K083LbG3InanpxZtWot6AE(IM35baKYZljoiyoolni4mm(yool9GtjheCGKjqAbbyM3vIi1uokIu(Ypy((ZVkoMiDKUsT94m2KmO6UOZQ4iNo4P2oF)5DvHx1onk9qqk9Sma8wSbOiGqSuLZF)8noF)5Hz(vXXUlt5c5itT1dBGK9hbeILQCEunFJZJg98OEE2WKYXUlt5c5itT1dBGK9hj1GGP18qpp0ZJg98WmVRerQPCuZ2l(Sz089NFvCuwE4dO4iNo4P2oF)5DvHx1onk9qqk9Sma8wSbOiGqSuLZF)8noF)5Hz(vXXUlt5c5itT1dBGK9hbeILQCEunFJZJg98OEE2WKYXUlt5c5itT1dBGK9hj1GGP18qpp0ZJg98WmpmZ7krKAkhvYbkCbwZJg98UsePMYr4(bPPZJg98UsePMYrTuAEONV)8RIJDxMYfYrMARh2aj7pYPdEQTZ3F(vXXUlt5c5itT1dBGK9hbeILQC(7NVX5HoiGtjFudHccldaVfBa60bOUahAaL7eAkiqQbbtRWnbHfjDGSJZsdc(kAdqYR5xflNNma2)8528TvQTZNkxZBZlVmWAEzhPRuBNV7YKuqWCCwAqWzy8XCCw6bNsoi4ajtG0ccWmVRerQPCuZ2l(Sz089Nh1ZVkoklp8buCKth8uBNV)8UQWRANgLLh(akocielv583p)EMh65rJEEyM3vIi1uokIu(Ypy((ZJ65xfhtKosxP2ECgBsguDx0zvCKth8uBNV)8UQWRANgtKosxP2ECgBsguDxueqiwQY5VF(9mp0ZJg98WmpmZ7krKAkhvYbkCbwZJg98UsePMYr4(bPPZJg98UsePMYrTuAEONV)8SHjLJDxMYfYrMARh2aj7psQbbtR57ppQNFvCS7YuUqoYuB9Wgiz)roDWtTD((Z7QcVQDAS7YuUqoYuB9Wgiz)raHyPkN)(53Z8qheWPKpQHqbHvXNoa1f4qdOGsOPGaPgemTc3eemhNLgewga(rwE4GWIKoq2XzPbbF928W6lt5czEHuB9Wgiz)ZNY550bp1wFMp55t58sBJMNR59K083LbGpVq5HdcoqYeiTGWQ4y3LPCHCKP26HnqY(JC6GNABGdnGsJHMccKAqW0kCtqWbsMaPfeq98SHjLJDxMYfYrMARh2aj7psQbbtR57ppmZVkoklp8buCKth8uBNhn65xfhtKosxP2ECgBsguDx0zvCKth8uBNh6GG54S0GWYaWpYYdh4qdO08qtbbsniyAfUjiyoolni0DzkxihzQTEydKS)GWIKoq2XzPbbb)QBEy9LPCHmVqQTEydKS)53L818IDqkF5hSFdz7fpFZCJM3vIi1uE(vX(mFXxeyxkP59K08LoVRk8Q2PX591BZ3mH05hqgEEyvWsn1rZdXBBB(uoFQUcj1wFM)QWR59uoXZNS4Y5bKT8ppmOi2MxsUsxY5TnMaZ7jjOdcoqYeiTGGRerQPCuZ2l(Sz089NNteAEunVVmF)5DvHx1onklp8buCeqiwQY5VFEuMV)8WmVRk8Q2PrcPZpGm8Pal1uhfbeILQC(7NhL7UX5rJEEuppT3EzxhTIesNFaz4tbwQPoAEOdCObu2tOPGaPgemTc3eeCGKjqAbbxjIut5Ois5l)G57ppNi08OAEFz((Z7QcVQDAmr6iDLA7XzSjzq1DrraHyPkN)(5rz((ZdZ8UQWRANgjKo)aYWNcSutDueqiwQY5VFEuU7gNhn65r980E7LDD0ksiD(bKHpfyPM6O5Hoiyoolni0DzkxihzQTEydKS)ahAafFj0uqGudcMwHBccMJZsdcDxMYfYrMARh2aj7piSiPdKDCwAqObYbkCbwZVl5R5fRgM2s38ndGXxZ7mjlNV7YuUqMxMARh2aj7F(uNhNkn)UKVM)UixIyCQTZFtH5GGdKmbsli4krKAkhvYbkCbwZ3FEGNsBfOLIigM2s3zhW4RiPgemTMV)8CIqZJQ59L57pVRk8Q2PXf5seJtT9aPWCeqiwQY5VF(MpF)5HzExv4vTtJesNFaz4tbwQPokcielv583ppk3DJZJg98OEEAV9YUoAfjKo)aYWNcSutD08qh4qdOC3HMccKAqW0kCtqWCCwAqO7YuUqoYuB9Wgiz)bHfjDGSJZsdcWQ8fbM3vIi1uwopmP6WERuBNxlDVeRnJ5BGCGc65DMKNhwlmFPZ7QcVQDAqWbsMaPfeGzExjIut5iC)G005rJEExjIut5OwknpA0ZdZ8UsePMYrLCGcxG189Nh1Zd8uARaTueXW0w6o7agFfj1GGP18qpp0Z3FEyM3vfEv70iH05hqg(uGLAQJIacXsvo)9ZJYD348OrppQNN2BVSRJwrcPZpGm8Pal1uhnp0bo0akn7qtbbsniyAfUji4ajtG0ccqkPC((ZVLTx8bqiwQY5VFEuU7GG54S0Gq3LPCHCKP26HnqY(dCObueBHMccKAqW0kCtqyrshi74S0GGVEBEy9LPCHmVqQTEydKS)5t58C6GNARpZNS4Y55eHMNR59K08fFrG5rmXUfy(vXYGG54S0GGZW4J54S0doLCqWbsMaPfewfh7UmLlKJm1wpSbs2FKth8uBNV)8WmVRerQPCuZ2l(Sz08OrpVRerQPCueP8LFW8qheWPKpQHqbbxjIut5ahAafX(qtbbsniyAfUjiyoolniyTL6pi4ajtG0ccRIJwBP(JacXsvo)9ZVNGGZVdth2aTeldnGsGdn04DcnfemhNLgeUmpLdcKAqW0kCtGdn0ikHMccKAqW0kCtqWCCwAqqs06uBhxbaEDCwAqyrshi74S0GGqTBE(IMxGOLC(sNV5ZZgOLy58528jpFkvX55DEaaPm2)8Po)goBV45lW8LopFrZZgOL448nJKVMxi7UkDEyl3O5twC58gwwZdHyMaZZ18EsAEbIwZxIiW8iM6zyS)5TUoS)uBNV5Zdlfa41XzPYyqWbsMaPfemhNIOdPessY5r18noF)5zdtkhL1UdFrhjrlzKudcMwZ3FEup)Q4OKO1P2oUca864S0iNo4P2oF)5r98PE2Wz7fh4qdn2yOPGaPgemTc3eeCGKjqAbbZXPi6qkHKKCEunFJZ3FE2WKYrz2Dv6bNBuKudcMwZ3FEup)Q4OKO1P2oUca864S0iNo4P2oF)5r98PE2Wz7fpF)5xfhDfa41XzPraHyPkN)(53tqWCCwAqqs06uBhxbaEDCwAGdn0yZdnfei1GGPv4MGGdKmbsliaZ8YYdFKxgynpQMhL5rJEEZXPi6qkHKKCEunFJZd989N3vfEv70O0dbP0ZYaWBXgGIacXsvopQMhLgdcMJZsdcIsmDylvoWHgACpHMccKAqW0kCtqWbsMaPfemhNIOZQ4ONkzdcMo22goDCw689M)oZJg98C6GNA789NFvC0tLSbbthBBdNoolncielv583p)EccMJZsdcEQKniy6yBB40XzPbo0qJ(sOPGaPgemTc3eemhNLgeKz3vPhCUrbbhizcKwqyvCuMDxLEW5gfbeILQC(7NFpbbNFhMoSbAjwgAaLahAOX7o0uqGudcMwHBccoqYeiTGaQN3vIi1uoQKdu4cSccsgKoo0akbbZXzPbbNHXhZXzPhCk5GaoL8rneki4krKAkh4qdn2Sdnfei1GGPv4MGG54S0GGRaaVoolni487W0HnqlXYqdOeeCGKjqAbbZXPi6qkHKKC(7NFpZVxZdZ8SHjLJYA3HVOJKOLmsQbbtR5rJEE2WKYrz2Dv6bNBuKudcMwZd989NFvC0vaGxhNLgbeILQC(7NVXGWIKoq2XzPbbXsxh2)8WsbaEDCw68iM6zyS)5lDEu2RgNNnqlXsFMVaZx68nF(DjFnVybISWEmnpSuaGxhNLg4qdnk2cnfei1GGPv4MGG54S0GaIHPT0Dawh7bOGWIKoq2XzPbbXYgtG55lA(QJuc4Z8YosxZBZlVmWA(DxKoVXZ7lZx68IvdtBPBEFL1XEaAEUM3ev5A(sebCwxxQTbbhizcKwqqwE4J8YaR5r187z((ZZjcnpQMVrucCOHgf7dnfei1GGPv4MGWIKoq2XzPbHMXfPZRfpV0V6sTDEy9LPCHmVqQTEydKS)55AEXoiLV8d2VHS9INVzUr(mVGhcsPZFxgaEl2a08528ggp)Qy58gGM366WjTccMJZsdcodJpMJZsp4uYbbhizcKwqaM5DLisnLJIiLV8dMV)8OEE2WKYXUlt5c5itT1dBGK9hj1GGP189NFvCmr6iDLA7XzSjzq1DrNvXroDWtTD((Z7QcVQDAu6HGu6zza4Tydqrazl)Zd98OrppmZ7krKAkh1S9IpBgnF)5r98SHjLJDxMYfYrMARh2aj7psQbbtR57p)Q4OS8WhqXroDWtTD((Z7QcVQDAu6HGu6zza4Tydqrazl)Zd98OrppmZdZ8UsePMYrLCGcxG18OrpVRerQPCeUFqA68OrpVRerQPCulLMh657pVRk8Q2PrPhcsPNLbG3InafbKT8pp0bbCk5JAiuqyza4TydqNoa1f4qdn)oHMccKAqW0kCtqWCCwAqyza4hz5Hdcls6azhNLgeGvkP5VldaFEHYdpFUn)Dza4TydqZVRuX55HqZdiB5FER1s1N5lW85288fbO53Ly88qO5nEEmzsE(gNhPa083LbG3InanVNKKbbhizcKwqasjLZ3FExv4vTtJspeKspldaVfBakcielv58OA(TS9IpacXsvoF)5HzEuppBys5y3LPCHCKP26HnqY(JKAqW0AE0ON3vfEv70y3LPCHCKP26HnqY(JacXsvopQMFlBV4dGqSuLZdDGdn0Cucnfei1GGPv4MGGdKmbsliaPKY57ppQNNnmPCS7YuUqoYuB9Wgiz)rsniyAnF)5DvHx1onk9qqk9Sma8wSbOiGqSuLZF78UQWRANgLEiiLEwgaEl2auC5bmolD(7NFlBV4dGqSuLbbZXzPbHLbGFKLhoWHgAEJHMccKAqW0kCtqyrshi74S0GaSyS7AVmmE(KjK59Kwln)wbM3u)8vQTZRfpVSJC5wsR5jSK2Drakiyoolni4mm(yool9GtjheWPKpQHqbHKjKahAO5np0uqGudcMwHBccoqYeiTGaBys5O8Yw1UdHabyoksQbbtR57ppmZViiEBBr5LTQDhcbcWCuuYMd(83ppmZ348718MJZsJYlBv7oqkmht9SHZ2lEEONhn65xeeVTTO8Yw1UdHabyokcielv583pFZNh6GG54S0GGZW4J54S0doLCqaNs(OgcfeKuGdn089eAkiqQbbtRWnbbZXzPbbedtBP7aSo2dqbHfjDGSJZsdcWkL08IvdtBPBEFL1XEaA(DxKopIj2TaZVkwoVbO5968z(cmFUnpFraA(DjgppeAEz2Q5w6mLNNteAEpLt888fnVsWoppS(YuUqMxi1wpSbs2FCEF928ECIZMzP2oVy1W0w6MVzam(YN5Vk8AEBE5LbwZZ18aAdqYR55lAEiEBBbbhizcKwqaM5xfhfLy6WwQCKth8uBNhn65xfhtKosxP2ECgBsguDx0zvCKth8uBNhn65xfhLLh(akoYPdEQTZd989NhM5r98apL2kqlfrmmTLUZoGXxrsniyAnpA0ZdXBBlIyyAlDNDaJVIs2CWN)(5B(8OrpVS8Wh5LbwZJQ5rzEOdCOHM7lHMccKAqW0kCtqWCCwAqaXW0w6oaRJ9auqyrshi74S0GaSsjnVy1W0w6M3xzDShGMNR5rSuzl155lAEedtBPB(DaJVMhI3228EkN45LxgyjNxjAnpxZdHMVLucymTMFRaZZx08kb788q8asE(DPUQDZdtJ3zEj5kDjNpLZJuaAE(Y05LEBBPljLNNR5BjLagtZ385LxgyjHoi4ajtG0ccapL2kqlfrmmTLUZoGXxrsniyAnF)5DvHx1onklp8buCeqiwQY5r18nEN57ppeVTTiIHPT0D2bm(kcielv583p)EcCOHMF3HMccKAqW0kCtqWCCwAqaXW0w6oaRJ9auqyrshi74S0GGy1sLTuNxSAyAlDZ3magFnVXZBy88CIqY53kW88fnFdKdu4cSMVaZl2j)G005DLisnLdcoqYeiTGaWtPTc0sredtBP7Sdy8vKudcMwZ3FEyM3vIi1uoQKdu4cSMhn65DLisnLJW9dstNh657ppeVTTiIHPT0D2bm(kcielv583p)EcCOHM3Sdnfei1GGPv4MGG54S0GaIHPT0Dawh7bOGWIKoq2XzPbbyLsAEXQHPT0nVVY6ypanFPZdRVmLlK5fsT1dBGK9pVZKS0N5rm4P2oV0dqZZ18stenVnV8YaR55AEjBo4ZlwnmTLU5BgaJVMp3M3tMA78jheCGKjqAbb2WKYXUlt5c5itT1dBGK9hj1GGP189NhM5xfh7UmLlKJm1wpSbs2FKth8uBNhn65DvHx1on2DzkxihzQTEydKS)iGqSuLZJQ5B0xMhn65Hus589NNte6W1zL083pVRk8Q2PXUlt5c5itT1dBGK9hbeILQCEONV)8WmpQNh4P0wbAPiIHPT0D2bm(ksQbbtR5rJEEiEBBredtBP7Sdy8vuYMd(83pFZNhn65LLh(iVmWAEunpkZdDGdn0CXwOPGaPgemTc3eeCGKjqAbb2WKYrzT7Wx0rs0sgj1GGPvqWCCwAqaXW0w6oaRJ9auGdn0CX(qtbbsniyAfUjiyoolniSawQhCUrbHfjDGSJZsdc3fWsDEyl3O5t58LI9pVn)DbRfMV1sD(DjFnVVwjrjBqW083fHKsAELmW8igSpVKnhCzCEF928Bz7fpFkN3GuE88CnpPR5x18AXZJKs58YosxP2opFrZlzZbxgeCGKjqAbbiEBBXujrjBqW0zriPKIs2CWNhvZVN7mpA0ZdXBBlMkjkzdcMolcjLu0RB((ZdPKY57p)w2EXhaHyPkN)(53tGdnSN7eAkiqQbbtRWnbbZXzPbbNHXhZXzPhCk5GaoL8rneki4krKAkh4qd7bLqtbbsniyAfUjiyoolniyTL6pi4ajtG0ccaAdqYldcMcco)omDyd0sSm0akbo0WEAm0uqGudcMwHBccoqYeiTGG54ueDwfh9ujBqW0X22WPJZsNV383zE0ONNth8uBNV)8aAdqYldcMccMJZsdcEQKniy6yBB40XzPbo0WEAEOPGaPgemTc3eemhNLgeKz3vPhCUrbbhizcKwqaqBasEzqWuqW53HPdBGwILHgqjWHg2ZEcnfei1GGPv4MGG54S0GGRaaVoolni4ajtG0ccaAdqYldcMMV)8MJtr0Hucjj583p)EMFVMhM5zdtkhL1UdFrhjrlzKudcMwZJg98SHjLJYS7Q0do3OiPgemTMh6GGZVdth2aTeldnGsGdnShFj0uqivMaaVooiGsqWCCwAqybSupYYdhei1GGPv4MahAyp3DOPGG54S0GG8Yw1UdKcZbbsniyAfUjWboi0bixHaX4qtHgqj0uqGudcMwHBccoqYeiTGaNi08OA(7mF)5r98DehnCkIMV)8OEEiEBBXwqIujGo12rAoqULok61femhNLge2i8zviPACwAGdn0yOPGG54S0GG0dbP0ZgHV8uMabbsniyAfUjWHgAEOPGaPgemTc3eeudHccCHqNA7GuQKbLN84kvYaphNLkdcMJZsdcCHqNA7GuQKbLN84kvYaphNLkdCOH9eAkiqQbbtRWnbb1qOGGSWKDjpsYbi(WK7sZ92JccMJZsdcYct2L8ijhG4dtUln3BpkWHg8LqtbbsniyAfUji4ajtG0ccSHjLJTGePsaDQTJ0CGClDuKudcMwbbZXzPbHwqIujGo12rAoqULokWHgU7qtbbsniyAfUjiuDbbjXbbZXzPbbrginiykiiYWEuqWCCkIoRIJUca864S05r183z((ZBoofrNvXrRTu)ZJQ5VZ89N3CCkIoRIJEQKniy6yBB40XzPZJQ5VZ89NhM5r98SHjLJYS7Q0do3OiPgemTMhn65nhNIOZQ4Om7Uk9GZnAEun)DMh657ppmZVko2DzkxihzQTEydKS)iNo4P2opA0ZJ65zdtkh7UmLlKJm1wpSbs2FKudcMwZdDqqKboQHqbHvXYdGSL)ahAOzhAkiqQbbtRWnbb1qOGG1mtEzatE2kLp12PR2rGGG54S0GG1mtEzatE2kLp12PR2rGahAqSfAkiqQbbtRWnbbZXzPbbjrRtTDCfa41XzPbbhizcKwqq2ry8HnqlXYOKO1P2oUca864S0Jv08OQ38npiGtLoUvqaL7e4qdI9HMccMJZsdcxMNYbbsniyAfUjWHgq5oHMccMJZsdcEQKniy6yBB40XzPbbsniyAfUjWboiyffAk0akHMccMJZsdcDxMYfYrMARh2aj7piqQbbtRWnbo0qJHMccMJZsdcxMNYbbsniyAfUjWHgAEOPGaPgemTc3eeCGKjqAbbxjIut5Ois5l)G57p)Q4yI0r6k12JZytYGQ7IoRIJC6GNA789N3vfEv70O0dbP0ZYaWBXgGIaYw(NV)8Wm)Q4y3LPCHCKP26HnqY(JacXsvopQMVX5rJEEuppBys5y3LPCHCKP26HnqY(JKAqW0AEONhn65DLisnLJA2EXNnJMV)8RIJYYdFafh50bp1257pVRk8Q2PrPhcsPNLbG3InafbKT8pF)5Hz(vXXUlt5c5itT1dBGK9hbeILQCEunFJZJg98OEE2WKYXUlt5c5itT1dBGK9hj1GGP18qppA0ZdZ8UsePMYrLCGcxG18OrpVRerQPCeUFqA68OrpVRerQPCulLMh657p)Q4y3LPCHCKP26HnqY(JC6GNA789NFvCS7YuUqoYuB9Wgiz)raHyPkN)(5Bmiyoolni4mm(yool9GtjheWPKpQHqbHLbG3InaD6auxGdnSNqtbbsniyAfUji4ajtG0ccSHjLJYA3HVOJKOLmsQbbtR57pVZ0JKOvqWCCwAqqs06uBhxbaEDCwAGdn4lHMccKAqW0kCtqWbsMaPfeq98SHjLJYA3HVOJKOLmsQbbtR57ppQNFvCus06uBhxbaEDCwAKth8uBNV)8OE(upB4S9INV)8RIJUca864S0iG2aK8YGGPGG54S0GGKO1P2oUca864S0ahA4Udnfei1GGPv4MGG54S0GG1wQ)GGdKmbsliyoofrNvXrRTu)ZF)87z((ZJ65xfhT2s9h50bp12GGZVdth2aTeldnGsGdn0Sdnfei1GGPv4MGG54S0GG1wQ)GGdKmbsliyoofrNvXrRTu)ZJQEZVN57ppG2aK8YGGP57p)Q4O1wQ)iNo4P2geC(Dy6WgOLyzObucCObXwOPGaPgemTc3eeCGKjqAbbZXPi6Sko6Ps2GGPJTTHthNLoFV5VZ8OrppNo4P2oF)5b0gGKxgemfemhNLge8ujBqW0X22WPJZsdCObX(qtbbsniyAfUjiyoolni4Ps2GGPJTTHthNLgeCGKjqAbbuppNo4P2oF)57e1XgMuocmKot5JTTHthNLkJKAqW0A((ZBoofrNvXrpvYgemDSTnC64S05VF(MheC(Dy6WgOLyzObucCObuUtOPGaPgemTc3eeCGKjqAbbz5HpYldSMhvZJsqWCCwAqquIPdBPYbo0akOeAkiqQbbtRWnbbhizcKwqa1Z7krKAkhvYbkCbwbbjdshhAaLGG54S0GGZW4J54S0doLCqaNs(OgcfeCLisnLdCObuAm0uqGudcMwHBccoqYeiTGamZ7krKAkhfrkF5hmF)5HzExv4vTtJjshPRuBpoJnjdQUlkciB5FE0ONFvCmr6iDLA7XzSjzq1DrNvXroDWtTDEONV)8UQWRANgLEiiLEwgaEl2aueq2Y)89NhM5xfh7UmLlKJm1wpSbs2FeqiwQY5r18nopA0ZJ65zdtkh7UmLlKJm1wpSbs2FKudcMwZd98qpF)5HzEyM3vIi1uoQKdu4cSMhn65DLisnLJW9dstNhn65DLisnLJAP08qpF)5DvHx1onk9qqk9Sma8wSbOiGqSuLZF)8noF)5Hz(vXXUlt5c5itT1dBGK9hbeILQCEunFJZJg98OEE2WKYXUlt5c5itT1dBGK9hj1GGP18qpp0ZJg98WmVRerQPCuZ2l(Sz089NhM5DvHx1onklp8buCeq2Y)8Orp)Q4OS8WhqXroDWtTDEONV)8UQWRANgLEiiLEwgaEl2aueqiwQY5VF(gNV)8Wm)Q4y3LPCHCKP26HnqY(JacXsvopQMVX5rJEEuppBys5y3LPCHCKP26HnqY(JKAqW0AEONh6GG54S0GGZW4J54S0doLCqaNs(OgcfewgaEl2a0PdqDbo0aknp0uqGudcMwHBccoqYeiTGaKskNV)8UQWRANgLEiiLEwgaEl2aueqiwQY5r18Bz7fFaeILQC((ZdZ8OEE2WKYXUlt5c5itT1dBGK9hj1GGP18OrpVRk8Q2PXUlt5c5itT1dBGK9hbeILQCEun)w2EXhaHyPkNh6GG54S0GWYaWpYYdh4qdOSNqtbbsniyAfUji4ajtG0ccqkPC((Z7QcVQDAu6HGu6zza4TydqraHyPkN)25DvHx1onk9qqk9Sma8wSbO4YdyCw683p)w2EXhaHyPkdcMJZsdclda)ilpCGdnGIVeAkiqQbbtRWnbbZXzPbbNHXhZXzPhCk5GaoL8rnekiKmHe4qdOC3HMccKAqW0kCtqWCCwAqWzy8XCCw6bNsoiGtjFudHcclcB(P1HbPcNyzGdnGsZo0uqGudcMwHBccMJZsdcodJpMJZsp4uYbbCk5JAiuqyziwlDyqQWjwg4qdOi2cnfei1GGPv4MGGdKmbsliSko2DzkxihzQTEydKS)iNo4P2opA0ZJ65zdtkh7UmLlKJm1wpSbs2FKudcMwbbZXzPbbNHXhZXzPhCk5GaoL8rnekiizJpmiv4eldCObue7dnfei1GGPv4MGGdKmbsliSkokkX0HTu5iNo4P2gemhNLgeqmmTLUdW6ypaf4qdnENqtbbsniyAfUji4ajtG0ccRIJYYdFafh50bp1257ppQNNnmPCuw7o8fDKeTKrsniyAfemhNLgeqmmTLUdW6ypaf4qdnIsOPGaPgemTc3eeCGKjqAbbuppBys5OOeth2sLJKAqW0kiyoolniGyyAlDhG1XEakWHgASXqtbbsniyAfUji4ajtG0ccYYdFKxgynpQMFpbbZXzPbbedtBP7aSo2dqbo0qJnp0uqGudcMwHBccMJZsdcYS7Q0do3OGGdKmbsliyoofrNvXrz2Dv6bNB0833B(MpF)5b0gGKxgemnF)5r98RIJYS7Q0do3OiNo4P2geC(Dy6WgOLyzObucCOHg3tOPGaPgemTc3eeCGKjqAbbxjIut5OsoqHlWkiizq64qdOeemhNLgeCggFmhNLEWPKdc4uYh1qOGGRerQPCGdn0OVeAkiqQbbtRWnbbhizcKwqaI32wmvsuYgemDweskPOKnh85rvV59L7mpA0ZdPKY57ppeVTTyQKOKniy6SiKusrVU57p)w2EXhaHyPkN)(59L5rJEEiEBBXujrjBqW0zriPKIs2CWNhv9MV5(Y89NFvCuwE4dO4iNo4P2gemhNLgewal1do3OahAOX7o0uqivMaaVooiGsqWCCwAqybSupYYdhei1GGPv4MahAOXMDOPGG54S0GG8Yw1UdKcZbbsniyAfUjWboiKmHeAk0akHMccMJZsdcEs6KmHidcKAqW0kCtGdCqqsHMcnGsOPGG54S0GWL5PCqGudcMwHBcCOHgdnfei1GGPv4MGqQmbaED8j3cclcI32wuEzRA3HqGamhfLS5GJQEnpiyoolniSawQhz5HdcPYea41XNwCbXWbbucCOHMhAkiyoolniiVSvT7aPWCqGudcMwHBcCGdcs24ddsfoXYqtHgqj0uqGudcMwHBccQHqbHuLoGhBqW0zV9mL9qolsu6OGG54S0GqQshWJniy6S3EMYEiNfjkDuGdn0yOPGaPgemTc3eeudHccPkzGNJlG8SsrPshieghemhNLgesvYaphxa5zLIsLoqimoWHgAEOPGaPgemTc3eeudHccLicSHRDP2EmnrSJZAPGG54S0GqjIaB4AxQThtte74SwkWHg2tOPGaPgemTc3eeudHccldahPk9Sih8tNhdiPJuhfemhNLgewgaosv6zro4NopgqshPokWHg8LqtbbsniyAfUjiOgcfeqmNbbqh5fr8bXtMUGG54S0GaI5mia6iViIpiEY0f4qd3DOPGaPgemTc3eeudHccBydHo12bIXmMccMJZsdcBydHo12bIXmMcCOHMDOPGaPgemTc3eeudHcc7m4Ksa5zdu6kiyoolniSZGtkbKNnqPRahAqSfAkiqQbbtRWnbb1qOGaBqWeFQTZIKDwcccMJZsdcSbbt8P2ols2zjiWHge7dnfei1GGPv4MGGAiuqqM6Mh(yYUeyklpqSvlDQTZgbkxY(dcMJZsdcYu38Wht2Latz5bITAPtTD2iq5s2FGdnGYDcnfei1GGPv4MGGAiuqqM6Mh(0ITvACbKhi2QLo12zJaLlz)bbZXzPbbzQBE4tl2wPXfqEGyRw6uBNncuUK9h4qdOGsOPGG54S0GaeCvRZMhWFqGudcMwHBcCObuAm0uqWCCwAqylbeeCvRGaPgemTc3e4qdO08qtbbZXzPbbieqsa4P2gei1GGPv4Mah4ahemp(QabbHebwcCGdba]] )


end