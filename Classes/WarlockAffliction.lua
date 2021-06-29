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


    spec:RegisterPack( "Affliction", 20210628, [[d808KcqiiHfjLqPhri0MKQ6tesJcqDkGyvsjKELkLMfvIBjLQSlH(LkjdtLkogK0YOs6zsPY0ujLRjLGTPsQ8nGKY4ujvDoPeQwhHiZtLQUNuL9bK6GecSqvkEiqIjQsLCrPeInQsLk(OuQQ0jjeLvciZesKBkLQYoLs6NajvdLqqlLqu9ucMQukxvkvvTvPuvXxvPszSsjAVc(RkgSQomLfdWJPQjRKlJAZkLplfJwP60IwTkvQ61a1SH62qSBs)wYWLkhhijlh0ZjA6ixNk2oH67QeJhsuNNk16LsOy(qQ7RsLkTFfhqn0wqyzehA1174kQ356C96JU2URDDUE9bbYDhhe6mpyRHdcQHWbbrW2go9uwAqOZCJlBfAliilhONdc7e1jfPRUQjPDharFHCLmrCWgLL6H2gDLmr8xfea4KysKPbabHLrCOvxVJROENRZ1Rp6A7U21H61feKDSp0QRxxlee2Z1I1aGGWIL(GGiyBdNEklD(7MbXLh8aeqokpVRxVlZ76DCf1bObiqz30gwksdqT38IG1IxZl0Xy88Ou5bhhGAV5fbRfVM)UyXLdC(2N1K(4au7nViyT418aGSb2VBQY45Xvt6NFRGZFxql15fkhCCaQ9MVTlSbE(2NH5T0pVi36ihippUAs)8un)LccE(CBE3LJOqEEKuktTzEBEYWSsZN680UrZdRlXbO2B(we1aG55f5gsNP08IGTnC6PSu58IqXIW5jdZkfhGAV5B7cBGLZt18M4kxZdaxxsTz(7YGGBWgKNp15rCWu2EKbByA(lxvZFxG6TjN3Ploa1EZdkLUyvYZlleE(7YGGBWgKNxec5U59gglNNQ5H8YXZZ7lKohYOS05PeHJdqT38cmnVSq459ggFmpLLEWPKMNvcMSCEQMxsW0tZt18M4kxZ73zp4uBMhNssopTB08xkvuAEa88q2878AEGTglvuasCaQ9MhuxXUNxG518L6557GC715GXXbO2BErW6U3rsZ3IfGduNhuUl58a4TcYZZ6A(AB(TSzNAXopUAs)8unV11HDpFPy3Zt18akPC(TSzNKZdSw08e0K7Z3zEWsqIbHoyTLyoiiII48IGTnC6PS05VBgexEWdqIOiopqokpVRxVlZ76DCf1bObirueNhu2nTHLI0aKikIZ3EZlcwlEnVqhJXZJsLhCCasefX5BV5fbRfVM)UyXLdC(2N1K(4aKikIZ3EZlcwlEnpaiBG97MQmEEC1K(53k483f0sDEHYbhhGerrC(2B(2UWg45BFgM3s)8ICRJCG884Qj9Zt18xki45ZT5DxoIc55rsPm1M5T5jdZknFQZt7gnpSUehGerrC(2B(we1aG55f5gsNP08IGTnC6PSu58IqXIW5jdZkfhGerrC(2B(2UWgy58unVjUY18aW1LuBM)Umi4gSb55tDEehmLThzWgMM)Yv183fOEBY5D6IdqIOioF7npOu6IvjpVSq45VldcUbBqEEriK7M3BySCEQMhYlhppVVq6CiJYsNNseooajII48T38cmnVSq459ggFmpLLEWPKMNvcMSCEQMxsW0tZt18M4kxZ73zp4uBMhNssopTB08xkvuAEa88q2878AEGTglvuasCasefX5BV5b1vS75fyEnFPEE(oi3EDoyCCasefX5BV5fbR7EhjnFlwaoqDEq5UKZdG3kippRR5RT53YMDQf784Qj9Zt18wxh298LIDppvZdOKY53YMDsopWArZtqtUpFN5blbjoanazEklvg7GSVqayuVngFwfsQgLL6sU1Jseg03Ppk6ykA4um3hfaC22InWePsiFQTJ08WCl9C0PBaY8uwQm2bzFHaWOB7DL0bbP0thtdqMNYsLXoi7leagDBVRAGjsLq(uBhP5H5w6zxYTEKHzLInWePsiFQTJ08WCl9CKvdaMxdqMNYsLXoi7leagDBVReBW0aGzxudH7TksEGSTC7Iyd7W9mpLI5ZQOOVGqNoklf03PV5PumFwffTMsDd67038ukMpRIIoQKmay(yBB40tzPG(o9bgfKHzLIYSBV0do34iRgamVqJ28ukMpRIIYSBV0do3yqFhq6d8QOy3UPuHCKP24GnysUJu6bNAdA0OGmmRuSB3uQqoYuBCWgmj3rwnayEbYaK5PSuzSdY(cbGr327khjFsIrCrneUN1IrUBqtE2kLo12PRUWWbiZtzPYyhK9fcaJUT3vsMxNA74li0PJYsDbNkF8REOEhxYTEYogJpKbBysgLmVo12XxqOthLLESIbDV2nazEklvg7GSVqay0T9UA3CuAaY8uwQm2bzFHaWOB7DLJkjdaMp22go9uw6a0aKikIZ3IGYS3H418Syg6EEkr45PDEEZtfC(uoVj2sSbaZXbiZtzPYEYogJp4YdEaY8uwQ82ExTyXLd8GynPFaY8uwQ82Ex5nm(yEkl9Gtj5IAiCpRyxKem9upuDj36zEkfZhwzKKLGUDdqI48IapLLopoLKC(TcopbtfmtZdG3nXzbJZlqgjN3G88stmVMFRGZdG3kipVq5GNxKx0vImKowxP2mpOyKjjy1TZxjc3nLkK5fsTXbBWKC7Y8fTZWlPKNV059vHx1fDaY8uwQ82Ex5nm(yEkl9Gtj5IAiCpcMkyMoYoCsh)o7bpazEklvEBVR8ggFmpLLEWPKCrneU3IXMBEDiyQGzsoazEklvEBVR8ggFmpLLEWPKCrneUNKm6qWubZK0fjbtp1dvxYTEaVkkklh8bwuKsp4uBqJEvumr6yDLAZXBKjjy1TZNvrrk9GtTbn6vrXUDtPc5itTXbBWKChP0do1gq6llh8rUBWfOBhA0RIIItmFilvksPhCQnOrtgMvkkRlhANpsMxYbiZtzPYB7DL3W4J5PS0doLKlQHW9wgI1WhcMkyMKUKB98LywnLIA2StNnJ7dmkeBW0aG5ibtfmthzhoj0O9vHx1fnklh8bwueYiwQsq76DqJgyXgmnayosWubZ0PuUVVk8QUOrz5GpWIIqgXsvEpbtfmtruJ(QWR6IgHmILQee0ObwSbtdaMJemvWmDOlvFFv4vDrJYYbFGffHmILQ8EcMkyMIUg9vHx1fnczelvjiGGgTVeZQPuumR0UByFGrHydMgamhjyQGz6i7WjHgTVk8QUOXePJ1vQnhVrMKGv3ohHmILQe0UEh0ObwSbtdaMJemvWmDkL77RcVQlAmr6yDLAZXBKjjy1TZriJyPkVNGPcMPiQrFv4vDrJqgXsvccA0al2GPbaZrcMkyMo0LQVVk8QUOXePJ1vQnhVrMKGv3ohHmILQ8EcMkyMIUg9vHx1fnczelvjiGGgnW(smRMsrL9WcxWfA0(smRMsrWUHPPOr7lXSAkf1szq6dmkeBW0aG5ibtfmthzhoj0O9vHx1fn2TBkvihzQnoydMK7iKrSuLG217GgnWInyAaWCKGPcMPtPCFFv4vDrJD7MsfYrMAJd2Gj5oczelv59emvWmfrn6RcVQlAeYiwQsqqJgyXgmnayosWubZ0HUu99vHx1fn2TBkvihzQnoydMK7iKrSuL3tWubZu01OVk8QUOriJyPkbbe0OrbzywPy3UPuHCKP24GnysUJSAaW8QpWOqSbtdaMJemvWmDKD4KqJ2xfEvx0O0bbP0ZYGGBWgKJqgXsvcAxVdA0al2GPbaZrcMkyMoLY99vHx1fnkDqqk9Smi4gSb5iKrSuL3tWubZue1OVk8QUOriJyPkbbnAGfBW0aG5ibtfmth6s13xfEvx0O0bbP0ZYGGBWgKJqgXsvEpbtfmtrxJ(QWR6IgHmILQeeqgGeX5VXbQZllh88YDdUKZNBZVLn708PCEdJusA(smdhGmpLLkVT3vigM3s)bADKdKDj36bOKY(BzZoDGmILQ8EgLzVdXhkr4wuz5GpYDdU6Vkk6OsYaG5JTTHtpLLgP0do1MbirCEr228(smRMsZVk6kr4UPuHmVqQnoydMK75t58qhvtTXL5DK883Lbb3GnippvZZOmX6AEANN37aHSsZlzAaY8uwQ82Ex5nm(yEkl9Gtj5IAiCVLbb3GniF6GCNl5wpG9LywnLIIzL2Dd7VkkMiDSUsT54nYKeS625ZQOiLEWP203xfEvx0O0bbP0ZYGGBWgKJqgXsvEVR9bEvuSB3uQqoYuBCWgmj3riJyPkbTROrJcYWSsXUDtPc5itTXbBWKCdciOrdSVeZQPuuZMD6SzC)vrrz5GpWIIu6bNAtFFv4vDrJsheKspldcUbBqoczelv59U2h4vrXUDtPc5itTXbBWKChHmILQe0UIgnkidZkf72nLkKJm1ghSbtYniGGgnWa7lXSAkfv2dlCbxOr7lXSAkfb7gMMIgTVeZQPuulLbP)QOy3UPuHCKP24GnysUJu6bNAt)vrXUDtPc5itTXbBWKChHmILQ8ExbzaseNxKZBqwUp)Qi58SbXUNp3MVPsTz(uPAEBE5UbxZl7yDLAZ8D7MKhGmpLLkVT3vEdJpMNYsp4usUOgc3Bv0PdYDUKB9a2xIz1ukQzZoD2mUpkwffLLd(alksPhCQn99vHx1fnklh8bwueYiwQY7VgiOrdSVeZQPuumR0UByFuSkkMiDSUsT54nYKeS625ZQOiLEWP203xfEvx0yI0X6k1MJ3itsWQBNJqgXsvE)1abnAGb2xIz1ukQShw4cUqJ2xIz1ukc2nmnfnAFjMvtPOwkdsFYWSsXUDtPc5itTXbBWKC3hfRIID7MsfYrMAJd2Gj5osPhCQn99vHx1fn2TBkvihzQnoydMK7iKrSuL3FnqgGeX5fzBZlc3nLkK5fsTXbBWKCpFkNNsp4uBCz(KMpLZlTnEEQM3rYZFxge88cLdEaY8uwQ82ExTmi4JSCWUKB9wff72nLkKJm1ghSbtYDKsp4uBgGmpLLkVT3vldc(ilhSl5wpuqgMvk2TBkvihzQnoydMK7(aVkkklh8bwuKsp4uBqJEvumr6yDLAZXBKjjy1TZNvrrk9GtTbKbirCEb3QFEr4UPuHmVqQnoydMK75VK0(8TFyL2DdVQ1SzNM)UJXZ7lXSAkn)QixMVODgEjL88osE(sN3xfEvx048IST5Brq6CdzdppOoCPM655b4STnFkNpvFHKAJlZVx418okL45tsu58q2wUNhyuV(5LSV0LCEBJy48osgKbiZtzPYB7Dv3UPuHCKP24GnysUDj365lXSAkf1SzNoBg3Nseg0TqFFv4vDrJYYbFGffHmILQ8Eu7dmbtfmtrgPZnKn8PGl1uph9vHx1fnczelv59OEDUIgnkyqLt21XRiJ05gYg(uWLAQNbzaY8uwQ82Ex1TBkvihzQnoydMKBxYTE(smRMsrXSs7UH9PeHbDl03xfEvx0yI0X6k1MJ3itsWQBNJqgXsvEpQ9bMGPcMPiJ05gYg(uWLAQNJ(QWR6IgHmILQ8EuVoxrJgfmOYj764vKr6CdzdFk4sn1ZGmazEklvEBVR62nLkKJm1ghSbtYTl5wpG9LywnLIk7HfUGl0O9LywnLIGDdttrJ2xIz1ukQLYG0hycMkyMImsNBiB4tbxQPEo6RcVQlAeYiwQY7r96CfnAuWGkNSRJxrgPZnKn8PGl1updYaK5PSu5T9UQB3uQqoYuBCWgmj3UKB9ausz)TSzNoqgXsvEpQx3aKioViBBEr4UPuHmVqQnoydMK75t58u6bNAJlZNKOY5PeHNNQ5DK88fTZW5rS7(co)Qi5aK5PSu5T9UYBy8X8uw6bNsYf1q4E(smRMsUKB9wff72nLkKJm1ghSbtYDKsp4uB6dSVeZQPuuZMD6SzmA0(smRMsrXSs7UHGmazEklvEBVRSMsD7I3ThZhYGnmj7HQl5wVvrrRPu3riJyPkV)AdqMNYsL327QDZrPbirCEH6Y80opVaZl58LoF7MNmydtY5ZT5tA(uQIsZ7DGqwjS75tD(nC2StZxW5lDEANNNmydtX5VBjTpVq2Tx68OuUXZNKOY5nSSMhatedNNQ5DK88cmVMVeZW5rm1XWy3ZBDDy3P2mF7Mhuki0PJYsLXbiZtzPYB7DLK51P2o(ccD6OSuxYTEMNsX8HvgjzjODTpzywPOSUCOD(izEj7JIvrrjZRtTD8fe60rzPrk9GtTPpks9SHZMDAaY8uwQ82ExjzEDQTJVGqNokl1LCRN5PumFyLrswcAx7tgMvkkZU9sp4CJ7JIvrrjZRtTD8fe60rzPrk9GtTPpks9SHZMDQ)QOOVGqNoklnczelv59xBaY8uwQ82ExjoX8HSujxYTEallh8rUBWfOrfnAZtPy(WkJKSe0UcsFFv4vDrJsheKspldcUbBqoczelvjOr11biZtzPYB7DLJkjdaMp22go9uwQl5wpZtPy(Skk6OsYaG5JTTHtpLL27oOrtPhCQn9xffDujzaW8X22WPNYsJqgXsvE)1gGmpLLkVT3vYSBV0do3yx8U9y(qgSHjzpuDj36TkkkZU9sp4CJJqgXsvE)1gGmpLLkVT3vEdJpMNYsp4usUOgc3ZxIz1uYfjbtp1dvxYTEOWxIz1ukQShw4cUgGeX5fbDDy3Zdkfe60rzPZJyQJHXUNV05rT9CDEYGnmjDz(coFPZ3U5VK0(8IaaYc7q88GsbHoDuw6aK5PSu5T9UYxqOthLL6I3ThZhYGnmj7HQl5wpZtPy(WkJKS8(R1EatgMvkkRlhANpsMxs0OjdZkfLz3EPhCUXG0Fvu0xqOthLLgHmILQ8ExhGeX5fbBedNN255RowzOlZl7yDnVnVC3GR5VSZ68gnFlmFPZ3(mmVL(5f5wh5a55PAEtCLR5lXm0BDDP2mazEklvEBVRqmmVL(d06ihi7sU1two4JC3GlqFT(uIWG2vuhGeX5VB7SoVw08s3Qp1M5fH7MsfY8cP24GnysUNNQ5B)WkT7gEvRzZon)DhJDzEbheKsN)Umi4gSb55ZT5nmE(vrY5nipV11HtEnazEklvEBVR8ggFmpLLEWPKCrneU3YGGBWgKpDqUZLCRhW(smRMsrXSs7UH9rbzywPy3UPuHCKP24GnysU7VkkMiDSUsT54nYKeS625ZQOiLEWP203xfEvx0O0bbP0ZYGGBWgKJq2wUbbnAG9LywnLIA2StNnJ7JcYWSsXUDtPc5itTXbBWKC3Fvuuwo4dSOiLEWP203xfEvx0O0bbP0ZYGGBWgKJq2wUbbnAGb2xIz1ukQShw4cUqJ2xIz1ukc2nmnfnAFjMvtPOwkdsFFv4vDrJsheKspldcUbBqoczB5gKbirC(2Fjp)DzqWZluo45ZT5VldcUbBqE(lLkknpaEEiBl3ZBnwQUmFbNp3MN2zip)LeJNhapVrZJztsZ768ifKN)Umi4gSb55DKSCaY8uwQ82ExTmi4JSCWUKB9auszFFv4vDrJsheKspldcUbBqoczelvjO3YMD6azelvzFGrbzywPy3UPuHCKP24GnysUrJ2xfEvx0y3UPuHCKP24GnysUJqgXsvc6TSzNoqgXsvcYaK5PSu5T9UAzqWhz5GDj36bOKY(OGmmRuSB3uQqoYuBCWgmj399vHx1fnkDqqk9Smi4gSb5iKrSuL36RcVQlAu6GGu6zzqWnydYXLd0OS073YMD6azelv5aKiopOyKFV9mmE(KyK5DKwdp)wbN3u30EQnZRfnVSJ95wYR5zSKVSZqEaY8uwQ82Ex5nm(yEkl9Gtj5IAiCVKyKbirueNxKZBqwUpVWUTQlZ3IGaaAEEEa8wb55LDSUsTzE5UbxY5lD(2NH5T0pVi36ihipazEklvEBVR8ggFmpLLEWPKCrneUNKDj36rgMvkk3TvD5WiaGMNJSAaW8QpWlgGZ2wuUBR6YHraanphLK5bFpWU2EMNYsJYDBvxoakmft9SHZMDce0OxmaNTTOC3w1LdJaaAEoczelv59TdKbirC(2FjpF7ZW8w6NxKBDKdKN)YoRZJy39fC(vrY5nipVtNlZxW5ZT5PDgYZFjX45bWZlZgn3sVP08uIWZ7OuINN255vgLP5fH7MsfY8cP24GnysUJZlY2M3HsC2Ij1M5BFgM3s)83nOr7Um)EHxZBZl3n4AEQMhYBqwUppTZZdWzBBaY8uwQ82ExHyyEl9hO1roq2LCRhWRIIItmFilvksPhCQnOrVkkMiDSUsT54nYKeS625ZQOiLEWP2Gg9QOOSCWhyrrk9GtTbK(aJcOJYBfSHJigM3s)5c0OD0Ob4STfrmmVL(ZfOr7rjzEW33o0OLLd(i3n4c0OcYaKioF7VKNV9zyEl9ZlYToYbYZt18iwQKL680oppIH5T0p)fOr7ZdWzBBEhLs88YDdUKZRmVMNQ5bWZ3WkdnIxZVvW5PDEELrzAEaoqjn)Lux1L5b217mVK9LUKZNY5rkippTB68sNTT0NSsZt18nSYqJ45B38YDdUKGmazEklvEBVRqmmVL(d06ihi7sU1d6O8wbB4iIH5T0FUanAVVVk8QUOrz5GpWIIqgXsvcAxVtFaoBBredZBP)CbA0EeYiwQY7V2aKioF7VKNV9zyEl9ZlYToYbYZx68IWDtPczEHuBCWgmj3Z7njjDzEedCQnZlDG88unV0eZZBZl3n4AEQMxsMh88TpdZBPF(7g0O95ZT5DKP2mFsdqMNYsL327kedZBP)aToYbYUKB9idZkf72nLkKJm1ghSbtYDFGxff72nLkKJm1ghSbtYDKsp4uBqJ2xfEvx0y3UPuHCKP24GnysUJqgXsvcAxBb0ObuszFkr4dvNvY37RcVQlASB3uQqoYuBCWgmj3riJyPkbPpWOa6O8wbB4iIH5T0FUanAhnAaoBBredZBP)CbA0EusMh89TdnAz5GpYDdUanQGmazEklvEBVRqmmVL(d06ihi7sU1JmmRuuwxo0oFKmVKdqI483f0sDEuk345t58LIDpVn)DjcfMVXsD(ljTpVitzXjzaW883fJKsEELn48igkpVKmpyzCEr228BzZonFkN3auo08unpRR5x18ArZJKs58YowxP2mpTZZljZdwoazEklvEBVRwql1do3yxYTEaC22IPYItYaG5ZIrsjhLK5bd6RDh0Ob4STftLfNKbaZNfJKso601hqjL93YMD6azelv59xBaY8uwQ82Ex5nm(yEkl9Gtj5IAiCpFjMvtPbiZtzPYB7DL1uQBx8U9y(qgSHjzpuDj36b5nil3nayEaY8uwQ82Ex5OsYaG5JTTHtpLL6sU1Z8ukMpRIIoQKmay(yBB40tzP9UdA0u6bNAtFiVbz5UbaZdqMNYsL327kz2Tx6bNBSlE3EmFid2WKShQUKB9G8gKL7gampazEklvEBVR8fe60rzPU4D7X8HmydtYEO6sU1dYBqwUBaWCFZtPy(WkJKS8(R1EatgMvkkRlhANpsMxs0OjdZkfLz3EPhCUXGmazEklvEBVRwql1JSCWUKkXqOth1d1biZtzPYB7DLC3w1LdGctdqdqMNYsLrR4ED7MsfYrMAJd2Gj5EaY8uwQmAfFBVR2nhLgGmpLLkJwX327kVHXhZtzPhCkjxudH7Tmi4gSb5thK7Cj365lXSAkffZkT7g2Fvumr6yDLAZXBKjjy1TZNvrrk9GtTPVVk8QUOrPdcsPNLbb3GnihHSTC3h4vrXUDtPc5itTXbBWKChHmILQe0UIgnkidZkf72nLkKJm1ghSbtYniOr7lXSAkf1SzNoBg3Fvuuwo4dSOiLEWP203xfEvx0O0bbP0ZYGGBWgKJq2wU7d8QOy3UPuHCKP24GnysUJqgXsvcAxrJgfKHzLID7MsfYrMAJd2Gj5ge0Ob2xIz1ukQShw4cUqJ2xIz1ukc2nmnfnAFjMvtPOwkds)vrXUDtPc5itTXbBWKChP0do1M(RIID7MsfYrMAJd2Gj5oczelv59UoazEklvgTIVT3vsMxNA74li0PJYsDj36rgMvkkRlhANpsMxY(EtpsMxdqMNYsLrR4B7DLK51P2o(ccD6OSuxYTEOGmmRuuwxo0oFKmVK9rXQOOK51P2o(ccD6OS0iLEWP20hfPE2WzZo1Fvu0xqOthLLgH8gKL7gampazEklvgTIVT3vwtPUDX72J5dzWgMK9q1LCRN5PumFwffTMsDF)16JIvrrRPu3rk9GtTzaY8uwQmAfFBVRSMsD7I3ThZhYGnmj7HQl5wpZtPy(SkkAnL6g09UwFiVbz5UbaZ9xffTMsDhP0do1MbiZtzPYOv8T9UYrLKbaZhBBdNEkl1LCRN5PumFwffDujzaW8X22WPNYs7Dh0OP0do1M(qEdYYDdaMhGmpLLkJwX327khvsgamFSTnC6PSux8U9y(qgSHjzpuDj36Hck9GtTPFN4oYWSsrOH0zkDSTnC6PSuzKvdaMx9npLI5ZQOOJkjdaMp22go9uw69TBaY8uwQmAfFBVReNy(qwQKl5wpz5GpYDdUanQdqMNYsLrR4B7DL3W4J5PS0doLKlQHW98LywnLCrsW0t9q1LCRhk8LywnLIk7HfUGRbiZtzPYOv8T9UYBy8X8uw6bNsYf1q4EldcUbBq(0b5oxYTEa7lXSAkffZkT7g2hyFv4vDrJjshRRuBoEJmjbRUDoczB5gn6vrXePJ1vQnhVrMKGv3oFwffP0do1gq67RcVQlAu6GGu6zzqWnydYriBl39bEvuSB3uQqoYuBCWgmj3riJyPkbTROrJcYWSsXUDtPc5itTXbBWKCdci9bgyFjMvtPOYEyHl4cnAFjMvtPiy3W0u0O9LywnLIAPmi99vHx1fnkDqqk9Smi4gSb5iKrSuL37AFGxff72nLkKJm1ghSbtYDeYiwQsq7kA0OGmmRuSB3uQqoYuBCWgmj3GacA0a7lXSAkf1SzNoBg3hyFv4vDrJYYbFGffHSTCJg9QOOSCWhyrrk9GtTbK((QWR6IgLoiiLEwgeCd2GCeYiwQY7DTpWRIID7MsfYrMAJd2Gj5oczelvjODfnAuqgMvk2TBkvihzQnoydMKBqazaY8uwQmAfFBVRwge8rwoyxYTEakPSVVk8QUOrPdcsPNLbb3GnihHmILQe0BzZoDGmILQSpWOGmmRuSB3uQqoYuBCWgmj3Or7RcVQlASB3uQqoYuBCWgmj3riJyPkb9w2SthiJyPkbzaY8uwQmAfFBVRwge8rwoyxYTEakPSVVk8QUOrPdcsPNLbb3GnihHmILQ8wFv4vDrJsheKspldcUbBqoUCGgLLE)w2SthiJyPkhGmpLLkJwX327kVHXhZtzPhCkjxudH7LeJmazEklvgTIVT3vEdJpMNYsp4usUOgc3BXyZnVoemvWmjhGmpLLkJwX327kVHXhZtzPhCkjxudH7TmeRHpemvWmjhGmpLLkJwX327kVHXhZtzPhCkjxudH7jjJoemvWmjDj36Tkk2TBkvihzQnoydMK7iLEWP2GgnkidZkf72nLkKJm1ghSbtY9aK5PSuz0k(2ExHyyEl9hO1roq2LCR3QOO4eZhYsLIu6bNAZaK5PSuz0k(2ExHyyEl9hO1roq2LCR3QOOSCWhyrrk9GtTPpkidZkfL1LdTZhjZl5aK5PSuz0k(2ExHyyEl9hO1roq2LCRhkidZkffNy(qwQ0aK5PSuz0k(2ExHyyEl9hO1roq2LCRNSCWh5UbxG(AdqMNYsLrR4B7DLm72l9GZn2fVBpMpKbBys2dvxYTEMNsX8zvuuMD7LEW5gFFV21hYBqwUBaWCFuSkkkZU9sp4CJJu6bNAZaK5PSuz0k(2Ex5nm(yEkl9Gtj5IAiCpFjMvtjxKem9upuDj365lXSAkfv2dlCbxdqMNYsLrR4B7D1cAPEW5g7sU1dGZ2wmvwCsgamFwmsk5OKmpyq3RfUdA0akPSpaNTTyQS4Kmay(SyKuYrNU(BzZoDGmILQ8(wanAaoBBXuzXjzaW8zXiPKJsY8GbDV21c9xffLLd(alksPhCQndqMNYsLrR4B7D1cAPEKLd2LujgcD6OEOoazEklvgTIVT3vYDBvxoakmnanazEklvg9LywnL6LiDSUsT54nYKeS62zxYTEOGmmRuSB3uQqoYuBCWgmj39b2xfEvx0O0bbP0ZYGGBWgKJqgXsvEpQ3bnAFv4vDrJsheKspldcUbBqoczelvjOBH703xfEvx0O0bbP0ZYGGBWgKJqgXsvcAxBH((sxojf9fe60rP2CWmdbzaY8uwQm6lXSAkDBVRsKowxP2C8gzscwD7Sl5wpYWSsXUDtPc5itTXbBWKC3FvuSB3uQqoYuBCWgmj3rk9GtTzaY8uwQm6lXSAkDBVRwSprmk1MdGctUKB98vHx1fnkDqqk9Smi4gSb5iKrSuLGUf6d8Ib4STf3nhLIqgXsvc6RHgnkidZkf3nhLazaY8uwQm6lXSAkDBVRKLd(alYLCRhkidZkf72nLkKJm1ghSbtYDFG9vHx1fnkDqqk9Smi4gSb5iKrSuL33cOr7RcVQlAu6GGu6zzqWnydYriJyPkbDlCh0O9vHx1fnkDqqk9Smi4gSb5iKrSuLG21wOVV0LtsrFbHoDuQnhmZqqgGmpLLkJ(smRMs327kz5GpWICj36rgMvk2TBkvihzQnoydMK7(RIID7MsfYrMAJd2Gj5osPhCQndqMNYsLrFjMvtPB7DL0xoWuBous78a0aK5PSuzCziwdFiyQGzs2ZrYNKyexudH7jlh8jB0Ky4aK5PSuzCziwdFiyQGzsEBVRCK8jjgXf1q4EliBRTeYhXSuY4biZtzPY4YqSg(qWubZK82Ex5i5tsmIlQHW9AWU72p12XKYejXgLLoanazEklvgxgeCd2G8PdYD9eNy(qwQ0aK5PSuzCzqWnydYNoi3DBVRwge8rwo4biZtzPY4YGGBWgKpDqU72Ex1vuw6aK5PSuzCzqWnydYNoi3DBVR2sidax1AaY8uwQmUmi4gSb5thK7UT3vaWvToBoq3dqMNYsLXLbb3GniF6GC3T9UcadLmeCQndqMNYsLXLbb3GniF6GC3T9UYBy8X8uw6bNsYf1q4E(smRMsUKB9qHVeZQPuuzpSWfCnazEklvgxgeCd2G8PdYD327kPdcsPNLbb3GnipanazEklvgxm2CZRdbtfmtYEos(KeJ4IAiCpgPZnKn8PGl1up7sU1dyFjMvtPOMn70zZ4((QWR6IgLLd(alkczelv59UEhqqJgyFjMvtPOywPD3W((QWR6IgtKowxP2C8gzscwD7CeYiwQY7D9oGGgnW(smRMsrL9WcxWfA0(smRMsrWUHPPOr7lXSAkf1szqgGmpLLkJlgBU51HGPcMj5T9UYrYNKyexudH7jDua4QwhdHPD3sYLCRhW(smRMsrnB2PZMX99vHx1fnklh8bwueYiwQY7VoqqJgyFjMvtPOywPD3W((QWR6IgtKowxP2C8gzscwD7CeYiwQY7VoqqJgyFjMvtPOYEyHl4cnAFjMvtPiy3W0u0O9LywnLIAPmidqMNYsLXfJn386qWubZK82Ex5i5tsmIlQHW9KLdgZeLAZb6aWTl5wpG9LywnLIA2StNnJ77RcVQlAuwo4dSOiKrSuL3F9GGgnW(smRMsrXSs7UH99vHx1fnMiDSUsT54nYKeS625iKrSuL3F9GGgnW(smRMsrL9WcxWfA0(smRMsrWUHPPOr7lXSAkf1szqgGgGmpLLkJRIoDqURN1uQBxYTERIIwtPUJqgXsvE)133xfEvx0O0bbP0ZYGGBWgKJqgXsvc6vrrRPu3riJyPkhGmpLLkJRIoDqU72ExjZU9sp4CJDj36TkkkZU9sp4CJJqgXsvE)133xfEvx0O0bbP0ZYGGBWgKJqgXsvc6vrrz2Tx6bNBCeYiwQYbiZtzPY4QOthK7UT3voQKmay(yBB40tzPUKB9wffDujzaW8X22WPNYsJqgXsvE)133xfEvx0O0bbP0ZYGGBWgKJqgXsvc6vrrhvsgamFSTnC6PS0iKrSuLdqMNYsLXvrNoi3DBVR8fe60rzPUKB9wff9fe60rzPriJyPkV)677RcVQlAu6GGu6zzqWnydYriJyPkb9QOOVGqNoklnczelv5a0aK5PSuzmjgPNJKpjXiYbObiZtzPYOK7TBoknazEklvgL8T9UAbTupYYb7sQedHoD0PbxamCpuDjvIHqNo6KB9wmaNTTOC3w1LdJaaAEokjZdg09A3aK5PSuzuY327k5UTQlhafMgGgGmpLLkJsYOdbtfmtYEos(KeJ4IAiCVuLEOdzaW8bu5yk5GCwS40ZdqMNYsLrjz0HGPcMj5T9UYrYNKyexudH7LQKGoEQGYZkfNkFaWy8aK5PSuzusgDiyQGzsEBVRCK8jjgXf1q4ELygUHRlP2CmnrSJ3A4biZtzPYOKm6qWubZK82Ex5i5tsmIlQHW9wgemsv6zXEWNohcYspREEaY8uwQmkjJoemvWmjVT3vos(KeJ4IAiCpeZBaG8rUZmDqCKPFaY8uwQmkjJoemvWmjVT3vos(KeJ4IAiCVnSHWNA7aWicZdqMNYsLrjz0HGPcMj5T9UYrYNKyexudH7DXaZkdLNnyPRbiZtzPYOKm6qWubZK82Ex5i5tsmIlQHW9idaMPtTDwSSZs4aK5PSuzusgDiyQGzsEBVRCK8jjgXf1q4EYu3CWht2Lqtj5bGTA4tTD2yy5tY9aK5PSuzusgDiyQGzsEBVRCK8jjgXf1q4EYu3CWNgSTsJkO8aWwn8P2oBmS8j5EaY8uwQmkjJoemvWmjVT3vaWvToBoq3dqMNYsLrjz0HGPcMj5T9UAlHmaCvRbiZtzPYOKm6qWubZK82ExbGHsgco1MbObirC(7gp)QurP5LoDDfKMFU7oVjNVLG6I85tDEuYXCzEznVituX88(sfZqIxZt7PCEQM3GjTJWu6JdqMNYsLrcMkyMoYoCsh)o7b3tSbtdaMDrneUNSJ9PHpmOYj764LlInSd3dyGrTfLbvozxhVImsNBiB4tbxQPEgKBbg1wugu5KDD8kMQ0dDidaMpGkhtjhKZIfNEgKBbg1wugu5KDD8kklhmMjk1Md0bGBqUfyuBrzqLt21XRO0rbGRADmeM2DljqaPhQdqMNYsLrcMkyMoYoCsh)o7bFBVReBW0aGzxudH7rWubZ0Pu2fXg2H7bmbtfmtruJ7M80blFFcMkyMIOg3n5XxfEvxuqgGmpLLkJemvWmDKD4Ko(D2d(2Exj2GPbaZUOgc3JGPcMPdDPCrSHD4EatWubZu014UjpDWY3NGPcMPORXDtE8vHx1ffKbiZtzPYibtfmthzhoPJFN9GVT3vInyAaWSlQHW9wgI1WhcMkyMCrSHD4EaJcGjyQGzkIAC3KNoy57tWubZue14Ujp(QWR6IcciOrdmkaMGPcMPORXDtE6GLVpbtfmtrxJ7M84RcVQlkiGGgndQCYUoEfBWU72p12XKYejXgLLoazEklvgjyQGz6i7WjD87Sh8T9UsSbtdaMDrneUhbtfmthzhojxeByhUhWInyAaWCKGPcMPtPCFXgmnayoUmeRHpemvWmbcA0al2GPbaZrcMkyMo0LQVydMgamhxgI1WhcMkyMabnAGfBW0aG5ibtfmtNs55URydMgamhLDSpn8HbvozxhVabnAGfBW0aG5ibtfmth6sn3DfBW0aG5OSJ9PHpmOYj764fibbXmuMLgA1174kQ356CfuliCXGAQnYGWDteiYBvK1A7xrA(5BBNNpr6kin)wbNxucMkyMoYoCsh)o7bl68qgu5KqEnVSq45nhQqmIxZ73nTHLXbiukvEExfP5bLsfZqIxZlkbtfmtruJTu05PAErjyQGzksOgBPOZdSROmiXbiukvE(2jsZdkLkMHeVMxucMkyMIUgBPOZt18IsWubZuKCn2srNhyxrzqIdqOuQ88xtKMhukvmdjEnVOemvWmfrn2srNNQ5fLGPcMPiHASLIopWUIYGehGqPu55VMinpOuQygs8AErjyQGzk6ASLIopvZlkbtfmtrY1ylfDEGDfLbjoanaD3ebI8wfzT2(vKMF(2255tKUcsZVvW5f1xIz1us05HmOYjH8AEzHWZBouHyeVM3VBAdlJdqOuQ88OksZdkLkMHeVMxuYWSsXwk68unVOKHzLITmYQbaZlrNhyurzqIdqOuQ88OksZdkLkMHeVMxuFPlNKITu05PAEr9LUCsk2YiRgamVeDEGrfLbjoaHsPYZ7QinpOuQygs8AErjdZkfBPOZt18IsgMvk2YiRgamVeDEGrfLbjoaHsPYZ3orAEqPuXmK418IsgMvk2srNNQ5fLmmRuSLrwnayEj68aJkkdsCacLsLN)AI08GsPIziXR5fLmmRuSLIopvZlkzywPylJSAaW8s05bgvugK4aekLkp)1eP5bLsfZqIxZlQV0LtsXwk68unVO(sxojfBzKvdaMxIopWOIYGehGqPu55BbrAEqPuXmK418IsgMvk2srNNQ5fLmmRuSLrwnayEj68aJkkdsCaAa6Ujce5TkYAT9Rin)8TTZZNiDfKMFRGZl6I3mhmj68qgu5KqEnVSq45nhQqmIxZ73nTHLXbiukvE(RtKMhukvmdjEnVOKHzLITu05PAErjdZkfBzKvdaMxIoVrZ3IaQJsZdmQOmiXbiukvEEqnrAEqPuXmK418IsWubZue1ylfDEQMxucMkyMIeQXwk68aFnugK4aekLkppOMinpOuQygs8AErjyQGzk6ASLIopvZlkbtfmtrY1ylfDEGVgkdsCacLsLNVfxKMhukvmdjEnVOKHzLITu05PAErjdZkfBzKvdaMxIopWUIYGehGqPu55r9oI08GsPIziXR5fLmmRuSLIopvZlkzywPylJSAaW8s05bgvugK4aekLkppQUksZdkLkMHeVMxuYWSsXwk68unVOKHzLITmYQbaZlrNhyurzqIdqOuQ88O2orAEqPuXmK418IsWubZu0a4J(QWR6Ik68unVO(QWR6IgnaErNhyurzqIdqOuQ88OEnrAEqPuXmK418IsWubZu0a4J(QWR6Ik68unVO(QWR6IgnaErNhyurzqIdqOuQ88O2cI08GsPIziXR5fLGPcMPObWh9vHx1fv05PAEr9vHx1fnAa8IopWOIYGehGqPu55D9oI08GsPIziXR5fLmmRuSLIopvZlkzywPylJSAaW8s05bgvugK4aekLkpVROksZdkLkMHeVMxuYWSsXwk68unVOKHzLITmYQbaZlrNhyurzqIdqOuQ88UEDI08GsPIziXR5fLmmRuSLIopvZlkzywPylJSAaW8s05b2vugK4aekLkpVRxVinpOuQygs8AErjdZkfBPOZt18IsgMvk2YiRgamVeDEGDfLbjoaHsPYZ7AlUinpOuQygs8AErjdZkfBPOZt18IsgMvk2YiRgamVeDEGrfLbjoaHsPYZ3U7isZdkLkMHeVMxuYWSsXwk68unVOKHzLITmYQbaZlrNhyurzqIdqOuQ88TRDI08GsPIziXR5ff6O8wbB4ylfDEQMxuOJYBfSHJTmYQbaZlrNhyurzqIdqOuQ88T7AI08GsPIziXR5ff6O8wbB4ylfDEQMxuOJYBfSHJTmYQbaZlrNhyurzqIdqOuQ88TRfeP5bLsfZqIxZlkzywPylfDEQMxuYWSsXwgz1aG5LOZdmQOmiXbiukvE(21cI08GsPIziXR5ff6O8wbB4ylfDEQMxuOJYBfSHJTmYQbaZlrNhyurzqIdqOuQ88T76eP5bLsfZqIxZlkzywPylfDEQMxuYWSsXwgz1aG5LOZB08TiG6O08aJkkdsCacLsLN)AUksZdkLkMHeVMxuYWSsXwk68unVOKHzLITmYQbaZlrNhyxrzqIdqdq3nrGiVvrwRTFfP5NVTDE(ePRG08BfCErTIfDEidQCsiVMxwi88MdvigXR597M2WY4aekLkpF7eP5bLsfZqIxZlkzywPylfDEQMxuYWSsXwgz1aG5LOZdSROmiXbiukvE(RjsZdkLkMHeVMxuYWSsXwk68unVOKHzLITmYQbaZlrNhyurzqIdqOuQ88TGinpOuQygs8AErjdZkfBPOZt18IsgMvk2YiRgamVeDEGrfLbjoaHsPYZJQRI08GsPIziXR5fLmmRuSLIopvZlkzywPylJSAaW8s05bUDOmiXbiukvEEuBNinpOuQygs8AErjdZkfBPOZt18IsgMvk2YiRgamVeDEGrfLbjoaHsPYZJ61lsZdkLkMHeVMxuYWSsXwk68unVOKHzLITmYQbaZlrN3O5Bra1rP5bgvugK4aekLkpVR3rKMhukvmdjEnVOKHzLITu05PAErjdZkfBzKvdaMxIoVrZ3IaQJsZdmQOmiXbiukvEExrvKMhukvmdjEnVOKHzLITu05PAErjdZkfBzKvdaMxIoVrZ3IaQJsZdmQOmiXbObirgsxbjEnpQUoV5PS05XPKKXbOGaoLKm0wqyzqWnydYNoi3fAl0kQH2ccMNYsdcItmFilvkiWQbaZRWnbk0QRH2ccMNYsdcldc(ilhCqGvdaMxHBcuO12fAliyEklni0vuwAqGvdaMxHBcuO1RfAliyEklniSLqgaUQvqGvdaMxHBcuO1wi0wqW8uwAqaaUQ1zZb6oiWQbaZRWnbk061fAliyEklniaGHsgco1MGaRgamVc3eOqRGAH2ccSAaW8kCtqWdtIHPfeqX8(smRMsrL9WcxWvqW8uwAqWBy8X8uw6bNskiGtjDudHdc(smRMsbk061hAliyEklniiDqqk9Smi4gSb5GaRgamVc3eOafeiyQGz6i7WjD87ShCOTqROgAliWQbaZRWnbHQliizkiyEklnii2GPbaZbbXg2HdcappWZJ68TOZZGkNSRJxrgPZnKn8PGl1upppiZF78appQZ3IopdQCYUoEftv6HoKbaZhqLJPKdYzXItpppiZF78appQZ3IopdQCYUoEfLLdgZeLAZb6aW98Gm)TZd88OoFl68mOYj764vu6OaWvTogct7UL08GmpiZ3BEudclw6HzhLLgeUB88RsfLMx601vqA(GGydEudHdcYo2Ng(WGkNSRJxbk0QRH2ccSAaW8kCtqO6ccsMccMNYsdcInyAaWCqqSHD4GaWZtWubZuKqnUBYthS8Z3FEcMkyMIeQXDtE8vHx1fDEqccIn4rneoiqWubZ0PuoqHwBxOTGaRgamVc3eeQUGGKPGG5PS0GGydMgamheeByhoia88emvWmfjxJ7M80bl)89NNGPcMPi5AC3KhFv4vDrNhKGGydEudHdcemvWmDOlvGcTETqBbbwnayEfUjiuDbbjtbbZtzPbbXgmnayoii2WoCqa45rX8appbtfmtrc14UjpDWYpF)5jyQGzksOg3n5XxfEvx05bzEqMhn65bEEumpWZtWubZuKCnUBYthS8Z3FEcMkyMIKRXDtE8vHx1fDEqMhK5rJEEgu5KDD8k2GD3TFQTJjLjsInklnii2Gh1q4GWYqSg(qWubZuGcT2cH2ccSAaW8kCtqO6ccsMccMNYsdcInyAaWCqqSHD4GaWZl2GPbaZrcMkyMoLYZ3FEXgmnayoUmeRHpemvWmnpiZJg98apVydMgamhjyQGz6qxQ57pVydMgamhxgI1WhcMkyMMhK5rJEEGNxSbtdaMJemvWmDkLdcIn4rneoiqWubZ0r2HtkqbkiSmeRHpemvWmjdTfAf1qBbbwnayEfUjiOgcheKLd(KnAsmmiyEklniilh8jB0KyyGcT6AOTGaRgamVc3eeudHdcliBRTeYhXSuY4GG5PS0GWcY2AlH8rmlLmoqHwBxOTGaRgamVc3eeudHdcny3D7NA7yszIKyJYsdcMNYsdcny3D7NA7yszIKyJYsduGcclgBU51HGPcMjzOTqROgAliWQbaZRWnbbZtzPbbgPZnKn8PGl1uphe8WKyyAbbGN3xIz1ukQzZoD2mE((Z7RcVQlAuwo4dSOiKrSuLZF)8UEN5bzE0ONh459LywnLIIzL2DdNV)8(QWR6IgtKowxP2C8gzscwD7CeYiwQY5VFExVZ8GmpA0Zd88(smRMsrL9WcxW18OrpVVeZQPueSByA68OrpVVeZQPuulLNhKGGAiCqGr6CdzdFk4sn1Zbk0QRH2ccSAaW8kCtqW8uwAqq6OaWvTogct7ULuqWdtIHPfeaEEFjMvtPOMn70zZ457pVVk8QUOrz5GpWIIqgXsvo)9ZFDZdY8OrppWZ7lXSAkffZkT7goF)59vHx1fnMiDSUsT54nYKeS625iKrSuLZF)8x38GmpA0Zd88(smRMsrL9WcxW18OrpVVeZQPueSByA68OrpVVeZQPuulLNhKGGAiCqq6OaWvTogct7ULuGcT2UqBbbwnayEfUjiyEklniilhmMjk1Md0bG7GGhMedtlia88(smRMsrnB2PZMXZ3FEFv4vDrJYYbFGffHmILQC(7N)6NhK5rJEEGN3xIz1ukkMvA3nC((Z7RcVQlAmr6yDLAZXBKjjy1TZriJyPkN)(5V(5bzE0ONh459LywnLIk7HfUGR5rJEEFjMvtPiy3W005rJEEFjMvtPOwkppibb1q4GGSCWyMOuBoqhaUduGcc(smRMsH2cTIAOTGaRgamVc3ee8WKyyAbbumpzywPy3UPuHCKP24GnysUJSAaW8A((Zd88(QWR6IgLoiiLEwgeCd2GCeYiwQY5VFEuVZ8OrpVVk8QUOrPdcsPNLbb3GnihHmILQCEqpFlCN57pVVk8QUOrPdcsPNLbb3GnihHmILQCEqpVRTW89N3x6YjPOVGqNok1MdMzyKvdaMxZdsqW8uwAqir6yDLAZXBKjjy1TZbk0QRH2ccSAaW8kCtqWdtIHPfeidZkf72nLkKJm1ghSbtYDKvdaMxZ3F(vrXUDtPc5itTXbBWKChP0do1MGG5PS0GqI0X6k1MJ3itsWQBNduO12fAliWQbaZRWnbbpmjgMwqWxfEvx0O0bbP0ZYGGBWgKJqgXsvopONVfMV)8ap)Ib4STf3nhLIqgXsvopON)AZJg98OyEYWSsXDZrPiRgamVMhKGG5PS0GWI9jIrP2CauykqHwVwOTGaRgamVc3ee8WKyyAbbumpzywPy3UPuHCKP24GnysUJSAaW8A((Zd88(QWR6IgLoiiLEwgeCd2GCeYiwQY5VF(wyE0ON3xfEvx0O0bbP0ZYGGBWgKJqgXsvopONVfUZ8OrpVVk8QUOrPdcsPNLbb3GnihHmILQCEqpVRTW89N3x6YjPOVGqNok1MdMzyKvdaMxZdsqW8uwAqqwo4dSOafATfcTfey1aG5v4MGGhMedtliqgMvk2TBkvihzQnoydMK7iRgamVMV)8RIID7MsfYrMAJd2Gj5osPhCQnbbZtzPbbz5GpWIcuO1Rl0wqW8uwAqq6lhyQnhkPDoiWQbaZRWnbkqbHvrNoi3fAl0kQH2ccSAaW8kCtqWdtIHPfewffTMsDhHmILQC(7N)6NV)8(QWR6IgLoiiLEwgeCd2GCeYiwQY5b98RIIwtPUJqgXsvgempLLgeSMsDhOqRUgAliWQbaZRWnbbpmjgMwqyvuuMD7LEW5ghHmILQC(7N)6NV)8(QWR6IgLoiiLEwgeCd2GCeYiwQY5b98RIIYSBV0do34iKrSuLbbZtzPbbz2Tx6bNBCGcT2UqBbbwnayEfUji4HjXW0ccRIIoQKmay(yBB40tzPriJyPkN)(5V(57pVVk8QUOrPdcsPNLbb3GnihHmILQCEqp)QOOJkjdaMp22go9uwAeYiwQYGG5PS0GGJkjdaMp22go9uwAGcTETqBbbwnayEfUji4HjXW0ccRII(ccD6OS0iKrSuLZF)8x)89N3xfEvx0O0bbP0ZYGGBWgKJqgXsvopONFvu0xqOthLLgHmILQmiyEklni4li0PJYsduGcclEZCWuOTqROgAliyEklnii7ym(Glp4GaRgamVc3eOqRUgAliyEklniSyXLd8GynPpiWQbaZRWnbk0A7cTfey1aG5v4MGGhMedtliyEkfZhwzKKLZd65BxqqsW0tHwrniyEklni4nm(yEkl9GtjfeWPKoQHWbbR4afA9AH2ccSAaW8kCtqyXspm7OS0GGiWtzPZJtjjNFRGZtWubZ08a4DtCwW48cKrY5nipV0eZR53k48a4TcYZluo45f5fDLidPJ1vQnZdkgzscwD78vIWDtPczEHuBCWgmj3UmFr7m8sk55lDEFv4vDrdcMNYsdcEdJpMNYsp4usbbCkPJAiCqGGPcMPJSdN0XVZEWbk0AleAliWQbaZRWnbbZtzPbbVHXhZtzPhCkPGaoL0rneoiSyS5MxhcMkyMKbk061fAliWQbaZRWnbbpmjgMwqa45xffLLd(alksPhCQnZJg98RIIjshRRuBoEJmjbRUD(SkksPhCQnZJg98RIID7MsfYrMAJd2Gj5osPhCQnZdY89Nxwo4JC3GR5b98TBE0ONFvuuCI5dzPsrk9GtTzE0ONNmmRuuwxo0oFKmVKrwnayEfeKem9uOvudcMNYsdcEdJpMNYsp4usbbCkPJAiCqqsgDiyQGzsgOqRGAH2ccSAaW8kCtqWdtIHPfe8LywnLIA2StNnJNV)8appkMxSbtdaMJemvWmDKD4KMhn659vHx1fnklh8bwueYiwQY5b98UEN5rJEEGNxSbtdaMJemvWmDkLNV)8(QWR6IgLLd(alkczelv583ppbtfmtrc1OVk8QUOriJyPkNhK5rJEEGNxSbtdaMJemvWmDOl189N3xfEvx0OSCWhyrriJyPkN)(5jyQGzksUg9vHx1fnczelv58GmpiZJg98(smRMsrXSs7UHZ3FEGNhfZl2GPbaZrcMkyMoYoCsZJg98(QWR6IgtKowxP2C8gzscwD7CeYiwQY5b98UEN5rJEEGNxSbtdaMJemvWmDkLNV)8(QWR6IgtKowxP2C8gzscwD7CeYiwQY5VFEcMkyMIeQrFv4vDrJqgXsvopiZJg98apVydMgamhjyQGz6qxQ57pVVk8QUOXePJ1vQnhVrMKGv3ohHmILQC(7NNGPcMPi5A0xfEvx0iKrSuLZdY8GmpA0Zd88(smRMsrL9WcxW18OrpVVeZQPueSByA68OrpVVeZQPuulLNhK57ppWZJI5fBW0aG5ibtfmthzhoP5rJEEFv4vDrJD7MsfYrMAJd2Gj5oczelv58GEExVZ8OrppWZl2GPbaZrcMkyMoLYZ3FEFv4vDrJD7MsfYrMAJd2Gj5oczelv583ppbtfmtrc1OVk8QUOriJyPkNhK5rJEEGNxSbtdaMJemvWmDOl189N3xfEvx0y3UPuHCKP24GnysUJqgXsvo)9ZtWubZuKCn6RcVQlAeYiwQY5bzEqMhn65rX8KHzLID7MsfYrMAJd2Gj5oYQbaZR57ppWZJI5fBW0aG5ibtfmthzhoP5rJEEFv4vDrJsheKspldcUbBqoczelv58GEExVZ8OrppWZl2GPbaZrcMkyMoLYZ3FEFv4vDrJsheKspldcUbBqoczelv583ppbtfmtrc1OVk8QUOriJyPkNhK5rJEEGNxSbtdaMJemvWmDOl189N3xfEvx0O0bbP0ZYGGBWgKJqgXsvo)9ZtWubZuKCn6RcVQlAeYiwQY5bzEqccMNYsdcEdJpMNYsp4usbbCkPJAiCqyziwdFiyQGzsgOqRxFOTGaRgamVc3eempLLgeqmmVL(d06ihihewS0dZoklniCJduNxwo45L7gCjNp3MFlB2P5t58ggPK08Lygge8WKyyAbbaLuoF)53YMD6azelv583ppJYS3H4dLi88TOZllh8rUBW189NFvu0rLKbaZhBBdNEklnsPhCQnbk0AlEOTGaRgamVc3eewS0dZoklniiY2M3xIz1uA(vrxjc3nLkK5fsTXbBWKCpFkNh6OAQnUmVJKN)Umi4gSb55PAEgLjwxZt788EhiKvAEjtbbZtzPbbVHXhZtzPhCkPGGhMedtlia88(smRMsrXSs7UHZ3F(vrXePJ1vQnhVrMKGv3oFwffP0do1M57pVVk8QUOrPdcsPNLbb3GnihHmILQC(7N3157ppWZVkk2TBkvihzQnoydMK7iKrSuLZd65DDE0ONhfZtgMvk2TBkvihzQnoydMK7iRgamVMhK5bzE0ONh459LywnLIA2StNnJNV)8RIIYYbFGffP0do1M57pVVk8QUOrPdcsPNLbb3GnihHmILQC(7N3157ppWZVkk2TBkvihzQnoydMK7iKrSuLZd65DDE0ONhfZtgMvk2TBkvihzQnoydMK7iRgamVMhK5bzE0ONh45bEEFjMvtPOYEyHl4AE0ON3xIz1ukc2nmnDE0ON3xIz1ukQLYZdY89NFvuSB3uQqoYuBCWgmj3rk9GtTz((ZVkk2TBkvihzQnoydMK7iKrSuLZF)8UopibbCkPJAiCqyzqWnydYNoi3fOqROENqBbbwnayEfUjiSyPhMDuwAqqKZBqwUp)Qi58SbXUNp3MVPsTz(uPAEBE5UbxZl7yDLAZ8D7MKdcMNYsdcEdJpMNYsp4usbbpmjgMwqa459LywnLIA2StNnJNV)8Oy(vrrz5GpWIIu6bNAZ89N3xfEvx0OSCWhyrriJyPkN)(5V28GmpA0Zd88(smRMsrXSs7UHZ3FEum)QOyI0X6k1MJ3itsWQBNpRIIu6bNAZ89N3xfEvx0yI0X6k1MJ3itsWQBNJqgXsvo)9ZFT5bzE0ONh45bEEFjMvtPOYEyHl4AE0ON3xIz1ukc2nmnDE0ON3xIz1ukQLYZdY89NNmmRuSB3uQqoYuBCWgmj3rwnayEnF)5rX8RIID7MsfYrMAJd2Gj5osPhCQnZ3FEFv4vDrJD7MsfYrMAJd2Gj5oczelv583p)1MhKGaoL0rneoiSk60b5UafAfvudTfey1aG5v4MGG5PS0GWYGGpYYbhewS0dZoklniiY2MxeUBkviZlKAJd2Gj5E(uopLEWP24Y8jnFkNxAB88unVJKN)Umi45fkhCqWdtIHPfewff72nLkKJm1ghSbtYDKsp4uBcuOvuDn0wqGvdaMxHBccEysmmTGakMNmmRuSB3uQqoYuBCWgmj3rwnayEnF)5bE(vrrz5GpWIIu6bNAZ8Orp)QOyI0X6k1MJ3itsWQBNpRIIu6bNAZ8GeempLLgewge8rwo4afAf12fAliWQbaZRWnbbZtzPbHUDtPc5itTXbBWKChewS0dZoklnii4w9Zlc3nLkK5fsTXbBWKCp)LK2NV9dR0UB4vTMn7083DmEEFjMvtP5xf5Y8fTZWlPKN3rYZx68(QWR6IgNxKTnFlcsNBiB45b1Hl1upppaNTT5t58P6lKuBCz(9cVM3rPepFsIkNhY2Y98aJ61pVK9LUKZBBedN3rYGee8WKyyAbbFjMvtPOMn70zZ457ppLi88GE(wy((Z7RcVQlAuwo4dSOiKrSuLZF)8OoF)5bEEFv4vDrJmsNBiB4tbxQPEoczelv583ppQxNRZJg98OyEgu5KDD8kYiDUHSHpfCPM655bjqHwr9AH2ccSAaW8kCtqWdtIHPfe8LywnLIIzL2DdNV)8uIWZd65BH57pVVk8QUOXePJ1vQnhVrMKGv3ohHmILQC(7Nh157ppWZ7RcVQlAKr6CdzdFk4sn1ZriJyPkN)(5r96CDE0ONhfZZGkNSRJxrgPZnKn8PGl1upppibbZtzPbHUDtPc5itTXbBWKChOqRO2cH2ccSAaW8kCtqWdtIHPfeaEEFjMvtPOYEyHl4AE0ON3xIz1ukc2nmnDE0ON3xIz1ukQLYZdY89Nh459vHx1fnYiDUHSHpfCPM65iKrSuLZF)8OEDUopA0ZJI5zqLt21XRiJ05gYg(uWLAQNNhKGG5PS0Gq3UPuHCKP24GnysUduOvuVUqBbbwnayEfUji4HjXW0ccakPC((ZVLn70bYiwQY5VFEuVUGG5PS0Gq3UPuHCKP24GnysUduOvub1cTfey1aG5v4MGWILEy2rzPbbr228IWDtPczEHuBCWgmj3ZNY5P0do1gxMpjrLZtjcppvZ7i55lANHZJy39fC(vrYGG5PS0GG3W4J5PS0doLuqWdtIHPfewff72nLkKJm1ghSbtYDKsp4uBMV)8apVVeZQPuuZMD6Sz88OrpVVeZQPuumR0UB48GeeWPKoQHWbbFjMvtPafAf1Rp0wqGvdaMxHBccMNYsdcwtPUdcEysmmTGWQOO1uQ7iKrSuLZF)8xli4D7X8HmydtYqROgOqRO2IhAliyEklniSBokfey1aG5v4MafA117eAliWQbaZRWnbbZtzPbbjZRtTD8fe60rzPbHfl9WSJYsdcc1L5PDEEbMxY5lD(2npzWgMKZNBZN08PufLM37aHSsy3ZN68B4SzNMVGZx680oppzWgMIZF3sAFEHSBV05rPCJNpjrLZByznpaMigopvZ7i55fyEnFjMHZJyQJHXUN366WUtTz(2npOuqOthLLkJbbpmjgMwqW8ukMpSYijlNh0Z7689NNmmRuuwxo0oFKmVKrwnayEnF)5rX8RIIsMxNA74li0PJYsJu6bNAZ89NhfZN6zdNn7uGcT6kQH2ccSAaW8kCtqWdtIHPfempLI5dRmsYY5b98UoF)5jdZkfLz3EPhCUXrwnayEnF)5rX8RIIsMxNA74li0PJYsJu6bNAZ89NhfZN6zdNn7089NFvu0xqOthLLgHmILQC(7N)AbbZtzPbbjZRtTD8fe60rzPbk0QRUgAliWQbaZRWnbbpmjgMwqa45LLd(i3n4AEqppQZJg98MNsX8Hvgjz58GEExNhK57pVVk8QUOrPdcsPNLbb3GnihHmILQCEqppQUgempLLgeeNy(qwQuGcT6A7cTfey1aG5v4MGGhMedtliyEkfZNvrrhvsgamFSTnC6PS057n)DMhn65P0do1M57p)QOOJkjdaMp22go9uwAeYiwQY5VF(RfempLLgeCujzaW8X22WPNYsduOvxVwOTGaRgamVc3eempLLgeKz3EPhCUXbbpmjgMwqyvuuMD7LEW5ghHmILQC(7N)AbbVBpMpKbBysgAf1afA11wi0wqGvdaMxHBccEysmmTGakM3xIz1ukQShw4cUccscMEk0kQbbZtzPbbVHXhZtzPhCkPGaoL0rneoi4lXSAkfOqRUEDH2ccSAaW8kCtqW8uwAqWxqOthLLge8U9y(qgSHjzOvudcEysmmTGG5PumFyLrswo)9ZFT5BV5bEEYWSsrzD5q78rY8sgz1aG518OrppzywPOm72l9GZnoYQbaZR5bz((ZVkk6li0PJYsJqgXsvo)9Z7AqyXspm7OS0GGiORd7EEqPGqNoklDEetDmm298LopQTNRZtgSHjPlZxW5lD(2n)LK2NxeaqwyhINhuki0PJYsduOvxb1cTfey1aG5v4MGG5PS0GaIH5T0FGwh5a5GWILEy2rzPbbrWgXW5PDE(QJvg6Y8YowxZBZl3n4A(l7SoVrZ3cZx68TpdZBPFErU1roqEEQM3ex5A(smd9wxxQnbbpmjgMwqqwo4JC3GR5b98xB((ZtjcppON3vuduOvxV(qBbbwnayEfUjiSyPhMDuwAq4UTZ68ArZlDR(uBMxeUBkviZlKAJd2Gj5EEQMV9dR0UB4vTMn7083Dm2L5fCqqkD(7YGGBWgKNp3M3W45xfjN3G88wxho5vqW8uwAqWBy8X8uw6bNski4HjXW0ccapVVeZQPuumR0UB489NhfZtgMvk2TBkvihzQnoydMK7iRgamVMV)8RIIjshRRuBoEJmjbRUD(SkksPhCQnZ3FEFv4vDrJsheKspldcUbBqoczB5EEqMhn65bEEFjMvtPOMn70zZ457ppkMNmmRuSB3uQqoYuBCWgmj3rwnayEnF)5xffLLd(alksPhCQnZ3FEFv4vDrJsheKspldcUbBqoczB5EEqMhn65bEEGN3xIz1ukQShw4cUMhn659LywnLIGDdttNhn659LywnLIAP88GmF)59vHx1fnkDqqk9Smi4gSb5iKTL75bjiGtjDudHdcldcUbBq(0b5UafA11w8qBbbwnayEfUjiyEklniSmi4JSCWbHfl9WSJYsdcT)sE(7YGGNxOCWZNBZFxgeCd2G88xkvuAEa88q2wUN3ASuDz(coFUnpTZqE(ljgppaEEJMhZMKM315rkip)DzqWnydYZ7izzqWdtIHPfeaus589N3xfEvx0O0bbP0ZYGGBWgKJqgXsvopONFlB2PdKrSuLZ3FEGNhfZtgMvk2TBkvihzQnoydMK7iRgamVMhn659vHx1fn2TBkvihzQnoydMK7iKrSuLZd653YMD6azelv58GeOqRT7oH2ccSAaW8kCtqWdtIHPfeaus589NhfZtgMvk2TBkvihzQnoydMK7iRgamVMV)8(QWR6IgLoiiLEwgeCd2GCeYiwQY5VDEFv4vDrJsheKspldcUbBqoUCGgLLo)9ZVLn70bYiwQYGG5PS0GWYGGpYYbhOqRTd1qBbbwnayEfUjiSyPhMDuwAqaumYV3EggpFsmY8osRHNFRGZBQBAp1M51IMx2X(Cl518mwYx2zihempLLge8ggFmpLLEWPKcc4ush1q4GqsmsGcT2oxdTfey1aG5v4MGGhMedtliqgMvkk3TvD5WiaGMNJSAaW8A((Zd88lgGZ2wuUBR6YHraanphLK5bp)9Zd88UoF7nV5PS0OC3w1LdGctXupB4SzNMhK5rJE(fdWzBlk3TvD5WiaGMNJqgXsvo)9Z3U5bjiyEklni4nm(yEkl9GtjfeWPKoQHWbbjhOqRTRDH2ccSAaW8kCtqW8uwAqaXW8w6pqRJCGCqyXspm7OS0Gq7VKNV9zyEl9ZlYToYbYZFzN15rS7(co)Qi58gKN3PZL5l485280od55VKy88a45LzJMBP3uAEkr45DukXZt788kJY08IWDtPczEHuBCWgmj3X5fzBZ7qjoBXKAZ8TpdZBPF(7g0ODxMFVWR5T5L7gCnpvZd5nil3NN255b4STfe8WKyyAbbGNFvuuCI5dzPsrk9GtTzE0ONFvumr6yDLAZXBKjjy1TZNvrrk9GtTzE0ONFvuuwo4dSOiLEWP2mpiZ3FEGNhfZdDuERGnCeXW8w6pxGgThz1aG518OrppaNTTiIH5T0FUanApkjZdE(7NVDZJg98YYbFK7gCnpONh15bjqHwB31cTfey1aG5v4MGG5PS0GaIH5T0FGwh5a5GWILEy2rzPbH2FjpF7ZW8w6NxKBDKdKNNQ5rSujl15PDEEedZBPF(lqJ2NhGZ228okL45L7gCjNxzEnpvZdGNVHvgAeVMFRGZt788kJY08aCGsA(lPUQlZdSR3zEj7lDjNpLZJuqEEA305LoBBPpzLMNQ5ByLHgXZ3U5L7gCjbji4HjXW0ccqhL3kydhrmmVL(ZfOr7rwnayEnF)59vHx1fnklh8bwueYiwQY5b98UEN57ppaNTTiIH5T0FUanApczelv583p)1cuO121cH2ccSAaW8kCtqW8uwAqaXW8w6pqRJCGCqyXspm7OS0Gq7VKNV9zyEl9ZlYToYbYZx68IWDtPczEHuBCWgmj3Z7njjDzEedCQnZlDG88unV0eZZBZl3n4AEQMxsMh88TpdZBPF(7g0O95ZT5DKP2mFsbbpmjgMwqGmmRuSB3uQqoYuBCWgmj3rwnayEnF)5bE(vrXUDtPc5itTXbBWKChP0do1M5rJEEFv4vDrJD7MsfYrMAJd2Gj5oczelv58GEExBH5rJEEaLuoF)5PeHpuDwjp)9Z7RcVQlASB3uQqoYuBCWgmj3riJyPkNhK57ppWZJI5HokVvWgoIyyEl9NlqJ2JSAaW8AE0ONhGZ2weXW8w6pxGgThLK5bp)9Z3U5rJEEz5GpYDdUMh0ZJ68GeOqRT76cTfey1aG5v4MGGhMedtliqgMvkkRlhANpsMxYiRgamVccMNYsdcigM3s)bADKdKduO12bQfAliWQbaZRWnbbZtzPbHf0s9GZnoiSyPhMDuwAq4UGwQZJs5gpFkNVuS75T5VlrOW8nwQZFjP95fzklojdaMN)UyKuYZRSbNhXq55LK5blJZlY2MFlB2P5t58gGYHMNQ5zDn)QMxlAEKukNx2X6k1M5PDEEjzEWYGGhMedtliaWzBlMklojdaMplgjLCusMh88GE(RDN5rJEEaoBBXuzXjzaW8zXiPKJoDZ3FEaLuoF)53YMD6azelv583p)1cuO12D9H2ccSAaW8kCtqW8uwAqWBy8X8uw6bNskiGtjDudHdc(smRMsbk0A7AXdTfey1aG5v4MGG5PS0GG1uQ7GGhMedtlia5nil3nayoi4D7X8HmydtYqROgOqRx7oH2ccSAaW8kCtqWdtIHPfempLI5ZQOOJkjdaMp22go9uw689M)oZJg98u6bNAZ89NhYBqwUBaWCqW8uwAqWrLKbaZhBBdNEklnqHwVgQH2ccSAaW8kCtqW8uwAqqMD7LEW5ghe8WKyyAbbiVbz5UbaZbbVBpMpKbBysgAf1afA9AUgAliWQbaZRWnbbZtzPbbFbHoDuwAqWdtIHPfeG8gKL7gampF)5npLI5dRmsYY5VF(RnF7npWZtgMvkkRlhANpsMxYiRgamVMhn65jdZkfLz3EPhCUXrwnayEnpibbVBpMpKbBysgAf1afA9ATl0wqivIHqNokiGAqW8uwAqybTupYYbhey1aG5v4MafA9Axl0wqW8uwAqqUBR6YbqHPGaRgamVc3eOafe6GSVqayuOTqROgAliWQbaZRWnbbpmjgMwqGseEEqp)DMV)8Oy(oMIgofZZ3FEumpaNTTydmrQeYNA7inpm3sphD6ccMNYsdcBm(SkKunklnqHwDn0wqW8uwAqq6GGu6zJX7okXWGaRgamVc3eOqRTl0wqGvdaMxHBccEysmmTGazywPydmrQeYNA7inpm3sphz1aG5vqW8uwAqObMivc5tTDKMhMBPNduO1RfAliWQbaZRWnbHQliizkiyEklnii2GPbaZbbXg2HdcMNsX8zvu0xqOthLLopON)oZ3FEZtPy(SkkAnL6EEqp)DMV)8MNsX8zvu0rLKbaZhBBdNEklDEqp)DMV)8appkMNmmRuuMD7LEW5ghz1aG518OrpV5PumFwffLz3EPhCUXZd65VZ8GmF)5bE(vrXUDtPc5itTXbBWKChP0do1M5rJEEumpzywPy3UPuHCKP24GnysUJSAaW8AEqccIn4rneoiSksEGSTChOqRTqOTGaRgamVc3eeudHdcwlg5Ubn5zRu6uBNU6cddcMNYsdcwlg5Ubn5zRu6uBNU6cdduO1Rl0wqGvdaMxHBccMNYsdcsMxNA74li0PJYsdcEysmmTGGSJX4dzWgMKrjZRtTD8fe60rzPhR45bDV5BxqaNkF8RGaQ3jqHwb1cTfempLLge2nhLccSAaW8kCtGcTE9H2ccMNYsdcoQKmay(yBB40tzPbbwnayEfUjqbkiyfhAl0kQH2ccMNYsdcD7MsfYrMAJd2Gj5oiWQbaZRWnbk0QRH2ccMNYsdc7MJsbbwnayEfUjqHwBxOTGaRgamVc3ee8WKyyAbbFjMvtPOywPD3W57p)QOyI0X6k1MJ3itsWQBNpRIIu6bNAZ89N3xfEvx0O0bbP0ZYGGBWgKJq2wUNV)8ap)QOy3UPuHCKP24GnysUJqgXsvopON315rJEEumpzywPy3UPuHCKP24GnysUJSAaW8AEqMhn659LywnLIA2StNnJNV)8RIIYYbFGffP0do1M57pVVk8QUOrPdcsPNLbb3GnihHSTCpF)5bE(vrXUDtPc5itTXbBWKChHmILQCEqpVRZJg98OyEYWSsXUDtPc5itTXbBWKChz1aG518GmpA0Zd88(smRMsrL9WcxW18OrpVVeZQPueSByA68OrpVVeZQPuulLNhK57p)QOy3UPuHCKP24GnysUJu6bNAZ89NFvuSB3uQqoYuBCWgmj3riJyPkN)(5DniyEklni4nm(yEkl9GtjfeWPKoQHWbHLbb3GniF6GCxGcTETqBbbwnayEfUji4HjXW0ccKHzLIY6YH25JK5LmYQbaZR57pV30JK5vqW8uwAqqY86uBhFbHoDuwAGcT2cH2ccSAaW8kCtqWdtIHPfeqX8KHzLIY6YH25JK5LmYQbaZR57ppkMFvuuY86uBhFbHoDuwAKsp4uBMV)8Oy(upB4SzNMV)8RII(ccD6OS0iK3GSC3aG5GG5PS0GGK51P2o(ccD6OS0afA96cTfey1aG5v4MGG5PS0GG1uQ7GGhMedtliyEkfZNvrrRPu3ZF)8xB((ZJI5xffTMsDhP0do1MGG3ThZhYGnmjdTIAGcTcQfAliWQbaZRWnbbZtzPbbRPu3bbpmjgMwqW8ukMpRIIwtPUNh09M)AZ3FEiVbz5UbaZZ3F(vrrRPu3rk9GtTji4D7X8HmydtYqROgOqRxFOTGaRgamVc3ee8WKyyAbbZtPy(Skk6OsYaG5JTTHtpLLoFV5VZ8OrppLEWP2mF)5H8gKL7gamhempLLgeCujzaW8X22WPNYsduO1w8qBbbwnayEfUjiyEklni4OsYaG5JTTHtpLLge8WKyyAbbumpLEWP2mF)57e3rgMvkcnKotPJTTHtpLLkJSAaW8A((ZBEkfZNvrrhvsgamFSTnC6PS05VF(2fe8U9y(qgSHjzOvuduOvuVtOTGaRgamVc3ee8WKyyAbbz5GpYDdUMh0ZJAqW8uwAqqCI5dzPsbk0kQOgAliWQbaZRWnbbpmjgMwqafZ7lXSAkfv2dlCbxbbjbtpfAf1GG5PS0GG3W4J5PS0doLuqaNs6Ogche8LywnLcuOvuDn0wqGvdaMxHBccEysmmTGaWZ7lXSAkffZkT7goF)5bEEFv4vDrJjshRRuBoEJmjbRUDoczB5EE0ONFvumr6yDLAZXBKjjy1TZNvrrk9GtTzEqMV)8(QWR6IgLoiiLEwgeCd2GCeY2Y989Nh45xff72nLkKJm1ghSbtYDeYiwQY5b98UopA0ZJI5jdZkf72nLkKJm1ghSbtYDKvdaMxZdY8GmF)5bEEGN3xIz1ukQShw4cUMhn659LywnLIGDdttNhn659LywnLIAP88GmF)59vHx1fnkDqqk9Smi4gSb5iKrSuLZF)8UoF)5bE(vrXUDtPc5itTXbBWKChHmILQCEqpVRZJg98OyEYWSsXUDtPc5itTXbBWKChz1aG518GmpiZJg98apVVeZQPuuZMD6Sz889Nh459vHx1fnklh8bwueY2Y98Orp)QOOSCWhyrrk9GtTzEqMV)8(QWR6IgLoiiLEwgeCd2GCeYiwQY5VFExNV)8ap)QOy3UPuHCKP24GnysUJqgXsvopON315rJEEumpzywPy3UPuHCKP24GnysUJSAaW8AEqMhKGG5PS0GG3W4J5PS0doLuqaNs6OgchewgeCd2G8PdYDbk0kQTl0wqGvdaMxHBccEysmmTGaGskNV)8(QWR6IgLoiiLEwgeCd2GCeYiwQY5b98BzZoDGmILQC((Zd88OyEYWSsXUDtPc5itTXbBWKChz1aG518OrpVVk8QUOXUDtPc5itTXbBWKChHmILQCEqp)w2SthiJyPkNhKGG5PS0GWYGGpYYbhOqROETqBbbwnayEfUji4HjXW0ccakPC((Z7RcVQlAu6GGu6zzqWnydYriJyPkN)259vHx1fnkDqqk9Smi4gSb54YbAuw683p)w2SthiJyPkdcMNYsdcldc(ilhCGcTIAleAliWQbaZRWnbbZtzPbbVHXhZtzPhCkPGaoL0rneoiKeJeOqROEDH2ccSAaW8kCtqW8uwAqWBy8X8uw6bNskiGtjDudHdclgBU51HGPcMjzGcTIkOwOTGaRgamVc3eempLLge8ggFmpLLEWPKcc4ush1q4GWYqSg(qWubZKmqHwr96dTfey1aG5v4MGGhMedtliSkk2TBkvihzQnoydMK7iLEWP2mpA0ZJI5jdZkf72nLkKJm1ghSbtYDKvdaMxbbZtzPbbVHXhZtzPhCkPGaoL0rneoiijJoemvWmjduOvuBXdTfey1aG5v4MGGhMedtliSkkkoX8HSuPiLEWP2eempLLgeqmmVL(d06ihihOqRUENqBbbwnayEfUji4HjXW0ccRIIYYbFGffP0do1M57ppkMNmmRuuwxo0oFKmVKrwnayEfempLLgeqmmVL(d06ihihOqRUIAOTGaRgamVc3ee8WKyyAbbumpzywPO4eZhYsLISAaW8kiyEklniGyyEl9hO1roqoqHwD11qBbbwnayEfUji4HjXW0ccYYbFK7gCnpON)AbbZtzPbbedZBP)aToYbYbk0QRTl0wqGvdaMxHBccMNYsdcYSBV0do34GGhMedtliyEkfZNvrrz2Tx6bNB8833B(2nF)5H8gKL7gampF)5rX8RIIYSBV0do34iLEWP2ee8U9y(qgSHjzOvuduOvxVwOTGaRgamVc3ee8WKyyAbbFjMvtPOYEyHl4kiijy6PqROgempLLge8ggFmpLLEWPKcc4ush1q4GGVeZQPuGcT6AleAliWQbaZRWnbbpmjgMwqaGZ2wmvwCsgamFwmsk5OKmp45bDV5BH7mpA0ZdOKY57ppaNTTyQS4Kmay(SyKuYrNU57p)w2SthiJyPkN)(5BH5rJEEaoBBXuzXjzaW8zXiPKJsY8GNh09MVDTW89NFvuuwo4dSOiLEWP2eempLLgewql1do34afA11Rl0wqivIHqNokiGAqW8uwAqybTupYYbhey1aG5v4MafA1vqTqBbbZtzPbb5UTQlhafMccSAaW8kCtGcuqijgj0wOvudTfempLLgeCK8jjgrgey1aG5v4MafOGGKdTfAf1qBbbZtzPbHDZrPGaRgamVc3eOqRUgAliWQbaZRWnbHujgcD6OtUfewmaNTTOC3w1LdJaaAEokjZdg09AxqW8uwAqybTupYYbhesLyi0PJon4cGHdcOgOqRTl0wqW8uwAqqUBR6YbqHPGaRgamVc3eOafeKKrhcMkyMKH2cTIAOTGaRgamVc3eeudHdcPk9qhYaG5dOYXuYb5SyXPNdcMNYsdcPk9qhYaG5dOYXuYb5SyXPNduOvxdTfey1aG5v4MGGAiCqivjbD8ubLNvkov(aGX4GG5PS0GqQsc64PckpRuCQ8baJXbk0A7cTfey1aG5v4MGGAiCqOeZWnCDj1MJPjID8wdhempLLgekXmCdxxsT5yAIyhV1Wbk061cTfey1aG5v4MGGAiCqyzqWivPNf7bF6Ciil9S65GG5PS0GWYGGrQspl2d(05qqw6z1Zbk0AleAliWQbaZRWnbb1q4GaI5naq(i3zMoioY0hempLLgeqmVbaYh5oZ0bXrM(afA96cTfey1aG5v4MGGAiCqydBi8P2oamIWCqW8uwAqydBi8P2oamIWCGcTcQfAliWQbaZRWnbb1q4GWfdmRmuE2GLUccMNYsdcxmWSYq5zdw6kqHwV(qBbbwnayEfUjiOgcheidaMPtTDwSSZsyqW8uwAqGmayMo12zXYolHbk0AlEOTGaRgamVc3eeudHdcYu3CWht2Lqtj5bGTA4tTD2yy5tYDqW8uwAqqM6Md(yYUeAkjpaSvdFQTZgdlFsUduOvuVtOTGaRgamVc3eeudHdcYu3CWNgSTsJkO8aWwn8P2oBmS8j5oiyEklniitDZbFAW2knQGYdaB1WNA7SXWYNK7afAfvudTfempLLgeaGRAD2CGUdcSAaW8kCtGcTIQRH2ccMNYsdcBjKbGRAfey1aG5v4MafAf12fAliyEklniaGHsgco1MGaRgamVc3eOafOGG5q7fmiiKiGsGcuia]] )


end