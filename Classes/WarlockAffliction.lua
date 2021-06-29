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


    spec:RegisterPack( "Affliction", 20210629, [[d80wLcqiiHfjbu1JieAtsQ(eH0OaItbOwLKsXRuPywujULKs1Ue6xQKmmvs5yqslJkPNjPKPPsfxJquBtLk5BsayCaj15ujvADeImpvQ6EsO9bK6GecSqvk9qGetuLk1fLakBucGYhvjvOtkbKvciZesKBkPuANsq)eijnucbTuja9ucMQKIRQsQOTQsQGVcKeJvc0Ef8xvmyvDyklgGhtvtwjxg1MvkFwIgTs1PfTAjaYRbQzd1THy3K(TudxsoUkPQLd65enDKRtfBNq9DvIXdjQZtLA9savMpK6(sauTFfhqnutqyzehk01R5kQx7UC96gV21vKRfQx3Ga5UIdcvMhSvYbb1q4GGiyBdNEkBniuzUXTTc1eeKTd0ZbHDIQKI0vxvM0UdGOVrUsMioyJYw9qBJUsMi(RccaCsmvG0aGGWYiouORxZvuV2D561nETRRi7ATe5GGSI9HcD9Ue5GWEUwSgaeewS0heebBB40tzRZdQyqC7bpabKJYZ7611L5D9AUI6a0aeOSBAjlfPbOAFErWAXR5fQymEEuQ9GJdq1(8IG1IxZF3S42boFT1ktFCaQ2NxeSw8AEaq2a73nvz884Um9ZV1W5VBOL68cTdooav7ZxZf2apFT1W8w6NVaAvKdKNh3LPFEQN)sdbpFUnV72ruippskLPwoVnpzywP5tDEA3O5H9L4auTpFbMAaW88fqdPYuAErW2go9u2QCErOyr48KHzLIdq1(81CHnWY5PEEtCNR5bG7lPwo)DBqWLydYZN68ioykRDYGLmn)LR65VBq1AKZ7ufhGQ95bLwxSk55Lncp)DBqWLydYZlcHC18EdJLZt98qE54559nsLdzu268uIWXbOAFEbMMx2i88EdJpMNYwp4usZZkbtwop1Zljy6P5PEEtCNR597ShCQLZJtjjNN2nA(lTkknpaEEiB(DEnpiwPLkkaooav7ZdQQy3ZlW8A(w988vqU2RCW44auTpViyvaYrsZxGhGduNhuUB58a4TgYZZ6A(EB(TSCNkWppUlt)8upVvvHDpFRy3Zt98aAPC(TSCNKZdI208e0K7ZxzEWsGJbHkyVLyoiiII48IGTnC6PS15bvmiU9GhGerrCEGCuEExVUUmVRxZvuhGgGerrCEqz30swksdqIOioFTpViyT418cvmgppk1EWXbirueNV2NxeSw8A(7Mf3oW5RTwz6JdqIOioFTpViyT418aGSb2VBQY45XDz6NFRHZF3ql15fAhCCasefX5R95R5cBGNV2AyEl9ZxaTkYbYZJ7Y0pp1ZFPHGNp3M3D7ikKNhjLYulN3MNmmR08PopTB08W(sCasefX5R95lWudaMNVaAivMsZlc22WPNYwLZlcflcNNmmRuCasefX5R95R5cBGLZt98M4oxZda3xsTC(72GGlXgKNp15rCWuw7KblzA(lx1ZF3GQ1iN3PkoajII481(8GsRlwL88YgHN)Uni4sSb55fHqUAEVHXY5PEEiVC888(gPYHmkBDEkr44aKikIZx7ZlW08YgHN3By8X8u26bNsAEwjyYY5PEEjbtpnp1ZBI7CnVFN9GtTCECkj580UrZFPvrP5bWZdzZVZR5bXkTurbWXbirueNV2NhuvXUNxG518T655RGCTx5GXXbirueNV2NxeSka5iP5lWdWbQZdk3TCEa8wd55zDnFVn)wwUtf4Nh3LPFEQN3QQWUNVvS75PEEaTuo)wwUtY5brBAEcAY95RmpyjWXbObiZtzRYyfK9ncaJkUX4ZQrs1OSvxYTIuIWG(A1rrftrdNI56OaGZ2wSeMiDc5tVDKMhMBPNJovdqMNYwLXki7BeagDtXRKoiiTEQyAaY8u2QmwbzFJaWOBkEvjmr6eYNE7inpm3sp7sUvKmmRuSeMiDc5tVDKMhMBPNJSAaW8AaY8u2QmwbzFJaWOBkELydMgam7IAiCXvtYdKTLBxeByhUO5PumFwnf9ne6urzRG(A1npLI5ZQPOv2QBqFT6MNsX8z1u0rLKbaZhBBdNEkBf0xRoiOGmmRuuMv7TEW5ghz1aG5fA0MNsX8z1uuMv7TEW5gd6RbCDqwnfR2nLAKJm1shSbtYDKsp4ulrJgfKHzLIv7MsnYrMAPd2Gj5oYQbaZlGhGmpLTkJvq23iam6MIx5i5tsmIlQHWfTcCYDdAYZwR0P3ov9fgoazEkBvgRGSVray0nfVsY860BhFdHovu2Ql4u5JFve1R5sUvuwXy8HmyjtYOK51P3o(gcDQOS1J1mOlwRbiZtzRYyfK9ncaJUP4v7MJsdqMNYwLXki7BeagDtXRCujzaW8X22WPNYwhGgGerrC(cmuM9oeVMNfZq3ZtjcppTZZBEQHZNY5nXwInayooazEkBvwuwXy8b3EWdqMNYwL3u8QflUDGheRm9dqMNYwL3u8kVHXhZtzRhCkjxudHlAn7IKGPNkIQl5wrZtPy(WkJKSe01AaseNxe4PS15XPKKZV1W5jyQGzAEa8UjoByCEbYi58gKNxAI518BnCEa8wd55fAh88fWMUQaHuX6k1Y5bfJmjb7QD(kr4UPuJmVqQLoydMKBxMVPDgEjL88ToVVB8QVOdqMNYwL3u8kVHXhZtzRhCkjxudHlsWubZ0rwHt643zp4biZtzRYBkEL3W4J5PS1doLKlQHWfxm2CZRdbtfmtYbiZtzRYBkEL3W4J5PS1doLKlQHWfLKrhcMkyMKUijy6PIO6sUveKvtrz7GpWMIu6bNAjA0RMIjsfRRulpEJmjb7QD(SAksPhCQLOrVAkwTBk1ihzQLoydMK7iLEWPwcCDz7GpYDdUaDTqJE1uuCI5dzPsrk9GtTenAYWSsrzF5q78rY8soazEkBvEtXR8ggFmpLTEWPKCrneU4YqSs(qWubZK0LCROVfZQPuuZYD6SzCDqqHydMgamhjyQGz6iRWjHgTVB8QVOrz7GpWMIqgXsvcAxVgA0Gi2GPbaZrcMkyMoTY19DJx9fnkBh8b2ueYiwQY7jyQGzkIA03nE1x0iKrSuLaJgniInyAaWCKGPcMPdDPR77gV6lAu2o4dSPiKrSuL3tWubZu01OVB8QVOriJyPkbgy0O9TywnLIIzL2DdRdckeBW0aG5ibtfmthzfoj0O9DJx9fnMivSUsT84nYKeSR25iKrSuLG21RHgniInyAaWCKGPcMPtRCDF34vFrJjsfRRulpEJmjb7QDoczelv59emvWmfrn67gV6lAeYiwQsGrJgeXgmnayosWubZ0HU019DJx9fnMivSUsT84nYKeSR25iKrSuL3tWubZu01OVB8QVOriJyPkbgy0ObX3Iz1ukQSh24gUqJ23Iz1ukc2nmnfnAFlMvtPO2kdCDqqHydMgamhjyQGz6iRWjHgTVB8QVOXQDtPg5itT0bBWKChHmILQe0UEn0ObrSbtdaMJemvWmDALR77gV6lASA3uQroYulDWgmj3riJyPkVNGPcMPiQrF34vFrJqgXsvcmA0Gi2GPbaZrcMkyMo0LUUVB8QVOXQDtPg5itT0bBWKChHmILQ8EcMkyMIUg9DJx9fnczelvjWaJgnkidZkfR2nLAKJm1shSbtYDKvdaMx1bbfInyAaWCKGPcMPJScNeA0(UXR(IgLoiiTEwgeCj2GCeYiwQsq761qJgeXgmnayosWubZ0PvUUVB8QVOrPdcsRNLbbxInihHmILQ8EcMkyMIOg9DJx9fnczelvjWOrdIydMgamhjyQGz6qx66(UXR(IgLoiiTEwgeCj2GCeYiwQY7jyQGzk6A03nE1x0iKrSuLad8aKio)ToqDEz7GNxUBWLC(CB(TSCNMpLZByKwsZ3Iz4aK5PSv5nfVcXW8w6pqRICGSl5wraTuwFll3PdKrSuL3ZOm7Di(qjcxBKTd(i3n4Q(QPOJkjdaMp22go9u2AKsp4ulhGeX5lqBZ7BXSAkn)QPReH7MsnY8cPw6GnysUNpLZdDun1sxM3rYZF3geCj2G88uppJYeRR5PDEEVdeYknVKPbiZtzRYBkEL3W4J5PS1doLKlQHWfxgeCj2G8PcYvUKBfbX3Iz1ukkMvA3nS(QPyIuX6k1YJ3itsWUANpRMIu6bNAzDF34vFrJsheKwpldcUeBqoczelv59UwhKvtXQDtPg5itT0bBWKChHmILQe0UIgnkidZkfR2nLAKJm1shSbtYnWaJgni(wmRMsrnl3PZMX1xnfLTd(aBksPhCQL19DJx9fnkDqqA9Smi4sSb5iKrSuL37ADqwnfR2nLAKJm1shSbtYDeYiwQsq7kA0OGmmRuSA3uQroYulDWgmj3admA0GaIVfZQPuuzpSXnCHgTVfZQPueSByAkA0(wmRMsrTvg46RMIv7MsnYrMAPd2Gj5osPhCQL1xnfR2nLAKJm1shSbtYDeYiwQY7Df4birC(ciVbz5(8RMKZZge7E(CB(Yo1Y5tL65T5L7gCnVSI1vQLZxTBsEaY8u2Q8MIx5nm(yEkB9Gtj5IAiCXvtNkix5sUveeFlMvtPOML70zZ46Oy1uu2o4dSPiLEWPww33nE1x0OSDWhytriJyPkV)oaJgni(wmRMsrXSs7UH1rXQPyIuX6k1YJ3itsWUANpRMIu6bNAzDF34vFrJjsfRRulpEJmjb7QDoczelv593by0ObbeFlMvtPOYEyJB4cnAFlMvtPiy3W0u0O9TywnLIARmW1jdZkfR2nLAKJm1shSbtYDDuSAkwTBk1ihzQLoydMK7iLEWPww33nE1x0y1UPuJCKPw6GnysUJqgXsvE)DaEaseNVaTnViC3uQrMxi1shSbtY98PCEk9GtT0L5tA(uoV0245PEEhjp)DBqWZl0o4biZtzRYBkE1YGGpY2b7sUvC1uSA3uQroYulDWgmj3rk9GtTCaY8u2Q8MIxTmi4JSDWUKBfrbzywPy1UPuJCKPw6GnysURdYQPOSDWhytrk9GtTen6vtXePI1vQLhVrMKGD1oFwnfP0do1sGhGeX5fCR(5fH7MsnY8cPw6GnysUN)ss7ZFDGvA3n8QcZYDA(cWmEEFlMvtP5xn5Y8nTZWlPKN3rYZ368(UXR(IgNVaTnFbgsLBiB45bvHl1upppaNTT5t58P6BKulDz(9gVM3rPepFsIkNhY2Y98GGkOEEj7BDjN32igoVJKbEaY8u2Q8MIxvTBk1ihzQLoydMKBxYTI(wmRMsrnl3PZMX1PeHbTix33nE1x0OSDWhytriJyPkVh16GqWubZuKrQCdzdFA4sn1ZrF34vFrJqgXsvEpQ3LROrJc(6DYQkEfzKk3q2WNgUut9mWdqMNYwL3u8QQDtPg5itT0bBWKC7sUv03Iz1ukkMvA3nSoLimOf56(UXR(IgtKkwxPwE8gzsc2v7CeYiwQY7rToiemvWmfzKk3q2WNgUut9C03nE1x0iKrSuL3J6D5kA0OGVENSQIxrgPYnKn8PHl1upd8aK5PSv5nfVQA3uQroYulDWgmj3UKBfbX3Iz1ukQSh24gUqJ23Iz1ukc2nmnfnAFlMvtPO2kdCDqiyQGzkYivUHSHpnCPM65OVB8QVOriJyPkVh17Yv0OrbF9ozvfVImsLBiB4tdxQPEg4biZtzRYBkEv1UPuJCKPw6GnysUDj3kcOLY6Bz5oDGmILQ8EuVRbirC(c028IWDtPgzEHulDWgmj3ZNY5P0do1sxMpjrLZtjcpp1Z7i55BANHZJyfGA48RMKdqMNYwL3u8kVHXhZtzRhCkjxudHl6BXSAk5sUvC1uSA3uQroYulDWgmj3rk9GtTSoi(wmRMsrnl3PZMXOr7BXSAkffZkT7gc8aK5PSv5nfVYkB1TlE3EmFidwYKSiQUKBfxnfTYwDhHmILQ8(7mazEkBvEtXR2nhLgGeX5f6lZt788cmVKZ3681AEYGLmjNp3MpP5tPkknV3bczLWUNp153Wz5onFdNV15PDEEYGLmfNhujP95fYQ9wNhLYnE(KevoVHL98ayIy48upVJKNxG518TygopIPogg7EERQc7o1Y5R18GsdHovu2QmoazEkBvEtXRKmVo92X3qOtfLT6sUv08ukMpSYijlbTR1jdZkfL9LdTZhjZlzDuSAkkzED6TJVHqNkkBnsPhCQL1rrQNnCwUtdqMNYwL3u8kjZRtVD8ne6urzRUKBfnpLI5dRmsYsq7ADYWSsrzwT36bNBCDuSAkkzED6TJVHqNkkBnsPhCQL1rrQNnCwUt1xnf9ne6urzRriJyPkV)odqMNYwL3u8kXjMpKLk5sUveez7GpYDdUanQOrBEkfZhwzKKLG2vGR77gV6lAu6GG06zzqWLydYriJyPkbnQUoazEkBvEtXRCujzaW8X22WPNYwDj3kAEkfZNvtrhvsgamFSTnC6PS1IxdnAk9GtTS(QPOJkjdaMp22go9u2AeYiwQY7VZaK5PSv5nfVsMv7TEW5g7I3ThZhYGLmjlIQl5wXvtrzwT36bNBCeYiwQY7VZaK5PSv5nfVYBy8X8u26bNsYf1q4I(wmRMsUijy6PIO6sUvef(wmRMsrL9Wg3W1aKioViOQc7EEqPHqNkkBDEetDmm298TopQ1URZtgSKjPlZ3W5BD(An)LK2Nxeaq2yhINhuAi0PIYwhGmpLTkVP4v(gcDQOSvx8U9y(qgSKjzruDj3kAEkfZhwzKKL3FNAheYWSsrzF5q78rY8sIgnzywPOmR2B9GZng46RMI(gcDQOS1iKrSuL376aKioViyJy480opFxXkdDzEzfRR5T5L7gCn)LDwN3O5f55BD(ARH5T0pFb0Qihipp1ZBI7CnFlMHERQk1YbiZtzRYBkEfIH5T0FGwf5azxYTIY2bFK7gCb67uNseg0UI6aKiopOYoRZRnnV0T6tTCEr4UPuJmVqQLoydMK75PE(RdSs7UHxvywUtZxaMXUmVGdcsRZF3geCj2G88528ggp)Qj58gKN3QQWjVgGmpLTkVP4vEdJpMNYwp4usUOgcxCzqWLydYNkix5sUveeFlMvtPOywPD3W6OGmmRuSA3uQroYulDWgmj31xnftKkwxPwE8gzsc2v78z1uKsp4ulR77gV6lAu6GG06zzqWLydYriBl3aJgni(wmRMsrnl3PZMX1rbzywPy1UPuJCKPw6GnysURVAkkBh8b2uKsp4ulR77gV6lAu6GG06zzqWLydYriBl3aJgniG4BXSAkfv2dBCdxOr7BXSAkfb7gMMIgTVfZQPuuBLbUUVB8QVOrPdcsRNLbbxInihHSTCd8aKio)1PKN)Uni45fAh885283TbbxInip)LwfLMhappKTL75TslvxMVHZNBZt7mKN)sIXZdGN3O5XSjP5DDEKgYZF3geCj2G88oswoazEkBvEtXRwge8r2oyxYTIaAPSUVB8QVOrPdcsRNLbbxInihHmILQe0Bz5oDGmILQSoiOGmmRuSA3uQroYulDWgmj3Or77gV6lASA3uQroYulDWgmj3riJyPkb9wwUthiJyPkbEaY8u2Q8MIxTmi4JSDWUKBfb0szDuqgMvkwTBk1ihzQLoydMK76(UXR(IgLoiiTEwgeCj2GCeYiwQYB8DJx9fnkDqqA9Smi4sSb54YbAu269Bz5oDGmILQCaseNhumYVx7ggpFsmY8osRKNFRHZBQBAp1Y51MMxwX(Cl518mwYx2zipazEkBvEtXR8ggFmpLTEWPKCrneUysmYaKikIZxa5nil3Nxy3w9L5lWqaanpppaERH88YkwxPwoVC3Gl58ToFT1W8w6NVaAvKdKhGmpLTkVP4vEdJpMNYwp4usUOgcxuYUKBfjdZkfL72QVCyeaqZZrwnayEvhKfdWzBlk3TvF5WiaGMNJsY8GVhexRDZtzRr5UT6lhanMIPE2Wz5obmA0lgGZ2wuUBR(YHraanphHmILQ8(Ab8aKio)1PKNV2AyEl9ZxaTkYbYZFzN15rScqnC(vtY5nipVtLlZ3W5ZT5PDgYZFjX45bWZlZsn3sVP08uIWZ7OuINN255vgLP5fH7MsnY8cPw6GnysUJZxG2M3HsCwGl1Y5RTgM3s)8GkqJ2Dz(9gVM3MxUBW18uppK3GSCFEANNhGZ22aK5PSv5nfVcXW8w6pqRICGSl5wrqwnffNy(qwQuKsp4ulrJE1umrQyDLA5XBKjjyxTZNvtrk9GtTen6vtrz7GpWMIu6bNAjW1bbfqhL3AyjhrmmVL(ZfOr7OrdWzBlIyyEl9NlqJ2JsY8GVVwOrlBh8rUBWfOrf4birC(RtjpFT1W8w6NVaAvKdKNN65rSujl15PDEEedZBPF(lqJ2NhGZ228okL45L7gCjNxzEnp1ZdGNVKvgAeVMFRHZt788kJY08aCGsA(lPU6lZdIRxBEj7BDjNpLZJ0qEEA305LoBBPpzLMN65lzLHgXZxR5L7gCjbEaY8u2Q8MIxHyyEl9hOvroq2LCRi0r5TgwYredZBP)CbA0EDF34vFrJY2bFGnfHmILQe0UET6aC22IigM3s)5c0O9iKrSuL3FNbirC(RtjpFT1W8w6NVaAvKdKNV15fH7MsnY8cPw6GnysUN3Bss6Y8ig4ulNx6a55PEEPjMN3MxUBW18upVKmp45RTgM3s)8GkqJ2Np3M3rMA58jnazEkBvEtXRqmmVL(d0Qihi7sUvKmmRuSA3uQroYulDWgmj31bz1uSA3uQroYulDWgmj3rk9GtTenAF34vFrJv7MsnYrMAPd2Gj5oczelvjODvKrJgqlL1PeHpuFwjFVVB8QVOXQDtPg5itT0bBWKChHmILQe46GGcOJYBnSKJigM3s)5c0OD0Ob4STfrmmVL(ZfOr7rjzEW3xl0OLTd(i3n4c0Oc8aK5PSv5nfVcXW8w6pqRICGSl5wrYWSsrzF5q78rY8soajIZF3ql15rPCJNpLZ3k298283Tiuy(sl15VK0(8fiLfNKbaZZF3msk55v2GZJyO88sY8GLX5lqBZVLL708PCEdq7qZt98SUMF1ZRnnpskLZlRyDLA580opVKmpy5aK5PSv5nfVAbTup4CJDj3kcWzBlMklojdaMplgjLCusMhmOVZ1qJgGZ2wmvwCsgamFwmsk5OtvDaTuwFll3PdKrSuL3FNbiZtzRYBkEL3W4J5PS1doLKlQHWf9TywnLgGmpLTkVP4vwzRUDX72J5dzWsMKfr1LCRiK3GSC3aG5biZtzRYBkELJkjdaMp22go9u2Ql5wrZtPy(SAk6OsYaG5JTTHtpLTw8AOrtPhCQL1H8gKL7gampazEkBvEtXRKz1ERhCUXU4D7X8HmyjtYIO6sUveYBqwUBaW8aK5PSv5nfVY3qOtfLT6I3ThZhYGLmjlIQl5wriVbz5UbaZ1npLI5dRmsYY7VtTdczywPOSVCOD(izEjrJMmmRuuMv7TEW5gd8aK5PSv5nfVAbTupY2b7sQedHovuruhGmpLTkVP4vYDB1xoaAmnanazEkBvgTMlwTBk1ihzQLoydMK7biZtzRYO18nfVA3CuAaY8u2QmAnFtXR8ggFmpLTEWPKCrneU4YGGlXgKpvqUYLCROVfZQPuumR0UBy9vtXePI1vQLhVrMKGD1oFwnfP0do1Y6(UXR(IgLoiiTEwgeCj2GCeY2YDDqwnfR2nLAKJm1shSbtYDeYiwQsq7kA0OGmmRuSA3uQroYulDWgmj3aJgTVfZQPuuZYD6SzC9vtrz7GpWMIu6bNAzDF34vFrJsheKwpldcUeBqoczB5UoiRMIv7MsnYrMAPd2Gj5oczelvjODfnAuqgMvkwTBk1ihzQLoydMKBGrJgeFlMvtPOYEyJB4cnAFlMvtPiy3W0u0O9TywnLIARmW1xnfR2nLAKJm1shSbtYDKsp4ulRVAkwTBk1ihzQLoydMK7iKrSuL376aK5PSvz0A(MIxjzED6TJVHqNkkB1LCRizywPOSVCOD(izEjR7n9izEnazEkBvgTMVP4vsMxNE74Bi0PIYwDj3kIcYWSsrzF5q78rY8swhfRMIsMxNE74Bi0PIYwJu6bNAzDuK6zdNL7u9vtrFdHovu2AeYBqwUBaW8aK5PSvz0A(MIxzLT62fVBpMpKblzswevxYTIMNsX8z1u0kB1993PokwnfTYwDhP0do1YbiZtzRYO18nfVYkB1TlE3EmFidwYKSiQUKBfnpLI5ZQPOv2QBqx8o1H8gKL7gamxF1u0kB1DKsp4ulhGmpLTkJwZ3u8khvsgamFSTnC6PSvxYTIMNsX8z1u0rLKbaZhBBdNEkBT41qJMsp4ulRd5nil3nayEaY8u2QmAnFtXRCujzaW8X22WPNYwDX72J5dzWsMKfr1LCRikO0do1Y6vIRidZkfHgsLP0X22WPNYwLrwnayEv38ukMpRMIoQKmay(yBB40tzR3xRbiZtzRYO18nfVsCI5dzPsUKBfLTd(i3n4c0OoazEkBvgTMVP4vEdJpMNYwp4usUOgcx03Iz1uYfjbtpvevxYTIOW3Iz1ukQSh24gUgGmpLTkJwZ3u8kVHXhZtzRhCkjxudHlUmi4sSb5tfKRCj3kcIVfZQPuumR0UByDq8DJx9fnMivSUsT84nYKeSR25iKTLB0OxnftKkwxPwE8gzsc2v78z1uKsp4ulbUUVB8QVOrPdcsRNLbbxInihHSTCxhKvtXQDtPg5itT0bBWKChHmILQe0UIgnkidZkfR2nLAKJm1shSbtYnWaxheq8TywnLIk7HnUHl0O9TywnLIGDdttrJ23Iz1ukQTYax33nE1x0O0bbP1ZYGGlXgKJqgXsvEVR1bz1uSA3uQroYulDWgmj3riJyPkbTROrJcYWSsXQDtPg5itT0bBWKCdmWOrdIVfZQPuuZYD6SzCDq8DJx9fnkBh8b2ueY2YnA0RMIY2bFGnfP0do1sGR77gV6lAu6GG06zzqWLydYriJyPkV316GSAkwTBk1ihzQLoydMK7iKrSuLG2v0OrbzywPy1UPuJCKPw6GnysUbg4biZtzRYO18nfVAzqWhz7GDj3kcOLY6(UXR(IgLoiiTEwgeCj2GCeYiwQsqVLL70bYiwQY6GGcYWSsXQDtPg5itT0bBWKCJgTVB8QVOXQDtPg5itT0bBWKChHmILQe0Bz5oDGmILQe4biZtzRYO18nfVAzqWhz7GDj3kcOLY6(UXR(IgLoiiTEwgeCj2GCeYiwQYB8DJx9fnkDqqA9Smi4sSb54YbAu269Bz5oDGmILQCaY8u2QmAnFtXR8ggFmpLTEWPKCrneUysmYaK5PSvz0A(MIx5nm(yEkB9Gtj5IAiCXfJn386qWubZKCaY8u2QmAnFtXR8ggFmpLTEWPKCrneU4YqSs(qWubZKCaY8u2QmAnFtXR8ggFmpLTEWPKCrneUOKm6qWubZK0LCR4QPy1UPuJCKPw6GnysUJu6bNAjA0OGmmRuSA3uQroYulDWgmj3dqMNYwLrR5BkEfIH5T0FGwf5azxYTIRMIItmFilvksPhCQLdqMNYwLrR5BkEfIH5T0FGwf5azxYTIRMIY2bFGnfP0do1Y6OGmmRuu2xo0oFKmVKdqMNYwLrR5BkEfIH5T0FGwf5azxYTIOGmmRuuCI5dzPsdqMNYwLrR5BkEfIH5T0FGwf5azxYTIY2bFK7gCb67mazEkBvgTMVP4vYSAV1do3yx8U9y(qgSKjzruDj3kAEkfZNvtrzwT36bNB89fRvDiVbz5UbaZ1rXQPOmR2B9GZnosPhCQLdqMNYwLrR5BkEL3W4J5PS1doLKlQHWf9TywnLCrsW0tfr1LCROVfZQPuuzpSXnCnazEkBvgTMVP4vlOL6bNBSl5wraoBBXuzXjzaW8zXiPKJsY8GbDrr(AOrdOLY6aC22IPYItYaG5ZIrsjhDQQVLL70bYiwQY7fz0Ob4STftLfNKbaZNfJKsokjZdg0fRLixF1uu2o4dSPiLEWPwoazEkBvgTMVP4vlOL6r2oyxsLyi0PIkI6aK5PSvz0A(MIxj3TvF5aOX0a0aK5PSvz03Iz1uQyIuX6k1YJ3itsWUANDj3kIcYWSsXQDtPg5itT0bBWKCxheF34vFrJsheKwpldcUeBqoczelv59OEn0O9DJx9fnkDqqA9Smi4sSb5iKrSuLGwKVwDF34vFrJsheKwpldcUeBqoczelvjODvKR7BD5Ku03qOtfLA5bZme4biZtzRYOVfZQP0nfVkrQyDLA5XBKjjyxTZUKBfjdZkfR2nLAKJm1shSbtYD9vtXQDtPg5itT0bBWKChP0do1YbiZtzRYOVfZQP0nfVAX(eXOulpaAm5sUv03nE1x0O0bbP1ZYGGlXgKJqgXsvcArUoilgGZ2wC3CukczelvjOVdA0OGmmRuC3Cuc4biZtzRYOVfZQP0nfVs2o4dSjxYTIOGmmRuSA3uQroYulDWgmj31bX3nE1x0O0bbP1ZYGGlXgKJqgXsvEViJgTVB8QVOrPdcsRNLbbxInihHmILQe0I81qJ23nE1x0O0bbP1ZYGGlXgKJqgXsvcAxf56(wxojf9ne6urPwEWmdbEaY8u2Qm6BXSAkDtXRKTd(aBYLCRizywPy1UPuJCKPw6GnysURVAkwTBk1ihzQLoydMK7iLEWPwoazEkBvg9TywnLUP4vsF7atT8qjTZdqdqMNYwLXLHyL8HGPcMjzrhjFsIrCrneUOSDWNSutIHdqMNYwLXLHyL8HGPcMj5nfVYrYNKyexudHlUGST2siFeZsjJhGmpLTkJldXk5dbtfmtYBkELJKpjXiUOgcxSe7UA)0BhtktKeBu26a0aK5PSvzCzqWLydYNkixvuCI5dzPsdqMNYwLXLbbxIniFQGC1nfVAzqWhz7GhGmpLTkJldcUeBq(ub5QBkEvvtzRdqMNYwLXLbbxIniFQGC1nfVAlHmaC3RbiZtzRY4YGGlXgKpvqU6MIxba396S5aDpazEkBvgxgeCj2G8PcYv3u8kamuYqWPwoazEkBvgxgeCj2G8PcYv3u8kVHXhZtzRhCkjxudHl6BXSAk5sUvef(wmRMsrL9Wg3W1aK5PSvzCzqWLydYNkixDtXRKoiiTEwgeCj2G8a0aK5PSvzCXyZnVoemvWmjl6i5tsmIlQHWfzKk3q2WNgUut9Sl5wrq8TywnLIAwUtNnJR77gV6lAu2o4dSPiKrSuL3761agnAq8TywnLIIzL2DdR77gV6lAmrQyDLA5XBKjjyxTZriJyPkV31RbmA0G4BXSAkfv2dBCdxOr7BXSAkfb7gMMIgTVfZQPuuBLbEaY8u2QmUyS5MxhcMkyMK3u8khjFsIrCrneUO0rbG7EDmeM2DljxYTIG4BXSAkf1SCNoBgx33nE1x0OSDWhytriJyPkV)UagnAq8TywnLIIzL2DdR77gV6lAmrQyDLA5XBKjjyxTZriJyPkV)UagnAq8TywnLIk7HnUHl0O9TywnLIGDdttrJ23Iz1ukQTYapazEkBvgxm2CZRdbtfmtYBkELJKpjXiUOgcxu2oymtuQLhOda3UKBfbX3Iz1ukQz5oD2mUUVB8QVOrz7GpWMIqgXsvEpOgy0ObX3Iz1ukkMvA3nSUVB8QVOXePI1vQLhVrMKGD1ohHmILQ8EqnWOrdIVfZQPuuzpSXnCHgTVfZQPueSByAkA0(wmRMsrTvg4bObiZtzRY4QPtfKRkALT62LCR4QPOv2Q7iKrSuL3dQR77gV6lAu6GG06zzqWLydYriJyPkb9QPOv2Q7iKrSuLdqMNYwLXvtNkixDtXRKz1ERhCUXUKBfxnfLz1ERhCUXriJyPkVhux33nE1x0O0bbP1ZYGGlXgKJqgXsvc6vtrzwT36bNBCeYiwQYbiZtzRY4QPtfKRUP4voQKmay(yBB40tzRUKBfxnfDujzaW8X22WPNYwJqgXsvEpOUUVB8QVOrPdcsRNLbbxInihHmILQe0RMIoQKmay(yBB40tzRriJyPkhGmpLTkJRMovqU6MIx5Bi0PIYwDj3kUAk6Bi0PIYwJqgXsvEpOUUVB8QVOrPdcsRNLbbxInihHmILQe0RMI(gcDQOS1iKrSuLdqdqMNYwLXKyKIos(KeJihGgGmpLTkJsU4U5O0aK5PSvzuY3u8Qf0s9iBhSlPsme6urNsCdWWfr1LujgcDQOtUvCXaC22IYDB1xomcaO55OKmpyqxSwdqMNYwLrjFtXRK72QVCa0yAaAaY8u2QmkjJoemvWmjl6i5tsmIlQHWftv6HoKbaZNR3XuYb5SyXPNhGmpLTkJsYOdbtfmtYBkELJKpjXiUOgcxmvjbD8udLNvkov(aGX4biZtzRYOKm6qWubZK8MIx5i5tsmIlQHWfBXmCd3xsT8yAIyhVvYdqMNYwLrjz0HGPcMj5nfVYrYNKyexudHlUmiyKU1ZI9GpvoeKLEw98aK5PSvzusgDiyQGzsEtXRCK8jjgXf1q4IiM3aa5JCNz6G4it)aK5PSvzusgDiyQGzsEtXRCK8jjgXf1q4IBydHp92bGreMhGmpLTkJsYOdbtfmtYBkELJKpjXiUOgcx8IbMvgkpBWwxdqMNYwLrjz0HGPcMj5nfVYrYNKyexudHlsgamtNE7SyzLLWbiZtzRYOKm6qWubZK8MIx5i5tsmIlQHWfLPU5GpMSkHMsYdaBvYNE7SXW2NK7biZtzRYOKm6qWubZK8MIx5i5tsmIlQHWfLPU5GpLyBLg1q5bGTk5tVD2yy7tY9aK5PSvzusgDiyQGzsEtXRaG7ED2CGUhGmpLTkJsYOdbtfmtYBkE1wcza4UxdqMNYwLrjz0HGPcMj5nfVcadLmeCQLdqdqI48Gk88RwfLMx6uv1qA(Pa85n58feuTaoFQZJsoMlZl75lqIkMN33Qygs8AEApLZt98gmPDeMsFCaY8u2QmsWubZ0rwHt643zp4IInyAaWSlQHWfLvSpn8HVENSQIxUi2WoCrqab1AdF9ozvfVImsLBiB4tdxQPEg4Bab1AdF9ozvfVIPk9qhYaG5Z17yk5GCwS40ZaFdiOwB4R3jRQ4vu2oymtuQLhOda3aFdiOwB4R3jRQ4vu6OaWDVogct7ULeWaxe1biZtzRYibtfmthzfoPJFN9GVP4vInyAaWSlQHWfjyQGz60k7Iyd7WfbHGPcMPiQXDtEQGTVobtfmtruJ7M847gV6lkWdqMNYwLrcMkyMoYkCsh)o7bFtXReBW0aGzxudHlsWubZ0HU0Ui2WoCrqiyQGzk6AC3KNky7RtWubZu014Ujp(UXR(Ic8aK5PSvzKGPcMPJScN0XVZEW3u8kXgmnay2f1q4IldXk5dbtfmtUi2WoCrqqbiemvWmfrnUBYtfS91jyQGzkIAC3KhF34vFrbgy0ObbfGqWubZu014UjpvW2xNGPcMPORXDtE8DJx9ffyGrJMVENSQIxXsS7Q9tVDmPmrsSrzRdqMNYwLrcMkyMoYkCsh)o7bFtXReBW0aGzxudHlsWubZ0rwHtYfXg2HlcIydMgamhjyQGz60kxxSbtdaMJldXk5dbtfmtaJgniInyAaWCKGPcMPdDPRl2GPbaZXLHyL8HGPcMjGrJgeuRnInyAaWCKGPcMPtRmW3acQ1gXgmnayokRyFA4dF9ozvfVaUiQOrdcQ1gXgmnayosWubZ0HU0aFdiOwBeBW0aG5OSI9PHp817Kvv8c4IOgeeZqz2AOqxVMROET7YvqDq4Ib1ulLbbqfrqbSWcuHxhfP5NVMDE(ePQH08BnCErjyQGz6iRWjD87ShSOZd5R3jH8AEzJWZBouJyeVM3VBAjlJdqOuQ88UksZdkTkMHeVMxucMkyMIOglOOZt98IsWubZuKqnwqrNhexrzGJdqOuQ881sKMhuAvmdjEnVOemvWmfDnwqrNN65fLGPcMPi5ASGIopiUIYahhGqPu55VJinpO0Qygs8AErjyQGzkIASGIop1Zlkbtfmtrc1ybfDEqCfLbooaHsPYZFhrAEqPvXmK418IsWubZu01ybfDEQNxucMkyMIKRXck68G4kkdCCaAacureualSav41rrA(5RzNNprQAin)wdNxuFlMvtjrNhYxVtc518YgHN3COgXiEnVF30swghGqPu55rvKMhuAvmdjEnVOKHzLIfu05PEErjdZkflyKvdaMxIopiOIYahhGqPu55rvKMhuAvmdjEnVO(wxojflOOZt98I6BD5KuSGrwnayEj68GGkkdCCacLsLN3vrAEqPvXmK418IsgMvkwqrNN65fLmmRuSGrwnayEj68GGkkdCCacLsLNVwI08GsRIziXR5fLmmRuSGIop1ZlkzywPybJSAaW8s05bbvug44aekLkp)DeP5bLwfZqIxZlkzywPybfDEQNxuYWSsXcgz1aG5LOZdcQOmWXbiukvE(7isZdkTkMHeVMxuFRlNKIfu05PEEr9TUCskwWiRgamVeDEqqfLbooaHsPYZlYI08GsRIziXR5fLmmRuSGIop1ZlkzywPybJSAaW8s05bbvug44a0aeOIiOawybQWRJI08ZxZopFIu1qA(TgoVOlEZCWKOZd5R3jH8AEzJWZBouJyeVM3VBAjlJdqOuQ883LinpO0Qygs8AErjdZkflOOZt98IsgMvkwWiRgamVeDEJMVadufLMheurzGJdqOuQ88faI08GsRIziXR5fLGPcMPiQXck68upVOemvWmfjuJfu05b5oOmWXbiukvE(carAEqPvXmK418IsWubZu01ybfDEQNxucMkyMIKRXck68GChug44aekLkp)1vKMhuAvmdjEnVOKHzLIfu05PEErjdZkflyKvdaMxIopiUIYahhGqPu55r9AI08GsRIziXR5fLmmRuSGIop1ZlkzywPybJSAaW8s05bbvug44aekLkppQUksZdkTkMHeVMxuYWSsXck68upVOKHzLIfmYQbaZlrNheurzGJdqOuQ88OwlrAEqPvXmK418IsWubZu0a4J(UXR(Ik68upVO(UXR(IgnaErNheurzGJdqOuQ88OEhrAEqPvXmK418IsWubZu0a4J(UXR(Ik68upVO(UXR(IgnaErNheurzGJdqOuQ88OkYI08GsRIziXR5fLGPcMPObWh9DJx9fv05PEEr9DJx9fnAa8IopiOIYahhGqPu55D9AI08GsRIziXR5fLmmRuSGIop1ZlkzywPybJSAaW8s05bbvug44aekLkpVROksZdkTkMHeVMxuYWSsXck68upVOKHzLIfmYQbaZlrNheurzGJdqOuQ88UExI08GsRIziXR5fLmmRuSGIop1ZlkzywPybJSAaW8s05bXvug44aekLkpVRGArAEqPvXmK418IsgMvkwqrNN65fLmmRuSGrwnayEj68G4kkdCCacLsLN31RRinpO0Qygs8AErjdZkflOOZt98IsgMvkwWiRgamVeDEqqfLbooaHsPYZxRRjsZdkTkMHeVMxuYWSsXck68upVOKHzLIfmYQbaZlrNheurzGJdqOuQ881QwI08GsRIziXR5ff6O8wdl5ybfDEQNxuOJYBnSKJfmYQbaZlrNheurzGJdqOuQ8816oI08GsRIziXR5ff6O8wdl5ybfDEQNxuOJYBnSKJfmYQbaZlrNheurzGJdqOuQ881sKfP5bLwfZqIxZlkzywPybfDEQNxuYWSsXcgz1aG5LOZdcQOmWXbiukvE(AjYI08GsRIziXR5ff6O8wdl5ybfDEQNxuOJYBnSKJfmYQbaZlrNheurzGJdqOuQ8816UeP5bLwfZqIxZlkzywPybfDEQNxuYWSsXcgz1aG5LOZB08fyGQO08GGkkdCCacLsLN)oUksZdkTkMHeVMxuYWSsXck68upVOKHzLIfmYQbaZlrNhexrzGJdqdqGkIGcyHfOcVoksZpFn788jsvdP53A48IAnl68q(6DsiVMx2i88Md1igXR597MwYY4aekLkpFTeP5bLwfZqIxZlkzywPybfDEQNxuYWSsXcgz1aG5LOZdIROmWXbiukvE(7isZdkTkMHeVMxuYWSsXck68upVOKHzLIfmYQbaZlrNheurzGJdqOuQ88ISinpO0Qygs8AErjdZkflOOZt98IsgMvkwWiRgamVeDEqqfLbooaHsPYZJQRI08GsRIziXR5fLmmRuSGIop1ZlkzywPybJSAaW8s05bPwOmWXbiukvEEuRLinpO0Qygs8AErjdZkflOOZt98IsgMvkwWiRgamVeDEqqfLbooaHsPYZJkOwKMhuAvmdjEnVOKHzLIfu05PEErjdZkflyKvdaMxIoVrZxGbQIsZdcQOmWXbiukvEExVMinpO0Qygs8AErjdZkflOOZt98IsgMvkwWiRgamVeDEJMVadufLMheurzGJdqOuQ88UIQinpO0Qygs8AErjdZkflOOZt98IsgMvkwWiRgamVeDEJMVadufLMheurzGJdqdqfiKQgs8AEuDDEZtzRZJtjjJdqbbZH2ByqqiraLGaoLKmutqyzqWLydYNkixfQjuiQHAccMNYwdcItmFilvkiWQbaZRWTbkuORHAccMNYwdcldc(iBhCqGvdaMxHBduOWAfQjiyEkBniu1u2AqGvdaMxHBduOW7eQjiyEkBniSLqgaU7vqGvdaMxHBduOqroutqW8u2AqaaU71zZb6oiWQbaZRWTbku4DfQjiyEkBniaGHsgco1YGaRgamVc3gOqHfaHAccSAaW8kCBqWdtIHPfeqX8(wmRMsrL9Wg3WvqW8u2AqWBy8X8u26bNskiGtjDudHdc(wmRMsbkuiOoutqW8u2Aqq6GG06zzqWLydYbbwnayEfUnqbkiqWubZ0rwHt643zp4qnHcrnutqGvdaMxHBdcDvqqYuqW8u2AqqSbtdaMdcInSdheazEqMh15RnZZxVtwvXRiJu5gYg(0WLAQNNh45VzEqMh15RnZZxVtwvXRyQsp0Hmay(C9oMsoiNflo988ap)nZdY8OoFTzE(6DYQkEfLTdgZeLA5b6aW98ap)nZdY8OoFTzE(6DYQkEfLokaC3RJHW0UBjnpWZd88fNh1GWILEywrzRbbqfE(vRIsZlDQQAinFqqSbpQHWbbzf7tdF4R3jRQ4vGcf6AOMGaRgamVc3ge6QGGKPGG5PS1GGydMgamheeByhoiaY8emvWmfjuJ7M8ubB)81NNGPcMPiHAC3KhF34vFrNh4GGydEudHdcemvWmDALduOWAfQjiWQbaZRWTbHUkiizkiyEkBnii2GPbaZbbXg2HdcGmpbtfmtrY14UjpvW2pF95jyQGzksUg3n5X3nE1x05boii2Gh1q4Gabtfmth6shOqH3jutqGvdaMxHBdcDvqqYuqW8u2AqqSbtdaMdcInSdheazEumpiZtWubZuKqnUBYtfS9ZxFEcMkyMIeQXDtE8DJx9fDEGNh45rJEEqMhfZdY8emvWmfjxJ7M8ubB)81NNGPcMPi5AC3KhF34vFrNh45bEE0ONNVENSQIxXsS7Q9tVDmPmrsSrzRbbXg8OgchewgIvYhcMkyMcuOqroutqGvdaMxHBdcDvqqYuqW8u2AqqSbtdaMdcInSdheazEXgmnayosWubZ0PvE(6Zl2GPbaZXLHyL8HGPcMP5bEE0ONhK5fBW0aG5ibtfmth6spF95fBW0aG54YqSs(qWubZ08appA0ZdY8OoFTzEXgmnayosWubZ0PvEEGN)M5bzEuNV2mVydMgamhLvSpn8HVENSQIxZd88fNh15rJEEqMh15RnZl2GPbaZrcMkyMo0LEEGN)M5bzEuNV2mVydMgamhLvSpn8HVENSQIxZd88fNh1GGydEudHdcemvWmDKv4KcuGccldXk5dbtfmtYqnHcrnutqGvdaMxHBdcQHWbbz7GpzPMeddcMNYwdcY2bFYsnjggOqHUgQjiWQbaZRWTbb1q4GWcY2AlH8rmlLmoiyEkBniSGST2siFeZsjJduOWAfQjiWQbaZRWTbb1q4Gqj2D1(P3oMuMij2OS1GG5PS1Gqj2D1(P3oMuMij2OS1afOGWIXMBEDiyQGzsgQjuiQHAccSAaW8kCBqW8u2AqGrQCdzdFA4sn1ZbbpmjgMwqaK59TywnLIAwUtNnJNV(8(UXR(IgLTd(aBkczelv583pVRxBEGNhn65bzEFlMvtPOywPD3W5RpVVB8QVOXePI1vQLhVrMKGD1ohHmILQC(7N31RnpWZJg98GmVVfZQPuuzpSXnCnpA0Z7BXSAkfb7gMMopA0Z7BXSAkf1w55boiOgcheyKk3q2WNgUut9CGcf6AOMGaRgamVc3gempLTgeKokaC3RJHW0UBjfe8WKyyAbbqM33Iz1ukQz5oD2mE(6Z77gV6lAu2o4dSPiKrSuLZF)8318appA0ZdY8(wmRMsrXSs7UHZxFEF34vFrJjsfRRulpEJmjb7QDoczelv583p)DnpWZJg98GmVVfZQPuuzpSXnCnpA0Z7BXSAkfb7gMMopA0Z7BXSAkf1w55boiOgcheKokaC3RJHW0UBjfOqH1kutqGvdaMxHBdcMNYwdcY2bJzIsT8aDa4oi4HjXW0ccGmVVfZQPuuZYD6Sz881N33nE1x0OSDWhytriJyPkN)(5b1Zd88OrppiZ7BXSAkffZkT7goF959DJx9fnMivSUsT84nYKeSR25iKrSuLZF)8G65bEE0ONhK59TywnLIk7HnUHR5rJEEFlMvtPiy3W005rJEEFlMvtPO2kppWbb1q4GGSDWyMOulpqhaUduGcc(wmRMsHAcfIAOMGaRgamVc3ge8WKyyAbbumpzywPy1UPuJCKPw6GnysUJSAaW8A(6ZdY8(UXR(IgLoiiTEwgeCj2GCeYiwQY5VFEuV28OrpVVB8QVOrPdcsRNLbbxInihHmILQCEqpViFT5RpVVB8QVOrPdcsRNLbbxInihHmILQCEqpVRI881N336YjPOVHqNkk1YdMzyKvdaMxZdCqW8u2AqirQyDLA5XBKjjyxTZbkuORHAccSAaW8kCBqWdtIHPfeidZkfR2nLAKJm1shSbtYDKvdaMxZxF(vtXQDtPg5itT0bBWKChP0do1YGG5PS1GqIuX6k1YJ3itsWUANduOWAfQjiWQbaZRWTbbpmjgMwqW3nE1x0O0bbP1ZYGGlXgKJqgXsvopONxKNV(8Gm)Ib4STf3nhLIqgXsvopON)oZJg98OyEYWSsXDZrPiRgamVMh4GG5PS1GWI9jIrPwEa0ykqHcVtOMGaRgamVc3ge8WKyyAbbumpzywPy1UPuJCKPw6GnysUJSAaW8A(6ZdY8(UXR(IgLoiiTEwgeCj2GCeYiwQY5VFErEE0ON33nE1x0O0bbP1ZYGGlXgKJqgXsvopONxKV28OrpVVB8QVOrPdcsRNLbbxInihHmILQCEqpVRI881N336YjPOVHqNkk1YdMzyKvdaMxZdCqW8u2Aqq2o4dSPafkuKd1eey1aG5v42GGhMedtliqgMvkwTBk1ihzQLoydMK7iRgamVMV(8RMIv7MsnYrMAPd2Gj5osPhCQLbbZtzRbbz7GpWMcuOW7kutqW8u2Aqq6BhyQLhkPDoiWQbaZRWTbkqbHvtNkixfQjuiQHAccSAaW8kCBqWdtIHPfewnfTYwDhHmILQC(7NhupF959DJx9fnkDqqA9Smi4sSb5iKrSuLZd65xnfTYwDhHmILQmiyEkBniyLT6oqHcDnutqGvdaMxHBdcEysmmTGWQPOmR2B9GZnoczelv583ppOE(6Z77gV6lAu6GG06zzqWLydYriJyPkNh0ZVAkkZQ9wp4CJJqgXsvgempLTgeKz1ERhCUXbkuyTc1eey1aG5v42GGhMedtliSAk6OsYaG5JTTHtpLTgHmILQC(7NhupF959DJx9fnkDqqA9Smi4sSb5iKrSuLZd65xnfDujzaW8X22WPNYwJqgXsvgempLTgeCujzaW8X22WPNYwduOW7eQjiWQbaZRWTbbpmjgMwqy1u03qOtfLTgHmILQC(7NhupF959DJx9fnkDqqA9Smi4sSb5iKrSuLZd65xnf9ne6urzRriJyPkdcMNYwdc(gcDQOS1afOGWI3mhmfQjuiQHAccMNYwdcYkgJp42doiWQbaZRWTbkuORHAccMNYwdclwC7apiwz6dcSAaW8kCBGcfwRqnbbwnayEfUni4HjXW0ccMNsX8Hvgjz58GE(AfeKem9uOqudcMNYwdcEdJpMNYwp4usbbCkPJAiCqWAoqHcVtOMGaRgamVc3gewS0dZkkBniic8u2684usY53A48emvWmnpaE3eNnmoVazKCEdYZlnX8A(TgopaERH88cTdE(cytxvGqQyDLA58GIrMKGD1oFLiC3uQrMxi1shSbtYTlZ30odVKsE(wN33nE1x0GG5PS1GG3W4J5PS1doLuqaNs6OgcheiyQGz6iRWjD87ShCGcfkYHAccSAaW8kCBqW8u2AqWBy8X8u26bNskiGtjDudHdclgBU51HGPcMjzGcfExHAccSAaW8kCBqWdtIHPfeaz(vtrz7GpWMIu6bNA58Orp)QPyIuX6k1YJ3itsWUANpRMIu6bNA58Orp)QPy1UPuJCKPw6GnysUJu6bNA58apF95LTd(i3n4AEqpFTMhn65xnffNy(qwQuKsp4ulNhn65jdZkfL9LdTZhjZlzKvdaMxbbjbtpfke1GG5PS1GG3W4J5PS1doLuqaNs6OgcheKKrhcMkyMKbkuybqOMGaRgamVc3ge8WKyyAbbFlMvtPOML70zZ45RppiZJI5fBW0aG5ibtfmthzfoP5rJEEF34vFrJY2bFGnfHmILQCEqpVRxBE0ONhK5fBW0aG5ibtfmtNw55RpVVB8QVOrz7GpWMIqgXsvo)9ZtWubZuKqn67gV6lAeYiwQY5bEE0ONhK5fBW0aG5ibtfmth6spF959DJx9fnkBh8b2ueYiwQY5VFEcMkyMIKRrF34vFrJqgXsvopWZd88OrpVVfZQPuumR0UB481NhK5rX8InyAaWCKGPcMPJScN08OrpVVB8QVOXePI1vQLhVrMKGD1ohHmILQCEqpVRxBE0ONhK5fBW0aG5ibtfmtNw55RpVVB8QVOXePI1vQLhVrMKGD1ohHmILQC(7NNGPcMPiHA03nE1x0iKrSuLZd88OrppiZl2GPbaZrcMkyMo0LE(6Z77gV6lAmrQyDLA5XBKjjyxTZriJyPkN)(5jyQGzksUg9DJx9fnczelv58appWZJg98GmVVfZQPuuzpSXnCnpA0Z7BXSAkfb7gMMopA0Z7BXSAkf1w55bE(6ZdY8OyEXgmnayosWubZ0rwHtAE0ON33nE1x0y1UPuJCKPw6GnysUJqgXsvopON31RnpA0ZdY8InyAaWCKGPcMPtR881N33nE1x0y1UPuJCKPw6GnysUJqgXsvo)9ZtWubZuKqn67gV6lAeYiwQY5bEE0ONhK5fBW0aG5ibtfmth6spF959DJx9fnwTBk1ihzQLoydMK7iKrSuLZF)8emvWmfjxJ(UXR(IgHmILQCEGNh45rJEEumpzywPy1UPuJCKPw6GnysUJSAaW8A(6ZdY8OyEXgmnayosWubZ0rwHtAE0ON33nE1x0O0bbP1ZYGGlXgKJqgXsvopON31RnpA0ZdY8InyAaWCKGPcMPtR881N33nE1x0O0bbP1ZYGGlXgKJqgXsvo)9ZtWubZuKqn67gV6lAeYiwQY5bEE0ONhK5fBW0aG5ibtfmth6spF959DJx9fnkDqqA9Smi4sSb5iKrSuLZF)8emvWmfjxJ(UXR(IgHmILQCEGNh4GG5PS1GG3W4J5PS1doLuqaNs6OgchewgIvYhcMkyMKbkuiOoutqGvdaMxHBdcMNYwdcigM3s)bAvKdKdclw6HzfLTgeU1bQZlBh88YDdUKZNBZVLL708PCEdJ0sA(wmddcEysmmTGaGwkNV(8Bz5oDGmILQC(7NNrz27q8HseE(AZ8Y2bFK7gCnF95xnfDujzaW8X22WPNYwJu6bNAzGcfEDd1eey1aG5v42GWILEywrzRbHc028(wmRMsZVA6kr4UPuJmVqQLoydMK75t58qhvtT0L5DK883TbbxInipp1ZZOmX6AEANN37aHSsZlzkiyEkBni4nm(yEkB9Gtjfe8WKyyAbbqM33Iz1ukkMvA3nC(6ZVAkMivSUsT84nYKeSR25ZQPiLEWPwoF959DJx9fnkDqqA9Smi4sSb5iKrSuLZF)8UoF95bz(vtXQDtPg5itT0bBWKChHmILQCEqpVRZJg98OyEYWSsXQDtPg5itT0bBWKChz1aG518appWZJg98GmVVfZQPuuZYD6Sz881NF1uu2o4dSPiLEWPwoF959DJx9fnkDqqA9Smi4sSb5iKrSuLZF)8UoF95bz(vtXQDtPg5itT0bBWKChHmILQCEqpVRZJg98OyEYWSsXQDtPg5itT0bBWKChz1aG518appWZJg98GmpiZ7BXSAkfv2dBCdxZJg98(wmRMsrWUHPPZJg98(wmRMsrTvEEGNV(8RMIv7MsnYrMAPd2Gj5osPhCQLZxF(vtXQDtPg5itT0bBWKChHmILQC(7N315boiGtjDudHdcldcUeBq(ub5Qafke1RfQjiWQbaZRWTbHfl9WSIYwdcfqEdYY95xnjNNni298528LDQLZNk1ZBZl3n4AEzfRRulNVA3KCqW8u2AqWBy8X8u26bNski4HjXW0ccGmVVfZQPuuZYD6Sz881NhfZVAkkBh8b2uKsp4ulNV(8(UXR(IgLTd(aBkczelv583p)DMh45rJEEqM33Iz1ukkMvA3nC(6ZJI5xnftKkwxPwE8gzsc2v78z1uKsp4ulNV(8(UXR(IgtKkwxPwE8gzsc2v7CeYiwQY5VF(7mpWZJg98GmpiZ7BXSAkfv2dBCdxZJg98(wmRMsrWUHPPZJg98(wmRMsrTvEEGNV(8KHzLIv7MsnYrMAPd2Gj5oYQbaZR5RppkMF1uSA3uQroYulDWgmj3rk9GtTC(6Z77gV6lASA3uQroYulDWgmj3riJyPkN)(5VZ8aheWPKoQHWbHvtNkixfOqHOIAOMGaRgamVc3gempLTgewge8r2o4GWILEywrzRbHc028IWDtPgzEHulDWgmj3ZNY5P0do1sxMpP5t58sBJNN65DK883TbbpVq7GdcEysmmTGWQPy1UPuJCKPw6GnysUJu6bNAzGcfIQRHAccSAaW8kCBqWdtIHPfeqX8KHzLIv7MsnYrMAPd2Gj5oYQbaZR5RppiZVAkkBh8b2uKsp4ulNhn65xnftKkwxPwE8gzsc2v78z1uKsp4ulNh4GG5PS1GWYGGpY2bhOqHOwRqnbbwnayEfUniyEkBniuTBk1ihzQLoydMK7GWILEywrzRbbb3QFEr4UPuJmVqQLoydMK75VK0(8xhyL2DdVQWSCNMVamJN33Iz1uA(vtUmFt7m8sk55DK88ToVVB8QVOX5lqBZxGHu5gYgEEqv4sn1ZZdWzBB(uoFQ(gj1sxMFVXR5DukXZNKOY5HSTCppiOcQNxY(wxY5TnIHZ7izGdcEysmmTGGVfZQPuuZYD6Sz881NNseEEqpVipF959DJx9fnkBh8b2ueYiwQY5VFEuNV(8GmVVB8QVOrgPYnKn8PHl1uphHmILQC(7Nh17Y15rJEEumpF9ozvfVImsLBiB4tdxQPEEEGduOquVtOMGaRgamVc3ge8WKyyAbbFlMvtPOywPD3W5RppLi88GEErE(6Z77gV6lAmrQyDLA5XBKjjyxTZriJyPkN)(5rD(6ZdY8(UXR(IgzKk3q2WNgUut9CeYiwQY5VFEuVlxNhn65rX8817Kvv8kYivUHSHpnCPM655boiyEkBniuTBk1ihzQLoydMK7afkevroutqGvdaMxHBdcEysmmTGaiZ7BXSAkfv2dBCdxZJg98(wmRMsrWUHPPZJg98(wmRMsrTvEEGNV(8GmVVB8QVOrgPYnKn8PHl1uphHmILQC(7Nh17Y15rJEEumpF9ozvfVImsLBiB4tdxQPEEEGdcMNYwdcv7MsnYrMAPd2Gj5oqHcr9Uc1eey1aG5v42GGhMedtliaOLY5Rp)wwUthiJyPkN)(5r9UccMNYwdcv7MsnYrMAPd2Gj5oqHcrTaiutqGvdaMxHBdclw6HzfLTgekqBZlc3nLAK5fsT0bBWKCpFkNNsp4ulDz(KevopLi88upVJKNVPDgopIvaQHZVAsgempLTge8ggFmpLTEWPKccEysmmTGWQPy1UPuJCKPw6GnysUJu6bNA581NhK59TywnLIAwUtNnJNhn659TywnLIIzL2DdNh4GaoL0rneoi4BXSAkfOqHOcQd1eey1aG5v42GG5PS1GGv2Q7GGhMedtliSAkALT6oczelv583p)DccE3EmFidwYKmuiQbkuiQx3qnbbZtzRbHDZrPGaRgamVc3gOqHUETqnbbwnayEfUniyEkBniizED6TJVHqNkkBniSyPhMvu2AqqOVmpTZZlW8soFRZxR5jdwYKC(CB(KMpLQO08EhiKvc7E(uNFdNL708nC(wNN255jdwYuCEqLK2NxiR2BDEuk345tsu58gw2ZdGjIHZt98osEEbMxZ3Iz48iM6yyS75TQkS7ulNVwZdkne6urzRYyqWdtIHPfempLI5dRmsYY5b98UoF95jdZkfL9LdTZhjZlzKvdaMxZxFEum)QPOK51P3o(gcDQOS1iLEWPwoF95rX8PE2Wz5ofOqHUIAOMGaRgamVc3ge8WKyyAbbZtPy(WkJKSCEqpVRZxFEYWSsrzwT36bNBCKvdaMxZxFEum)QPOK51P3o(gcDQOS1iLEWPwoF95rX8PE2Wz5onF95xnf9ne6urzRriJyPkN)(5VtqW8u2AqqY860BhFdHovu2AGcf6QRHAccSAaW8kCBqWdtIHPfeazEz7GpYDdUMh0ZJ68OrpV5PumFyLrswopON315bE(6Z77gV6lAu6GG06zzqWLydYriJyPkNh0ZJQRbbZtzRbbXjMpKLkfOqHUwRqnbbwnayEfUni4HjXW0ccMNsX8z1u0rLKbaZhBBdNEkBD(IZFT5rJEEk9GtTC(6ZVAk6OsYaG5JTTHtpLTgHmILQC(7N)obbZtzRbbhvsgamFSTnC6PS1afk017eQjiWQbaZRWTbbZtzRbbzwT36bNBCqWdtIHPfewnfLz1ERhCUXriJyPkN)(5VtqW72J5dzWsMKHcrnqHcDvKd1eey1aG5v42GGhMedtliGI59TywnLIk7HnUHRGGKGPNcfIAqW8u2AqWBy8X8u26bNskiGtjDudHdc(wmRMsbkuOR3vOMGaRgamVc3gempLTge8ne6urzRbbVBpMpKblzsgke1GGhMedtliyEkfZhwzKKLZF)83z(AFEqMNmmRuu2xo0oFKmVKrwnayEnpA0ZtgMvkkZQ9wp4CJJSAaW8AEGNV(8RMI(gcDQOS1iKrSuLZF)8UgewS0dZkkBniicQQWUNhuAi0PIYwNhXuhdJDpFRZJAT768Kblzs6Y8nC(wNVwZFjP95fbaKn2H45bLgcDQOS1afk01cGqnbbwnayEfUniyEkBniGyyEl9hOvroqoiSyPhMvu2AqqeSrmCEANNVRyLHUmVSI11828YDdUM)YoRZB08I88ToFT1W8w6NVaAvKdKNN65nXDUMVfZqVvvLAzqWdtIHPfeKTd(i3n4AEqp)DMV(8uIWZd65Df1afk0vqDOMGaRgamVc3gewS0dZkkBniaQSZ68AtZlDR(ulNxeUBk1iZlKAPd2Gj5EEQN)6aR0UB4vfML708fGzSlZl4GG0683TbbxInipFUnVHXZVAsoVb55TQkCYRGG5PS1GG3W4J5PS1doLuqWdtIHPfeazEFlMvtPOywPD3W5RppkMNmmRuSA3uQroYulDWgmj3rwnayEnF95xnftKkwxPwE8gzsc2v78z1uKsp4ulNV(8(UXR(IgLoiiTEwgeCj2GCeY2Y98appA0ZdY8(wmRMsrnl3PZMXZxFEumpzywPy1UPuJCKPw6GnysUJSAaW8A(6ZVAkkBh8b2uKsp4ulNV(8(UXR(IgLoiiTEwgeCj2GCeY2Y98appA0ZdY8GmVVfZQPuuzpSXnCnpA0Z7BXSAkfb7gMMopA0Z7BXSAkf1w55bE(6Z77gV6lAu6GG06zzqWLydYriBl3ZdCqaNs6OgchewgeCj2G8PcYvbkuORx3qnbbwnayEfUniyEkBniSmi4JSDWbHfl9WSIYwdcxNsE(72GGNxODWZNBZF3geCj2G88xAvuAEa88q2wUN3kTuDz(goFUnpTZqE(ljgppaEEJMhZMKM315rAip)DBqWLydYZ7izzqWdtIHPfea0s581N33nE1x0O0bbP1ZYGGlXgKJqgXsvopONFll3PdKrSuLZxFEqMhfZtgMvkwTBk1ihzQLoydMK7iRgamVMhn659DJx9fnwTBk1ihzQLoydMK7iKrSuLZd653YYD6azelv58ahOqH16AHAccSAaW8kCBqWdtIHPfea0s581NhfZtgMvkwTBk1ihzQLoydMK7iRgamVMV(8(UXR(IgLoiiTEwgeCj2GCeYiwQY5VzEF34vFrJsheKwpldcUeBqoUCGgLTo)9ZVLL70bYiwQYGG5PS1GWYGGpY2bhOqH1c1qnbbwnayEfUniSyPhMvu2AqaumYVx7ggpFsmY8osRKNFRHZBQBAp1Y51MMxwX(Cl518mwYx2zihempLTge8ggFmpLTEWPKcc4ush1q4GqsmsGcfwlxd1eey1aG5v42GGhMedtliqgMvkk3TvF5WiaGMNJSAaW8A(6ZdY8lgGZ2wuUBR(YHraanphLK5bp)9ZdY8UoFTpV5PS1OC3w9LdGgtXupB4SCNMh45rJE(fdWzBlk3TvF5WiaGMNJqgXsvo)9ZxR5boiyEkBni4nm(yEkB9GtjfeWPKoQHWbbjhOqH1QwHAccSAaW8kCBqW8u2AqaXW8w6pqRICGCqyXspmROS1GW1PKNV2AyEl9ZxaTkYbYZFzN15rScqnC(vtY5nipVtLlZ3W5ZT5PDgYZFjX45bWZlZsn3sVP08uIWZ7OuINN255vgLP5fH7MsnY8cPw6GnysUJZxG2M3HsCwGl1Y5RTgM3s)8GkqJ2Dz(9gVM3MxUBW18uppK3GSCFEANNhGZ2wqWdtIHPfeaz(vtrXjMpKLkfP0do1Y5rJE(vtXePI1vQLhVrMKGD1oFwnfP0do1Y5rJE(vtrz7GpWMIu6bNA58apF95bzEump0r5TgwYredZBP)CbA0EKvdaMxZJg98aC22IigM3s)5c0O9OKmp45VF(AnpA0ZlBh8rUBW18GEEuNh4afkSw3jutqGvdaMxHBdcMNYwdcigM3s)bAvKdKdclw6HzfLTgeUoL881wdZBPF(cOvroqEEQNhXsLSuNN255rmmVL(5VanAFEaoBBZ7OuINxUBWLCEL518uppaE(swzOr8A(TgopTZZRmktZdWbkP5VK6QVmpiUET5LSV1LC(uopsd55PDtNx6STL(KvAEQNVKvgAepFTMxUBWLe4GGhMedtliaDuERHLCeXW8w6pxGgThz1aG5181N33nE1x0OSDWhytriJyPkNh0Z761MV(8aC22IigM3s)5c0O9iKrSuLZF)83jqHcRLihQjiWQbaZRWTbbZtzRbbedZBP)aTkYbYbHfl9WSIYwdcxNsE(ARH5T0pFb0QihipFRZlc3nLAK5fsT0bBWKCpV3KK0L5rmWPwoV0bYZt98stmpVnVC3GR5PEEjzEWZxBnmVL(5bvGgTpFUnVJm1Y5tki4HjXW0ccKHzLIv7MsnYrMAPd2Gj5oYQbaZR5RppiZVAkwTBk1ihzQLoydMK7iLEWPwopA0Z77gV6lASA3uQroYulDWgmj3riJyPkNh0Z7QippA0ZdOLY5RppLi8H6Zk55VFEF34vFrJv7MsnYrMAPd2Gj5oczelv58apF95bzEump0r5TgwYredZBP)CbA0EKvdaMxZJg98aC22IigM3s)5c0O9OKmp45VF(AnpA0ZlBh8rUBW18GEEuNh4afkSw3vOMGaRgamVc3ge8WKyyAbbYWSsrzF5q78rY8sgz1aG5vqW8u2AqaXW8w6pqRICGCGcfwRcGqnbbwnayEfUniyEkBniSGwQhCUXbHfl9WSIYwdc3n0sDEuk345t58TIDpVn)DlcfMV0sD(ljTpFbszXjzaW883nJKsEELn48igkpVKmpyzC(c028Bz5onFkN3a0o08uppRR5x98AtZJKs58YkwxPwopTZZljZdwge8WKyyAbbaoBBXuzXjzaW8zXiPKJsY8GNh0ZFNRnpA0ZdWzBlMklojdaMplgjLC0PA(6ZdOLY5Rp)wwUthiJyPkN)(5VtGcfwlqDOMGaRgamVc3gempLTge8ggFmpLTEWPKcc4ush1q4GGVfZQPuGcfwRRBOMGaRgamVc3gempLTgeSYwDhe8WKyyAbbiVbz5UbaZbbVBpMpKblzsgke1afk8oxlutqGvdaMxHBdcEysmmTGG5PumFwnfDujzaW8X22WPNYwNV48xBE0ONNsp4ulNV(8qEdYYDdaMdcMNYwdcoQKmay(yBB40tzRbku4DqnutqGvdaMxHBdcMNYwdcYSAV1do34GGhMedtlia5nil3nayoi4D7X8HmyjtYqHOgOqH3X1qnbbwnayEfUniyEkBni4Bi0PIYwdcEysmmTGaK3GSC3aG55RpV5PumFyLrswo)9ZFN5R95bzEYWSsrzF5q78rY8sgz1aG518OrppzywPOmR2B9GZnoYQbaZR5boi4D7X8HmyjtYqHOgOqH3PwHAccPsme6urbbudcMNYwdclOL6r2o4GaRgamVc3gOqH35oHAccMNYwdcYDB1xoaAmfey1aG5v42afOGqfK9ncaJc1eke1qnbbwnayEfUni4HjXW0ccuIWZd65V281NhfZxXu0WPyE(6ZJI5b4STflHjsNq(0BhP5H5w65OtvqW8u2AqyJXNvJKQrzRbkuORHAccMNYwdcsheKwpBmE3rjggey1aG5v42afkSwHAccSAaW8kCBqWdtIHPfeidZkflHjsNq(0BhP5H5w65iRgamVccMNYwdcLWePtiF6TJ08WCl9CGcfENqnbbwnayEfUni0vbbjtbbZtzRbbXgmnayoii2WoCqW8ukMpRMI(gcDQOS15b98xB(6ZBEkfZNvtrRSv3Zd65V281N38ukMpRMIoQKmay(yBB40tzRZd65V281NhK5rX8KHzLIYSAV1do34iRgamVMhn65npLI5ZQPOmR2B9GZnEEqp)1Mh45RppiZVAkwTBk1ihzQLoydMK7iLEWPwopA0ZJI5jdZkfR2nLAKJm1shSbtYDKvdaMxZdCqqSbpQHWbHvtYdKTL7afkuKd1eey1aG5v42GGAiCqWkWj3nOjpBTsNE7u1xyyqW8u2AqWkWj3nOjpBTsNE7u1xyyGcfExHAccSAaW8kCBqW8u2AqqY860BhFdHovu2AqWdtIHPfeKvmgFidwYKmkzED6TJVHqNkkB9ynppOloFTcc4u5JFfeq9AbkuybqOMGG5PS1GWU5OuqGvdaMxHBduOqqDOMGG5PS1GGJkjdaMp22go9u2AqGvdaMxHBduGccwZHAcfIAOMGG5PS1Gq1UPuJCKPw6GnysUdcSAaW8kCBGcf6AOMGG5PS1GWU5OuqGvdaMxHBduOWAfQjiWQbaZRWTbbpmjgMwqW3Iz1ukkMvA3nC(6ZVAkMivSUsT84nYKeSR25ZQPiLEWPwoF959DJx9fnkDqqA9Smi4sSb5iKTL75RppiZVAkwTBk1ihzQLoydMK7iKrSuLZd65DDE0ONhfZtgMvkwTBk1ihzQLoydMK7iRgamVMh45rJEEFlMvtPOML70zZ45Rp)QPOSDWhytrk9GtTC(6Z77gV6lAu6GG06zzqWLydYriBl3ZxFEqMF1uSA3uQroYulDWgmj3riJyPkNh0Z768OrppkMNmmRuSA3uQroYulDWgmj3rwnayEnpWZJg98GmVVfZQPuuzpSXnCnpA0Z7BXSAkfb7gMMopA0Z7BXSAkf1w55bE(6ZVAkwTBk1ihzQLoydMK7iLEWPwoF95xnfR2nLAKJm1shSbtYDeYiwQY5VFExdcMNYwdcEdJpMNYwp4usbbCkPJAiCqyzqWLydYNkixfOqH3jutqGvdaMxHBdcEysmmTGazywPOSVCOD(izEjJSAaW8A(6Z7n9izEfempLTgeKmVo92X3qOtfLTgOqHICOMGaRgamVc3ge8WKyyAbbumpzywPOSVCOD(izEjJSAaW8A(6ZJI5xnfLmVo92X3qOtfLTgP0do1Y5RppkMp1Zgol3P5Rp)QPOVHqNkkBnc5nil3nayoiyEkBniizED6TJVHqNkkBnqHcVRqnbbwnayEfUniyEkBniyLT6oi4HjXW0ccMNsX8z1u0kB1983p)DMV(8Oy(vtrRSv3rk9GtTmi4D7X8HmyjtYqHOgOqHfaHAccSAaW8kCBqW8u2AqWkB1DqWdtIHPfempLI5ZQPOv2Q75bDX5VZ81NhYBqwUBaW881NF1u0kB1DKsp4uldcE3EmFidwYKmuiQbkuiOoutqGvdaMxHBdcEysmmTGG5PumFwnfDujzaW8X22WPNYwNV48xBE0ONNsp4ulNV(8qEdYYDdaMdcMNYwdcoQKmay(yBB40tzRbku41nutqGvdaMxHBdcMNYwdcoQKmay(yBB40tzRbbpmjgMwqafZtPhCQLZxF(kXvKHzLIqdPYu6yBB40tzRYiRgamVMV(8MNsX8z1u0rLKbaZhBBdNEkBD(7NVwbbVBpMpKblzsgke1afke1RfQjiWQbaZRWTbbpmjgMwqq2o4JC3GR5b98OgempLTgeeNy(qwQuGcfIkQHAccSAaW8kCBqWdtIHPfeqX8(wmRMsrL9Wg3WvqqsW0tHcrniyEkBni4nm(yEkB9GtjfeWPKoQHWbbFlMvtPafkevxd1eey1aG5v42GGhMedtliaY8(wmRMsrXSs7UHZxFEqM33nE1x0yIuX6k1YJ3itsWUANJq2wUNhn65xnftKkwxPwE8gzsc2v78z1uKsp4ulNh45RpVVB8QVOrPdcsRNLbbxInihHSTCpF95bz(vtXQDtPg5itT0bBWKChHmILQCEqpVRZJg98OyEYWSsXQDtPg5itT0bBWKChz1aG518appWZxFEqMhK59TywnLIk7HnUHR5rJEEFlMvtPiy3W005rJEEFlMvtPO2kppWZxFEF34vFrJsheKwpldcUeBqoczelv583pVRZxFEqMF1uSA3uQroYulDWgmj3riJyPkNh0Z768OrppkMNmmRuSA3uQroYulDWgmj3rwnayEnpWZd88OrppiZ7BXSAkf1SCNoBgpF95bzEF34vFrJY2bFGnfHSTCppA0ZVAkkBh8b2uKsp4ulNh45RpVVB8QVOrPdcsRNLbbxInihHmILQC(7N315RppiZVAkwTBk1ihzQLoydMK7iKrSuLZd65DDE0ONhfZtgMvkwTBk1ihzQLoydMK7iRgamVMh45boiyEkBni4nm(yEkB9GtjfeWPKoQHWbHLbbxIniFQGCvGcfIATc1eey1aG5v42GGhMedtliaOLY5RpVVB8QVOrPdcsRNLbbxInihHmILQCEqp)wwUthiJyPkNV(8GmpkMNmmRuSA3uQroYulDWgmj3rwnayEnpA0Z77gV6lASA3uQroYulDWgmj3riJyPkNh0ZVLL70bYiwQY5boiyEkBniSmi4JSDWbkuiQ3jutqGvdaMxHBdcEysmmTGaGwkNV(8(UXR(IgLoiiTEwgeCj2GCeYiwQY5VzEF34vFrJsheKwpldcUeBqoUCGgLTo)9ZVLL70bYiwQYGG5PS1GWYGGpY2bhOqHOkYHAccSAaW8kCBqW8u2AqWBy8X8u26bNskiGtjDudHdcjXibkuiQ3vOMGaRgamVc3gempLTge8ggFmpLTEWPKcc4ush1q4GWIXMBEDiyQGzsgOqHOwaeQjiWQbaZRWTbbZtzRbbVHXhZtzRhCkPGaoL0rneoiSmeRKpemvWmjduOqub1HAccSAaW8kCBqWdtIHPfewnfR2nLAKJm1shSbtYDKsp4ulNhn65rX8KHzLIv7MsnYrMAPd2Gj5oYQbaZRGG5PS1GG3W4J5PS1doLuqaNs6OgcheKKrhcMkyMKbkuiQx3qnbbwnayEfUni4HjXW0ccRMIItmFilvksPhCQLbbZtzRbbedZBP)aTkYbYbkuORxlutqGvdaMxHBdcEysmmTGWQPOSDWhytrk9GtTC(6ZJI5jdZkfL9LdTZhjZlzKvdaMxbbZtzRbbedZBP)aTkYbYbkuOROgQjiWQbaZRWTbbpmjgMwqafZtgMvkkoX8HSuPiRgamVccMNYwdcigM3s)bAvKdKduOqxDnutqGvdaMxHBdcEysmmTGGSDWh5UbxZd65VtqW8u2AqaXW8w6pqRICGCGcf6ATc1eey1aG5v42GG5PS1GGmR2B9GZnoi4HjXW0ccMNsX8z1uuMv7TEW5gp)9fNVwZxFEiVbz5UbaZZxFEum)QPOmR2B9GZnosPhCQLbbVBpMpKblzsgke1afk017eQjiWQbaZRWTbbpmjgMwqW3Iz1ukQSh24gUccscMEkuiQbbZtzRbbVHXhZtzRhCkPGaoL0rneoi4BXSAkfOqHUkYHAccSAaW8kCBqWdtIHPfea4STftLfNKbaZNfJKsokjZdEEqxCEr(AZJg98aAPC(6ZdWzBlMklojdaMplgjLC0PA(6ZVLL70bYiwQY5VFErEE0ONhGZ2wmvwCsgamFwmsk5OKmp45bDX5RLipF95xnfLTd(aBksPhCQLbbZtzRbHf0s9GZnoqHcD9Uc1eesLyi0PIccOgempLTgewql1JSDWbbwnayEfUnqHcDTaiutqW8u2AqqUBR(YbqJPGaRgamVc3gOafeKKrhcMkyMKHAcfIAOMGaRgamVc3geudHdcPk9qhYaG5Z17yk5GCwS40ZbbZtzRbHuLEOdzaW856DmLCqolwC65afk01qnbbwnayEfUniOgchesvsqhp1q5zLItLpaymoiyEkBniKQKGoEQHYZkfNkFaWyCGcfwRqnbbwnayEfUniOgcheAXmCd3xsT8yAIyhVvYbbZtzRbHwmd3W9LulpMMi2XBLCGcfENqnbbwnayEfUniOgchewgems36zXEWNkhcYspREoiyEkBniSmiyKU1ZI9GpvoeKLEw9CGcfkYHAccSAaW8kCBqqneoiGyEdaKpYDMPdIJm9bbZtzRbbeZBaG8rUZmDqCKPpqHcVRqnbbwnayEfUniOgche2WgcF6TdaJimhempLTge2WgcF6TdaJimhOqHfaHAccSAaW8kCBqqneoiCXaZkdLNnyRRGG5PS1GWfdmRmuE2GTUcuOqqDOMGaRgamVc3geudHdcKbaZ0P3olwwzjmiyEkBniqgamtNE7SyzLLWafk86gQjiWQbaZRWTbb1q4GGm1nh8XKvj0usEayRs(0BNng2(KChempLTgeCK8jjgjqHcr9AHAccSAaW8kCBqqneoiitDZbFkX2knQHYdaBvYNE7SXW2NK7GG5PS1GGJKpjXibkuiQOgQjiyEkBniaa396S5aDhey1aG5v42afkevxd1eempLTge2sida39kiWQbaZRWTbkuiQ1kutqW8u2AqaadLmeCQLbbwnayEfUnqbkii5qnHcrnutqW8u2Aqy3CukiWQbaZRWTbkuORHAccSAaW8kCBqivIHqNk6KBbHfdWzBlk3TvF5WiaGMNJsY8GbDXAfempLTgewql1JSDWbHujgcDQOtjUby4GaQbkuyTc1eempLTgeK72QVCa0ykiWQbaZRWTbkqbHKyKqnHcrnutqW8u2AqWrYNKyezqGvdaMxHBduGcuGcuia]] )


end