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


    spec:RegisterPack( "Affliction", 20211207, [[da13ZcqiqvTiqeOhbLInPs8jOKrbkofi1QujjEfi0SOQ4wsr0Ue6xQKAyGOCmqLLrvvptLettksxJQsSnqu5BQKKghiQ6CuvsADqP08aLCpLI9bQYbHsvwii4HGinrqeDrOurBKQsI(iuQaNukcwji5LqPcYmbLYnHsvTtQQ8tqeAOqPslLQsQNcvtvkQRcIG2kuQqFvkcnwQk1Ef8xvmyvDyklwL6XuzYk5YiBwQ8zP0OvQoTOvtvjHxdjZgLBdXUj9BjdxQ64QKulh45OA6exNQSDO47kLgpOuDEPW6braZhsDFOub1(vCaUqZb8LjuWp)Hm)Hdo)HSRA0)R4pK3x8pGln6PaEV5qzTuaxnekGJ966yPtYsd49wdwzRqZbCE5bCuaFxKEo2E91TPS7DhDfY18eXJzswQdyDY18eXDDa)2lzstqd3b8LjuWp)Hm)Hdo)HSRA0)R4pKVP(QbCEp5c(5pKZxc475ArA4oGViUlGJ966yPtYsNVjAaw5qnq5xHHqUjW8WDfFM3FiZF4gOgOG0DtBjo2oq1KZJ9wlAnpEpXyZdBLdvCGQjNh7Tw0AEijHP8aZJ9T20fhOAY5XERfTM)gqgk3UPkXMNvTPB(UcmpKeyPopE5XIdun58nVLmuZJ9ng1LU591wV4bO5zvB6MxQ53wauZNDZ3O8WcqZJKCEQTZBZlgJuz(uNx2nzEqTnoq1KZJDQ2nJM3xBi9MkZJ966yPtYs5ZJDXGDNxmgPsCGQjNV5TKHIpVuZByQCn)nR2MA78qsdGQLzaA(uNhXJjztkgOLK53EDnpKesSz(8E9XbQMCEiT0fPCAEEHqZdjnaQwMbO5XUaQFENXy85LAEaT8C08UcP3tmjlDEjrO4avtopojZZleAENXyhZjzPhwYL5jvajXNxQ55ciDY8snVHPY18UDYHk125zjx4Zl7Mm)2sXsM)MMhqMBNwZdJ1APcFOJdun58qIkRX84eTMVuhnFpGAYEpgloq1KZJ9w(k84Y8qcE7b05HuijF(BQRa08KUMV6MVlB3fibNNvTPBEPM367znMVuwJ5LA(7IZNVlB3f(8WOLmVam((89Mdfh64avtoVVsgX3DaRtUg7yXmjz084fddPY8otDe7KDZ72nTLwZl18Pkea41lNSlgW7bvxYOao2GnZJ966yPtYsNVjAaw5qnqHnyZ8(vyiKBcmpCxXN59hY8hUbQbkSbBMhs3nTL4y7af2GnZ3KZJ9wlAnpEpXyZdBLdvCGcBWM5BY5XERfTMhssykpW8yFRnDXbkSbBMVjNh7Tw0A(BazOC7MQeBEw1MU57kW8qsGL684LhloqHnyZ8n58nVLmuZJ9ng1LU591wV4bO5zvB6MxQ53wauZNDZ3O8WcqZJKCEQTZBZlgJuz(uNx2nzEqTnoqHnyZ8n58yNQDZO591gsVPY8yVUow6KSu(8yxmy35fJrQehOWgSz(MC(M3sgk(8snVHPY183SABQTZdjnaQwMbO5tDEepMKnPyGwsMF7118qsiXM5Z71hhOWgSz(MCEiT0fPCAEEHqZdjnaQwMbO5XUaQFENXy85LAEaT8C08UcP3tmjlDEjrO4af2GnZ3KZJtY88cHM3zm2XCsw6HLCzEsfqs85LAEUasNmVuZByQCnVBNCOsTDEwYf(8YUjZVTuSK5VP5bK52P18WyTwQWh64af2GnZ3KZdjQSgZJt0A(sD089aQj79yS4af2GnZ3KZJ9w(k84Y8qcE7b05HuijF(BQRa08KUMV6MVlB3fibNNvTPBEPM367znMVuwJ5LA(7IZNVlB3f(8WOLmVam((89Mdfh64af2GnZ3KZ7RKr8DhW6KRXowmtsgnpEXWqQmVZuhXoz38UDtBP18snFQcbaE9Yj7IduduMtYs5XEa5kKBt20rSZQqs1KSuFYUnsIqWdYUa)EsIglXqxG)TxxxSfKivcOt1D4MdKDPJIE9duMtYs5XEa5kKBtG4MR5EiiLE6jzGYCswkp2dixHCBce3CThNoPqi(OgcTrke6uDhKs5cO84hxPCb45KSu(aL5KSuEShqUc52eiU5ApoDsHq8rneAdVyKTZpCYbi5iKBxZR2JgOmNKLYJ9aYvi3MaXnx3csKkb0P6oCZbYU0r(KDBeJrQeBbjsLa6uDhU5azx6OiP2nJwduMtYs5XEa5kKBtG4MR7yeF3bSozGYCswkp2dixHCBce3CngdK2nJ8rneAZQe(bq2QHpymMhTXCsIHoRsIUca86LSu4bzxmNKyOZQKO1wAd4bzxmNKyOZQKONYf7MrhRRJLojlfEq2fyGVymsLip73l9WYoksQDZOfA0Mtsm0zvsKN97LEyzhbpid6lWSkj2VBQuihEQTEmdKsJOKouP2Ign8fJrQe73nvkKdp1wpMbsPrKu7MrlOhOmNKLYJ9aYvi3MaXnx7XPtkeIpQHqBmib47gW4NUsLt1D6RTeyGYCswkp2dixHCBce3CnNO1P6oUca86LSuFyPsh3AdCqMpz3gEpXyhXaTKWJCIwNQ74kaWRxYspwrWBZvgOmNKLYJ9aYvi3MaXnxVBEQmqzojlLh7bKRqUnbIBU2t5IDZOJ11XsNKLoqnqHnyZ8yNWo58eAnpHHanMxseAEzNM3CsbMp5ZBySKz3mkoqzojlLVH3tm2HvouduMtYs5qCZ1lct5boiwB6gOmNKLYH4MRDgJDmNKLEyjx8rneAJvKpCbKozdC(KDBmNKyOdPessC4DLbkSzESNtYsNNLCHpFxbMxaPIIK5VPDdtwG484Ij85nanp3WqR57kW83uxbO5Xlp28(6sUUjG0t6k125HutmUaQ(D6AS7UPsHmpEQTEmdKsdFMVKDcSn508LoVRk2Q2QXbkZjzPCiU5ANXyhZjzPhwYfFudH2iGurrYH3Zs542jhQbkZjzPCiU5ANXyhZjzPhwYfFudH2SiM1GwhbKkks4duMtYs5qCZ1oJXoMtYspSKl(OgcTHlMCeqQOiH7dxaPt2aNpz3gywLe5Lh7akjkPdvQTOrVkjMi9KUsT94mX4cO63PZQKOKouP2Ig9QKy)UPsHC4P26XmqknIs6qLAl0x4Lh7W3nWcExbn6vjrmjJoILQeL0Hk1w0OfJrQe512JSthorl(aL5KSuoe3CTZySJ5KS0dl5IpQHqBwgI1shbKkks4(KDBCfgsnvIA2UlNoJUad8XyG0UzuuaPIIKdVNLcA0UQyRARg5Lh7akjcielvo88hYqJggmgiTBgffqQOi5ukDXvfBvB1iV8yhqjraHyPYHLasffjr4IUQyRARgbeILkhA0OHbJbs7MrrbKkksoY26IRk2Q2QrE5XoGsIacXsLdlbKkksI(hDvXw1wncielvo0qJgTRWqQPsedPYEdWfyGpgdK2nJIcivuKC49SuqJ2vfBvB1yI0t6k12JZeJlGQFNIacXsLdp)Hm0OHbJbs7MrrbKkksoLsxCvXw1wnMi9KUsT94mX4cO63PiGqSu5WsaPIIKiCrxvSvTvJacXsLdnA0WGXaPDZOOasffjhzBDXvfBvB1yI0t6k12JZeJlGQFNIacXsLdlbKkksI(hDvXw1wncielvo0qJgnmUcdPMkrLCGIvGfA0UcdPMkrunaPPOr7kmKAQe1sjOVad8XyG0UzuuaPIIKdVNLcA0UQyRARg73nvkKdp1wpMbsPreqiwQC45pKHgnmymqA3mkkGurrYPu6IRk2Q2QX(DtLc5WtT1JzGuAebeILkhwcivuKeHl6QITQTAeqiwQCOrJggmgiTBgffqQOi5iBRlUQyRARg73nvkKdp1wpMbsPreqiwQCyjGurrs0)ORk2Q2QraHyPYHgA0OHVymsLy)UPsHC4P26XmqknIKA3mADbg4JXaPDZOOasffjhEplf0ODvXw1wnY9qqk9SmaQwMbOiGqSu5WZFidnAyWyG0UzuuaPIIKtP0fxvSvTvJCpeKspldGQLzakcielvoSeqQOijcx0vfBvB1iGqSu5qJgnmymqA3mkkGurrYr2wxCvXw1wnY9qqk9SmaQwMbOiGqSu5WsaPIIKO)rxvSvTvJacXsLdn0duyZ8qWdOZZlp288DdS4ZNDZ3LT7Y8jFEJHuCz(cdbgOmNKLYH4MRrmg1LUdW6fpa5t2T5U48lDz7UCaeILkhweStopHosIqxfE5Xo8DdSUSkj6PCXUz0X66yPtYsJs6qLA7af2mFtOBExHHutL5xLCn2D3uPqMhp1wpMbsPX8jFEGNQP26Z8ECAEiPbq1YmanVuZtWUq6AEzNM35baKkZZjzGYCswkhIBU2zm2XCsw6HLCXh1qOnldGQLza60dOEFYUnW4kmKAQeXqQS3aCzvsmr6jDLA7XzIXfq1VtNvjrjDOsT9IRk2Q2QrUhcsPNLbq1YmafbeILkhw(FbMvjX(DtLc5WtT1JzGuAebeILkhE(Jgn8fJrQe73nvkKdp1wpMbsPb0qJgnmUcdPMkrnB3LtNrxwLe5Lh7akjkPdvQTxCvXw1wnY9qqk9SmaQwMbOiGqSu5WY)lWSkj2VBQuihEQTEmdKsJiGqSu5WZF0OHVymsLy)UPsHC4P26XmqknGgA0OHbgxHHutLOsoqXkWcnAxHHutLiQgG0u0ODfgsnvIAPe0xwLe73nvkKdp1wpMbsPrushQuBVSkj2VBQuihEQTEmdKsJiGqSu5WYFOhOWM591uhG47ZVkHppzawJ5ZU5BRuBNpvPM3MNVBG188EsxP2oF)UXPbkZjzPCiU5ANXyhZjzPhwYfFudH2Sk50dOEFYUnW4kmKAQe1SDxoDgDb(RsI8YJDaLeL0Hk12lUQyRARg5Lh7akjcielvoSAk0OrdJRWqQPsedPYEdWf4VkjMi9KUsT94mX4cO63PZQKOKouP2EXvfBvB1yI0t6k12JZeJlGQFNIacXsLdRMcnA0WaJRWqQPsujhOyfyHgTRWqQPsevdqAkA0UcdPMkrTuc6lIXivI97MkfYHNARhZaP04c8xLe73nvkKdp1wpMbsPrushQuBV4QITQTASF3uPqo8uB9ygiLgraHyPYHvtHEGcBMVj0np2D3uPqMhp1wpMbsPX8jFEjDOsT1N5tz(Kpp36O5LAEponpK0aOMhV8yduMtYs5qCZ1ldG6WlpMpz3MvjX(DtLc5WtT1JzGuAeL0Hk12bkZjzPCiU56LbqD4LhZNSBd8fJrQe73nvkKdp1wpMbsPXfywLe5Lh7akjkPdvQTOrVkjMi9KUsT94mX4cO63PZQKOKouP2c9af2mpEd1np2D3uPqMhp1wpMbsPX8BtzFESJKk7nax7x2UlZ7R0O5DfgsnvMFvIpZxYob2MCAEponFPZ7QITQTAC(Mq38yNi9naKXMhseSutD083EDDZN85t1viP26Z87fBnVNkjB(uWIppGSvJ5Hboi)8CYv6IpV1jeyEpob9aL5KSuoe3CD)UPsHC4P26Xmqkn8j724kmKAQe1SDxoDgDrsecE(YfxvSvTvJ8YJDaLebeILkhwWDbgbKkksIesFdazStbwQPok6QITQTAeqiwQCybhKZF0OHpD1EzFpTIesFdazStbwQPoc6bkZjzPCiU56(DtLc5WtT1JzGuA4t2TXvyi1ujIHuzVb4IKie88LlUQyRARgtKEsxP2ECMyCbu97ueqiwQCyb3fyeqQOijsi9naKXofyPM6OORk2Q2QraHyPYHfCqo)rJg(0v7L990ksi9naKXofyPM6iOhOWM59JCGIvG18BtzFESVXOU0nFteyY(8oJl8573nvkK55P26XmqknMp15zPsZVnL95HKKlrmj125HqXKbkZjzPCiU56(DtLc5WtT1JzGuA4t2TXvyi1ujQKduScSUa8uQRaTueXyux6oBbMSFrsecE(YfxvSvTvJlYLiMKA75UyseqiwQCyDLlWiGurrsKq6BaiJDkWsn1rrxvSvTvJacXsLdl4GC(Jgn8PR2l77PvKq6BaiJDkWsn1rqpqHnZdjk7eyExHHutf(8WKQJ5TsTDET0Me73eN3pYbkON3zCzESl(8LoVRk2Q2QduMtYs5qCZ197MkfYHNARhZaP0WNSBdmUcdPMkrunaPPOr7kmKAQe1sj0OHXvyi1ujQKduScSUaFGNsDfOLIigJ6s3zlWKDOH(cmcivuKejK(gaYyNcSutDu0vfBvB1iGqSu5WcoiN)OrdF6Q9Y(EAfjK(gaYyNcSutDe0duMtYs5qCZ197MkfYHNARhZaP0WNSBZDX5x6Y2D5aielvoSGdYnqHnZ3e6Mh7UBQuiZJNARhZaP0y(KpVKouP26Z8PGfFEjrO5LAEponFj7eyEeZxrbMFvcFGYCswkhIBU2zm2XCsw6HLCXh1qOnUcdPMk(Wfq6KnW5t2TzvsSF3uPqo8uB9ygiLgrjDOsT9cmUcdPMkrnB3LtNrOr7kmKAQeXqQS3aa9aL5KSuoe3CT1wAdFCnCm6igOLe(g48j72SkjATL2icielvoSA6aL5KSuoe3C9U5PYaf2mpETDEzNMhNOfF(sN)kZlgOLe(8z38PmFYvSK5DEaaPcRX8PoFhlB3L5lW8LoVStZlgOLK48nXu2Nhp73lDEyl7O5tbl(8gJxZFtIqG5LAEponporR5lmeyEet9mgRX8wFpRrQTZFL5H0ca86LSuECGYCswkhIBUMt06uDhxbaE9swQpz3gZjjg6qkHKehE(FrmgPsKxBpYoD4eT4xG)QKiNO1P6oUca86LS0OKouP2Eb(PE6yz7UmqzojlLdXnxZjADQUJRaaVEjl1NSBJ5KedDiLqsIdp)VigJujYZ(9spSSJUa)vjrorRt1DCfa41lzPrjDOsT9c8t90XY2D5YQKORaaVEjlncielvoSA6aL5KSuoe3CnMKrhXsv8j72adV8yh(UbwWdo0OnNKyOdPessC45p0xCvXw1wnY9qqk9SmaQwMbOiGqSu5Wdo)hOmNKLYH4MR9uUy3m6yDDS0jzP(KDBmNKyOZQKONYf7MrhRRJLojlDdKHgTKouP2Ezvs0t5IDZOJ11XsNKLgbeILkhwnDGYCswkhIBUMN97LEyzh5JRHJrhXaTKW3aNpz3MvjrE2Vx6HLDueqiwQCy10bkZjzPCiU5ANXyhZjzPhwYfFudH24kmKAQ4dxaPt2aNpz3g47kmKAQevYbkwbwduyZ8yV(EwJ5H0ca86LS05rm1ZySgZx68W1K(pVyGws4(mFbMV05VY8BtzFES3nVyEcnpKwaGxVKLoqzojlLdXnx7kaWRxYs9X1WXOJyGws4BGZNSBJ5KedDiLqsIdRM2KWigJujYRThzNoCIwC0OfJrQe5z)EPhw2rqFzvs0vaGxVKLgbeILkhw(pqHnZJ96ecmVStZx9KsaFMN3t6AEBE(UbwZVDN05nzEFz(sNh7BmQlDZ7RTEXdqZl18gMkxZxyiGZ67tTDGYCswkhIBUgXyux6oaRx8aKpz3gE5Xo8DdSGxtVijcbp)HBGcBMVjUt68AjZZBOUuBNh7UBQuiZJNARhZaP0yEPMh7iPYEdW1(LT7Y8(knYN5X9qqkDEiPbq1YmanF2nVXyZVkHpVbO5T(EwsRbkZjzPCiU5ANXyhZjzPhwYfFudH2SmaQwMbOtpG69j72aJRWqQPsedPYEdWf4lgJuj2VBQuihEQTEmdKsJlRsIjspPRuBpotmUaQ(D6SkjkPdvQTxCvXw1wnY9qqk9SmaQwMbOiGSvdOrJggxHHutLOMT7YPZOlWxmgPsSF3uPqo8uB9ygiLgxwLe5Lh7akjkPdvQTxCvXw1wnY9qqk9SmaQwMbOiGSvdOrJggyCfgsnvIk5afRal0ODfgsnvIOAastrJ2vyi1ujQLsqFXvfBvB1i3dbP0ZYaOAzgGIaYwnGEGcBMhsiNMhsAauZJxES5ZU5HKgavlZa08Blflz(BAEazRgZBTwQ(mFbMp7Mx2jan)2KXM)MM3K5zKXL59FEKcqZdjnaQwMbO594eFGYCswkhIBUEzauhE5X8j72CxC(fxvSvTvJCpeKspldGQLzakcielvo86Y2D5aielv(fyGVymsLy)UPsHC4P26XmqknqJ2vfBvB1y)UPsHC4P26XmqknIacXsLdVUSDxoacXsLd9aL5KSuoe3C9YaOo8YJ5t2T5U48lWxmgPsSF3uPqo8uB9ygiLgxCvXw1wnY9qqk9SmaQwMbOiGqSu5q0vfBvB1i3dbP0ZYaOAzgGIlpGjzPWQlB3LdGqSu5duyZ8qQjU9M0yS5tHqM3JBT08DfyEtBi7P2oVwY88EYLDjTMNyCA7obObkZjzPCiU5ANXyhZjzPhwYfFudH2KcHmqHnyZ8(AQdq895X3TvTDEStKBG5O5VPUcqZZ7jDLA788DdS4Zx68yFJrDPBEFT1lEaAGYCswkhIBU2zm2XCsw6HLCXh1qOnCYNSBJymsLiF3w12dHCdmhfj1Uz06cml62RRlY3TvT9qi3aZrrUyouWcg)BsZjzPr(UTQTN7IjXupDSSDxGgn6fD711f572Q2EiKBG5OiGqSu5W6kqpqHnZdjKtZJ9ng1LU591wV4bO53Ut68iMVIcm)Qe(8gGM3R3N5lW8z38YobO53Mm283088SvZU0zQmVKi08EQKS5LDAELGDzES7UPsHmpEQTEmdKsJ48nHU59KKLqcKA78yFJrDPB(MiWKDFMFVyR5T557gynVuZdOoaX3Nx2P5V966gOmNKLYH4MRrmg1LUdW6fpa5t2TbMvjrmjJoILQeL0Hk1w0OxLetKEsxP2ECMyCbu970zvsushQuBrJEvsKxESdOKOKouP2c9fyGpWtPUc0sreJrDP7SfyYoA03EDDreJrDP7SfyYEKlMdfSUcA08YJD47gybp4GEGcBMhsiNMh7BmQlDZ7RTEXdqZl18iwQIL68YonpIXOU0n)wGj7ZF711nVNkjBE(Ubw85vIwZl18308TKsatO18DfyEzNMxjyxM)2dWL53M6Q2opm(dzZZjxPl(8jFEKcqZl7Mop3RRlDjPY8snFlPeWeA(RmpF3alo0duMtYs5qCZ1igJ6s3by9IhG8j72a8uQRaTueXyux6oBbMSFXvfBvB1iV8yhqjraHyPYHN)q2LBVUUiIXOU0D2cmzpcielvoSA6af2mp23svSuNh7BmQlDZ3ebMSpVjZBm28sIq857kW8YonVFKduScSMVaZJDOgG005DfgsnvgOmNKLYH4MRrmg1LUdW6fpa5t2Tb4PuxbAPiIXOU0D2cmz)cmUcdPMkrLCGIvGfA0UcdPMkrunaPPqF52RRlIymQlDNTat2JacXsLdRMoqHnZdjKtZJ9ng1LU591wV4bO5lDES7UPsHmpEQTEmdKsJ5Dgx4(mpIHk1255EaAEPMNByO5T557gynVuZZfZHAESVXOU0nFteyY(8z38E8uBNpLbkZjzPCiU5AeJrDP7aSEXdq(KDBeJrQe73nvkKdp1wpMbsPXfywLe73nvkKdp1wpMbsPrushQuBrJ2vfBvB1y)UPsHC4P26XmqknIacXsLdp)9f0OVlo)IKi0rQZkjy5QITQTASF3uPqo8uB9ygiLgraHyPYH(cmWh4PuxbAPiIXOU0D2cmzhn6BVUUiIXOU0D2cmzpYfZHcwxbnAE5Xo8DdSGhCqpqzojlLdXnxJymQlDhG1lEaYNSBJymsLiV2EKD6WjAXhOWM5HKal15HTSJMp5ZxkRX828qsSl(8TwQZVnL95BckHjf7MrZdjjKKtZRKbMhXG955I5qXJZ3e6MVlB3L5t(82D5jZl18KUMFvZRLmpsY5ZZ7jDLA78Yonpxmhk(aL5KSuoe3C9cyPEyzh5t2T52RRlMkHjf7MrNfHKCkYfZHcEnfYqJ(2RRlMkHjf7MrNfHKCk61F5U48lDz7UCaeILkhwnDGYCswkhIBU2zm2XCsw6HLCXh1qOnUcdPMkduMtYs5qCZ1wBPn8X1WXOJyGws4BGZNSBdG6aeF3Uz0aL5KSuoe3CTNYf7MrhRRJLojl1NSBJ5KedDwLe9uUy3m6yDDS0jzPBGm0OL0Hk12laQdq8D7MrduMtYs5qCZ18SFV0dl7iFCnCm6igOLe(g48j72aOoaX3TBgnqzojlLdXnx7kaWRxYs9X1WXOJyGws4BGZNSBdG6aeF3Uz0fZjjg6qkHKehwnTjHrmgPsKxBpYoD4eT4OrlgJujYZ(9spSSJGEGYCswkhIBUUJr8DhW6eFYUn8YJDN6kIPyMKm6WlggsfFsviaWRxoz3MBVUUiMIzsYOdVyyivIE9duMtYs5qCZ1lGL6HxEmFsviaWRx2a3aL5KSuoe3CnF3w12ZDXKbQbkZjzP8Ov0M(DtLc5WtT1JzGuAmqzojlLhTIG4MR3npvgOmNKLYJwrqCZ1oJXoMtYspSKl(OgcTzzauTmdqNEa17t2TXvyi1ujIHuzVb4YQKyI0t6k12JZeJlGQFNoRsIs6qLA7fxvSvTvJCpeKspldGQLzakciB14cmRsI97MkfYHNARhZaP0icielvo88hnA4lgJuj2VBQuihEQTEmdKsdOrJ2vyi1ujQz7UC6m6YQKiV8yhqjrjDOsT9IRk2Q2QrUhcsPNLbq1YmafbKTACbMvjX(DtLc5WtT1JzGuAebeILkhE(Jgn8fJrQe73nvkKdp1wpMbsPb0OrdJRWqQPsujhOyfyHgTRWqQPsevdqAkA0UcdPMkrTuc6lRsI97MkfYHNARhZaP0ikPdvQTxwLe73nvkKdp1wpMbsPreqiwQCy5)aL5KSuE0kcIBUMt06uDhxbaE9swQpz3gXyKkrET9i70Ht0IFXz6Ht0AGYCswkpAfbXnxZjADQUJRaaVEjl1NSBd8fJrQe512JSthorl(f4VkjYjADQUJRaaVEjlnkPdvQTxGFQNow2UlxwLeDfa41lzPra1bi(UDZObkZjzP8Ovee3CT1wAdFCnCm6igOLe(g48j72yojXqNvjrRT0gWQPxG)QKO1wAJOKouP2oqzojlLhTIG4MRT2sB4JRHJrhXaTKW3aNpz3gZjjg6SkjATL2aEBA6fa1bi(UDZOlRsIwBPnIs6qLA7aL5KSuE0kcIBU2t5IDZOJ11XsNKL6t2TXCsIHoRsIEkxSBgDSUow6KS0nqgA0s6qLA7fa1bi(UDZObkZjzP8Ovee3CTNYf7MrhRRJLojl1hxdhJoIbAjHVboFYUnWxshQuBV0JPxmgPseyi9MkhRRJLojlLhj1Uz06I5KedDwLe9uUy3m6yDDS0jzPW6kduMtYs5rRiiU5AmjJoILQ4t2THxESdF3al4b3aL5KSuE0kcIBU2zm2XCsw6HLCXh1qOnUcdPMk(Wfq6KnW5t2Tb(UcdPMkrLCGIvG1aL5KSuE0kcIBU2zm2XCsw6HLCXh1qOnldGQLza60dOEFYUnW4kmKAQeXqQS3aCbgxvSvTvJjspPRuBpotmUaQ(DkciB1an6vjXePN0vQThNjgxav)oDwLeL0Hk1wOV4QITQTAK7HGu6zzauTmdqrazRgxGzvsSF3uPqo8uB9ygiLgraHyPYHN)OrdFXyKkX(DtLc5WtT1JzGuAan0xGbgxHHutLOsoqXkWcnAxHHutLiQgG0u0ODfgsnvIAPe0xCvXw1wnY9qqk9SmaQwMbOiGqSu5WY)lWSkj2VBQuihEQTEmdKsJiGqSu5WZF0OHVymsLy)UPsHC4P26XmqknGgA0OHXvyi1ujQz7UC6m6cmUQyRARg5Lh7akjciB1an6vjrE5XoGsIs6qLAl0xCvXw1wnY9qqk9SmaQwMbOiGqSu5WY)lWSkj2VBQuihEQTEmdKsJiGqSu5WZF0OHVymsLy)UPsHC4P26XmqknGg6bkZjzP8Ovee3C9YaOo8YJ5t2T5U48lUQyRARg5EiiLEwgavlZaueqiwQC41LT7YbqiwQ8lWaFXyKkX(DtLc5WtT1JzGuAGgTRk2Q2QX(DtLc5WtT1JzGuAebeILkhEDz7UCaeILkh6bkZjzP8Ovee3C9YaOo8YJ5t2T5U48lUQyRARg5EiiLEwgavlZaueqiwQCi6QITQTAK7HGu6zzauTmdqXLhWKSuy1LT7YbqiwQ8bkZjzP8Ovee3CTZySJ5KS0dl5IpQHqBsHqgOmNKLYJwrqCZ1oJXoMtYspSKl(OgcTzrmRbTocivuKWhOmNKLYJwrqCZ1oJXoMtYspSKl(OgcTzziwlDeqQOiHpqzojlLhTIG4MRDgJDmNKLEyjx8rneAdxm5iGurrc3hUasNSboFYUnRsI97MkfYHNARhZaP0ikPdvQTOrdFXyKkX(DtLc5WtT1JzGuAmqzojlLhTIG4MRrmg1LUdW6fpa5t2TzvsetYOJyPkrjDOsTDGYCswkpAfbXnxJymQlDhG1lEaYNSBZQKiV8yhqjrjDOsT9c8fJrQe512JSthorl(aL5KSuE0kcIBUgXyux6oaRx8aKpz3g4lgJujIjz0rSuLbkZjzP8Ovee3CnIXOU0DawV4biFYUn8YJD47gybVMoqzojlLhTIG4MR5z)EPhw2r(4A4y0rmqlj8nW5t2TXCsIHoRsI8SFV0dl7iyT5kxauhG472nJUa)vjrE2Vx6HLDuushQuBhOmNKLYJwrqCZ1oJXoMtYspSKl(OgcTXvyi1uXhUasNSboFYUnUcdPMkrLCGIvG1aL5KSuE0kcIBUEbSupSSJ8j72C711ftLWKIDZOZIqsof5I5qbVn(cKHg9DX5xU966IPsysXUz0zrijNIE9x6Y2D5aielvoS8f0OV966IPsysXUz0zrijNICXCOG3MR4lxwLe5Lh7akjkPdvQTduMtYs5rRiiU56ogX3DaRt8j72Wlp2DQRiMIzsYOdVyyiv8jvHaaVE5KDBU966IykMjjJo8IHHuj61pqzojlLhTIG4MRxal1dV8y(KQqaGxVSbUbkZjzP8Ovee3CnF3w12ZDXKbQbkZjzP8ORWqQPYMePN0vQThNjgxav)o5t2Tb(IXivI97MkfYHNARhZaP04cmUQyRARg5EiiLEwgavlZaueqiwQCybhKHgTRk2Q2QrUhcsPNLbq1YmafbeILkhE(cKHgTRk2Q2QrUhcsPNLbq1YmafbeILkhE(7lxCLU8sj6kaWRxsT9Wica9aL5KSuE0vyi1ubIBUor6jDLA7XzIXfq1Vt(KDBeJrQe73nvkKdp1wpMbsPXLvjX(DtLc5WtT1JzGuAeL0Hk12bkZjzP8ORWqQPce3C9ICjIjP2EUlM4t2TXvfBvB1i3dbP0ZYaOAzgGIacXsLdpF5cml62RRlUBEQebeILkhEnfnA4lgJujUBEQa9aL5KSuE0vyi1ubIBUMxESdOeFYUnWxmgPsSF3uPqo8uB9ygiLgxGXvfBvB1i3dbP0ZYaOAzgGIacXsLdlFbnAxvSvTvJCpeKspldGQLzakcielvo88fidnAxvSvTvJCpeKspldGQLzakcielvo883xU4kD5Ls0vaGxVKA7Hrea6bkZjzP8ORWqQPce3CnV8yhqj(KDBeJrQe73nvkKdp1wpMbsPXLvjX(DtLc5WtT1JzGuAeL0Hk12bkZjzP8ORWqQPce3Cn3vEGuBpsk70a1aL5KSuECziwlDeqQOiHVXJtNuieFudH2Wlp2jB1uiWaL5KSuECziwlDeqQOiHdXnx7XPtkeIpQHqBwaYwDjGoyioNyduMtYs5XLHyT0raPIIeoe3CThNoPqi(OgcTPL1OF)uDhJZtKKzsw6aL5KSuECziwlDeqQOiHdXnx7XPtkeIpQHqB8u3ULkToTmBLMua(HVBoumIpqzojlLhxgI1shbKkks4qCZ1EC6KcH4JAi0g6UuE5XoyshnqnqzojlLhxgavlZa0Phq9BWKm6iwQYaL5KSuECzauTmdqNEa1dXnxVmaQdV8yduMtYs5XLbq1YmaD6bupe3CDFjzPduMtYs5XLbq1YmaD6bupe3CDxcOBwvRbkZjzP84YaOAzgGo9aQhIBU(Mv1605bAmqzojlLhxgavlZa0Phq9qCZ13eGtauP2oqzojlLhxgavlZa0Phq9qCZ1oJXoMtYspSKl(OgcTXvyi1uXhUasNSboFYUnW3vyi1ujQKduScSgOmNKLYJldGQLza60dOEiU5AUhcsPNLbq1YmanqnqzojlLhxeZAqRJasffj8nEC6KcH4JAi0gcPVbGm2Pal1uh5t2TbgxHHutLOMT7YPZOlUQyRARg5Lh7akjcielvoS8hYGgnAyCfgsnvIyiv2BaU4QITQTAmr6jDLA7XzIXfq1VtraHyPYHL)qg0OrdJRWqQPsujhOyfyHgTRWqQPsevdqAkA0UcdPMkrTuc6bkZjzP84IywdADeqQOiHdXnx7XPtkeIpQHqB4E6nRQ1XqizVbx8j72aJRWqQPsuZ2D50z0fxvSvTvJ8YJDaLebeILkhwqoOrJggxHHutLigsL9gGlUQyRARgtKEsxP2ECMyCbu97ueqiwQCyb5GgnAyCfgsnvIk5afRal0ODfgsnvIOAastrJ2vyi1ujQLsqpqzojlLhxeZAqRJasffjCiU5ApoDsHq8rneAdV8ymsKuBpaV7g(KDBGXvyi1ujQz7UC6m6IRk2Q2QrE5XoGsIacXsLdlip0OrdJRWqQPsedPYEdWfxvSvTvJjspPRuBpotmUaQ(DkcielvoSG8qJgnmUcdPMkrLCGIvGfA0UcdPMkrunaPPOr7kmKAQe1sjOhOmNKLYJlIznO1raPIIeoe3CThNoPqi(OgcTHVBRAlTof4(uDhPaiKk(KDBGXvyi1ujQz7UC6m6IRk2Q2QrE5XoGsIacXsLdRMcnA0W4kmKAQeXqQS3aCXvfBvB1yI0t6k12JZeJlGQFNIacXsLdRMcnA0W4kmKAQevYbkwbwOr7kmKAQer1aKMIgTRWqQPsulLGEGAGYCswkpUk50dO(nwBPn8j72SkjATL2icielvoSG8xCvXw1wnY9qqk9SmaQwMbOiGqSu5WBvs0AlTreqiwQ8bkZjzP84QKtpG6H4MR5z)EPhw2r(KDBwLe5z)EPhw2rraHyPYHfK)IRk2Q2QrUhcsPNLbq1YmafbeILkhERsI8SFV0dl7OiGqSu5duMtYs5XvjNEa1dXnx7PCXUz0X66yPtYs9j72Skj6PCXUz0X66yPtYsJacXsLdli)fxvSvTvJCpeKspldGQLzakcielvo8wLe9uUy3m6yDDS0jzPraHyPYhOmNKLYJRso9aQhIBU2vaGxVKL6t2Tzvs0vaGxVKLgbeILkhwq(lUQyRARg5EiiLEwgavlZaueqiwQC4Tkj6kaWRxYsJacXsLpqnqzojlLhtHq24XPtkecFGAGYCswkpYPn7MNkduMtYs5robXnxVawQhE5X8jvHaaVE50YQBJTboFsviaWRxoz3MfD711f572Q2EiKBG5Oixmhk4T5kduMtYs5robXnxZ3TvT9CxmzGAGYCswkpYftocivuKW34XPtkeIpQHqBsL7aEIDZOZv7zQ4HCweM0rduMtYs5rUyYraPIIeoe3CThNoPqi(OgcTjvUa8Csb4NvIjv6Ctm2aL5KSuEKlMCeqQOiHdXnx7XPtkeIpQHqBkmeOJvBtT9yAIyhN1sduMtYs5rUyYraPIIeoe3CThNoPqi(OgcTzzauivPNf5qD69eaXDK6ObkZjzP8ixm5iGurrchIBU2JtNuieFudH2Gyo7gqh(orYbXJNUbkZjzP8ixm5iGurrchIBU2JtNuieFudH20Xme6uDNBtegnqzojlLh5IjhbKkks4qCZ1EC6KcH4JAi0MTgksja)0bkDnqzojlLh5IjhbKkks4qCZ1EC6KcH4JAi0gXUzKCQUZI49wcgOmNKLYJCXKJasffjCiU5ApoDsHq8rneAdp1op2X49jWuHFUTvlDQUthbkxkngOmNKLYJCXKJasffjCiU5ApoDsHq8rneAdp1op2PLzR0KcWp32QLov3PJaLlLgduMtYs5rUyYraPIIeoe3C9nRQ1PZd0yGYCswkpYftocivuKWH4MR7saDZQAnqzojlLh5IjhbKkks4qCZ13eGtauP2oqnqHnZ3eP5xLILmp3RVVaY8d2HN34Z7BirF98PopS5z(mpVMVjGfgAExPyiGqR5L9KpVuZBGu2rijDXbkZjzP8OasffjhEplLJBNCO2GXaPDZiFudH2W7jxASdD1EzFpT8bJX8OnWadCxf6Q9Y(EAfjK(gaYyNcSutDe0qeg4Uk0v7L990kMk3b8e7MrNR2ZuXd5SimPJGgIWa3vHUAVSVNwrE5XyKiP2EaE3nGgIWa3vHUAVSVNwrUNEZQADmes2BWfOHEdCduMtYs5rbKkkso8Ewkh3o5qbXnxJXaPDZiFudH2iGurrYPuYhmgZJ2aJasffjr4I7g)0dk3fbKkksIWf3n(XvfBvBvOhOmNKLYJcivuKC49SuoUDYHcIBUgJbs7Mr(OgcTraPIIKJST8bJX8OnWiGurrs0)4UXp9GYDraPIIKO)XDJFCvXw1wf6bkZjzP8OasffjhEplLJBNCOG4MRXyG0UzKpQHqBwgI1shbKkks8bJX8OnWaFyeqQOijcxC34NEq5UiGurrseU4UXpUQyRARcn0Ordd8HraPIIKO)XDJF6bL7Iasffjr)J7g)4QITQTk0qJgnD1EzFpTITSg97NQ7yCEIKmtYshOmNKLYJcivuKC49SuoUDYHcIBUgJbs7Mr(OgcTraPIIKdVNLIpymMhTbgmgiTBgffqQOi5ukDbJbs7MrXLHyT0raPIIeOrJggmgiTBgffqQOi5iBRlymqA3mkUmeRLocivuKanA0Wa3vbJbs7MrrbKkksoLsqdryG7QGXaPDZOiVNCPXo0v7L990c6nWHgnmWDvWyG0UzuuaPIIKJSTGgIWa3vbJbs7MrrEp5sJDOR2l77Pf0BGlGJHa8S0GF(dz(dhKb5HdYhW3Aan1wEaVjI981(1e8d7aSD(5BENMpr6lGmFxbMhlbKkkso8Ewkh3o5qH18a6Q9saTMNxi08MNuiMqR5D7M2s84afSLknV)y78qAPyiGqR5XsaPIIKiCrFJ18snpwcivuKef4I(gR5HXFyh64afSLkn)vW25H0sXqaHwZJLasffjr)J(gR5LAESeqQOijk(h9nwZdJ)Wo0XbkylvA(MITZdPLIHacTMhlbKkksIWf9nwZl18yjGurrsuGl6BSMhg)HDOJduWwQ08nfBNhslfdbeAnpwcivuKe9p6BSMxQ5XsaPIIKO4F03ynpm(d7qhhOgOAIypFTFnb)WoaBNF(M3P5tK(ciZ3vG5XYvyi1ubR5b0v7LaAnpVqO5npPqmHwZ72nTL4XbkylvAE4W25H0sXqaHwZJLymsLOVXAEPMhlXyKkrFhj1Uz0cR5Hboyh64afSLknpCy78qAPyiGqR5XYv6YlLOVXAEPMhlxPlVuI(osQDZOfwZddCWo0XbkylvAE)X25H0sXqaHwZJLymsLOVXAEPMhlXyKkrFhj1Uz0cR5Hboyh64afSLkn)vW25H0sXqaHwZJLymsLOVXAEPMhlXyKkrFhj1Uz0cR5Hboyh64afSLknFtX25H0sXqaHwZJLymsLOVXAEPMhlXyKkrFhj1Uz0cR5Hboyh64afSLknFtX25H0sXqaHwZJLR0LxkrFJ18snpwUsxEPe9DKu7MrlSMhg4GDOJduWwQ08(c2opKwkgci0AESeJrQe9nwZl18yjgJuj67iP2nJwynpmWb7qhhOgOAIypFTFnb)WoaBNF(M3P5tK(ciZ3vG5XArDMhtWAEaD1EjGwZZleAEZtketO18UDtBjECGc2sLMhYHTZdPLIHacTMhlXyKkrFJ18snpwIXivI(osQDZOfwZBY8yNqIW28WahSdDCGc2sLM)QITZdPLIHacTMhlbKkksIWf9nwZl18yjGurrsuGl6BSMhMMc7qhhOGTuP5VQy78qAPyiGqR5XsaPIIKO)rFJ18snpwcivuKef)J(gR5HPPWo0XbkylvAEFvSDEiTumeqO18yjgJuj6BSMxQ5XsmgPs03rsTBgTWAEy8h2HooqbBPsZdhKHTZdPLIHacTMhlXyKkrFJ18snpwIXivI(osQDZOfwZddCWo0XbkylvAE48hBNhslfdbeAnpwIXivI(gR5LAESeJrQe9DKu7MrlSMhg4GDOJduWwQ08WDfSDEiTumeqO18yjGurrs0UDrxvSvTvXAEPMhlxvSvTvJ2TdR5Hboyh64afSLknpCnfBNhslfdbeAnpwcivuKeTBx0vfBvBvSMxQ5XYvfBvB1OD7WAEyGd2HooqbBPsZdNVGTZdPLIHacTMhlGNsDfOLI(gR5LAESaEk1vGwk67iP2nJwynpmWb7qhhOGTuP5HZxW25H0sXqaHwZJLasffjr72fDvXw1wfR5LAESCvXw1wnA3oSMhg4GDOJduWwQ08Wb5W25H0sXqaHwZJfWtPUc0srFJ18snpwapL6kqlf9DKu7MrlSMhg4GDOJduWwQ08Wb5W25H0sXqaHwZJLasffjr72fDvXw1wfR5LAESCvXw1wnA3oSMhg4GDOJduWwQ08(dh2opKwkgci0AESeJrQe9nwZl18yjgJuj67iP2nJwynpmWb7qhhOGTuP593FSDEiTumeqO18yjgJuj6BSMxQ5XsmgPs03rsTBgTWAEyGd2HooqbBPsZ7)vfBNhslfdbeAnpwIXivI(gR5LAESeJrQe9DKu7MrlSMhg)HDOJduWwQ08(7RITZdPLIHacTMhlXyKkrFJ18snpwIXivI(osQDZOfwZdJ)Wo0XbkylvA(Razy78qAPyiGqR5XsmgPs03ynVuZJLymsLOVJKA3mAH18WahSdDCGc2sLM)kWHTZdPLIHacTMhlXyKkrFJ18snpwIXivI(osQDZOfwZddCWo0XbkylvA(R0uSDEiTumeqO18yb8uQRaTu03ynVuZJfWtPUc0srFhj1Uz0cR5Hboyh64afSLkn)v8fSDEiTumeqO18yb8uQRaTu03ynVuZJfWtPUc0srFhj1Uz0cR5Hboyh64afSLkn)vGCy78qAPyiGqR5Xc4PuxbAPOVXAEPMhlGNsDfOLI(osQDZOfwZddCWo0XbkylvA(RCvX25H0sXqaHwZJLymsLOVXAEPMhlXyKkrFhj1Uz0cR5Hboyh64afSLkn)vUQy78qAPyiGqR5Xc4PuxbAPOVXAEPMhlGNsDfOLI(osQDZOfwZddCWo0XbkylvA(Ra5X25H0sXqaHwZJLymsLOVXAEPMhlXyKkrFhj1Uz0cR5nzEStiryBEyGd2HooqbBPsZ30MITZdPLIHacTMhlXyKkrFJ18snpwIXivI(osQDZOfwZdJ)Wo0XbkylvA(M6ly78qAPyiGqR5XIxES7uxrFJ18snpw8YJDN6k67iP2nJwynVjZJDcjcBZddCWo0XbQbQMi2Zx7xtWpSdW25NV5DA(ePVaY8DfyESSIWAEaD1EjGwZZleAEZtketO18UDtBjECGc2sLM)ky78qAPyiGqR5XsmgPs03ynVuZJLymsLOVJKA3mAH18W4pSdDCGc2sLMVPy78qAPyiGqR5XsmgPs03ynVuZJLymsLOVJKA3mAH18WahSdDCGc2sLM3xW25H0sXqaHwZJLymsLOVXAEPMhlXyKkrFhj1Uz0cR5Hboyh64afSLknpC(JTZdPLIHacTMhlXyKkrFJ18snpwIXivI(osQDZOfwZdZvGDOJduWwQ08WDfSDEiTumeqO18yjgJuj6BSMxQ5XsmgPs03rsTBgTWAEyGd2HooqbBPsZdhKhBNhslfdbeAnpwIXivI(gR5LAESeJrQe9DKu7MrlSM3K5XoHeHT5Hboyh64afSLknV)qg2opKwkgci0AESeJrQe9nwZl18yjgJuj67iP2nJwynVjZJDcjcBZddCWo0XbkylvAE)HdBNhslfdbeAnpwIXivI(gR5LAESeJrQe9DKu7MrlSM3K5XoHeHT5Hboyh64afSLknV)qoSDEiTumeqO18yXlp2DQROVXAEPMhlE5XUtDf9DKu7MrlSM3K5XoHeHT5Hboyh64a1avtaPVacTMho)N3Csw68SKl84avaNLCHhAoGVmaQwMbOtpG6dnh8dUqZbCZjzPbCmjJoILQeWj1Uz0kaHGe8Z)qZbCZjzPb8LbqD4LhlGtQDZOvacbj43vcnhWnNKLgW7ljlnGtQDZOvacbj4xtdnhWnNKLgW7saDZQAfWj1Uz0kaHGe8ZxcnhWnNKLgWVzvToDEGgbCsTBgTcqiib)GCHMd4MtYsd43eGtauP2gWj1Uz0kaHGe87QgAoGtQDZOvacbChifcKwah(Z7kmKAQevYbkwbwbCUasNe8dUaU5KS0aUZySJ5KS0dl5saNLC5OgcfWDfgsnvcsWpiFO5aU5KS0ao3dbP0ZYaOAzgGc4KA3mAfGqqcsaxaPIIKdVNLYXTtouHMd(bxO5aoP2nJwbieWR(aoNKaU5KS0aogdK2nJc4ymMhfWHzEyMhU5VkZtxTx23tRiH03aqg7uGLAQJMh65H48WmpCZFvMNUAVSVNwXu5oGNy3m6C1EMkEiNfHjD08qppeNhM5HB(RY80v7L990kYlpgJej12dW7UX8qppeNhM5HB(RY80v7L990kY90BwvRJHqYEdUmp0Zd98BMhUa(I4oq2lzPb8Min)QuSK55E99fqMpGJXah1qOaoVNCPXo0v7L990kib)8p0CaNu7MrRaec4vFaNtsa3CswAahJbs7MrbCmgZJc4WmVasffjrbU4UXp9GYn)L5fqQOijkWf3n(XvfBvB15HoGJXah1qOaUasffjNsPGe87kHMd4KA3mAfGqaV6d4Csc4MtYsd4ymqA3mkGJXyEuahM5fqQOijk(h3n(PhuU5VmVasffjrX)4UXpUQyRARop0bCmg4OgcfWfqQOi5iBRGe8RPHMd4KA3mAfGqaV6d4Csc4MtYsd4ymqA3mkGJXyEuahM5H)8WmVasffjrbU4UXp9GYn)L5fqQOijkWf3n(XvfBvB15HEEONhn65HzE4ppmZlGurrsu8pUB8tpOCZFzEbKkksII)XDJFCvXw1wDEONh65rJEE6Q9Y(EAfBzn63pv3X48ejzMKLgWXyGJAiuaFziwlDeqQOijib)8LqZbCsTBgTcqiGx9bCojbCZjzPbCmgiTBgfWXympkGdZ8ymqA3mkkGurrYPuA(lZJXaPDZO4YqSw6iGurrY8qppA0ZdZ8ymqA3mkkGurrYr2wZFzEmgiTBgfxgI1shbKkksMh65rJEEyMhU5VkZJXaPDZOOasffjNsP5HEEiopmZd38xL5XyG0UzuK3tU0yh6Q9Y(EAnp0ZVzE4Mhn65HzE4M)QmpgdK2nJIcivuKCKT18qppeNhM5HB(RY8ymqA3mkY7jxASdD1EzFpTMh653mpCbCmg4OgcfWfqQOi5W7zPeKGeWxgI1shbKkks4HMd(bxO5aoP2nJwbieWvdHc48YJDYwnfceWnNKLgW5Lh7KTAkeiib)8p0CaNu7MrRaec4QHqb8fGSvxcOdgIZjwa3CswAaFbiB1La6GH4CIfKGFxj0CaNu7MrRaec4QHqb8wwJ(9t1DmoprsMjzPbCZjzPb8wwJ(9t1DmoprsMjzPbj4xtdnhWj1Uz0kaHaUAiua3tD7wQ060YSvAsb4h(U5qXiEa3CswAa3tD7wQ060YSvAsb4h(U5qXiEqc(5lHMd4KA3mAfGqaxnekGt3LYlp2bt6OaU5KS0aoDxkV8yhmPJcsqc4lIznO1raPIIeEO5GFWfAoGtQDZOvacbCZjzPbCcPVbGm2Pal1uhfWDGuiqAbCyM3vyi1ujQz7UC6mA(lZ7QITQTAKxESdOKiGqSu5ZdR59hYMh65rJEEyM3vyi1ujIHuzVby(lZ7QITQTAmr6jDLA7XzIXfq1VtraHyPYNhwZ7pKnp0ZJg98WmVRWqQPsujhOyfynpA0Z7kmKAQer1aKMopA0Z7kmKAQe1sP5HoGRgcfWjK(gaYyNcSutDuqc(5FO5aoP2nJwbieWnNKLgW5E6nRQ1XqizVbxc4oqkeiTaomZ7kmKAQe1SDxoDgn)L5DvXw1wnYlp2buseqiwQ85H18qU5HEE0ONhM5DfgsnvIyiv2BaM)Y8UQyRARgtKEsxP2ECMyCbu97ueqiwQ85H18qU5HEE0ONhM5DfgsnvIk5afRaR5rJEExHHutLiQgG005rJEExHHutLOwknp0bC1qOao3tVzvTogcj7n4sqc(DLqZbCsTBgTcqiGBojlnGZlpgJej12dW7Ura3bsHaPfWHzExHHutLOMT7YPZO5VmVRk2Q2QrE5XoGsIacXsLppSMhYpp0ZJg98WmVRWqQPsedPYEdW8xM3vfBvB1yI0t6k12JZeJlGQFNIacXsLppSMhYpp0ZJg98WmVRWqQPsujhOyfynpA0Z7kmKAQer1aKMopA0Z7kmKAQe1sP5HoGRgcfW5LhJrIKA7b4D3iib)AAO5aoP2nJwbieWnNKLgW572Q2sRtbUpv3rkacPsa3bsHaPfWHzExHHutLOMT7YPZO5VmVRk2Q2QrE5XoGsIacXsLppSMVPZd98OrppmZ7kmKAQeXqQS3am)L5DvXw1wnMi9KUsT94mX4cO63PiGqSu5ZdR5B68qppA0ZdZ8UcdPMkrLCGIvG18OrpVRWqQPsevdqA68OrpVRWqQPsulLMh6aUAiuaNVBRAlTof4(uDhPaiKkbjibCxHHutLqZb)Gl0CaNu7MrRaec4oqkeiTao8NxmgPsSF3uPqo8uB9ygiLgrsTBgTM)Y8WmVRk2Q2QrUhcsPNLbq1YmafbeILkFEynpCq28OrpVRk2Q2QrUhcsPNLbq1YmafbeILkFE4nVVazZJg98UQyRARg5EiiLEwgavlZaueqiwQ85H38(7lZFzExPlVuIUca86LuBpmIarsTBgTMh6aU5KS0aEI0t6k12JZeJlGQFNcsWp)dnhWj1Uz0kaHaUdKcbslGlgJuj2VBQuihEQTEmdKsJiP2nJwZFz(vjX(DtLc5WtT1JzGuAeL0Hk12aU5KS0aEI0t6k12JZeJlGQFNcsWVReAoGtQDZOvacbChifcKwa3vfBvB1i3dbP0ZYaOAzgGIacXsLpp8M3xM)Y8Wm)IU966I7MNkraHyPYNhEZ305rJEE4pVymsL4U5PsKu7MrR5HoGBojlnGVixIysQTN7Ijbj4xtdnhWj1Uz0kaHaUdKcbslGd)5fJrQe73nvkKdp1wpMbsPrKu7MrR5VmpmZ7QITQTAK7HGu6zzauTmdqraHyPYNhwZ7lZJg98UQyRARg5EiiLEwgavlZaueqiwQ85H38(cKnpA0Z7QITQTAK7HGu6zzauTmdqraHyPYNhEZ7VVm)L5DLU8sj6kaWRxsT9Wicej1Uz0AEOd4MtYsd48YJDaLeKGF(sO5aoP2nJwbieWDGuiqAbCXyKkX(DtLc5WtT1JzGuAej1Uz0A(lZVkj2VBQuihEQTEmdKsJOKouP2gWnNKLgW5Lh7akjib)GCHMd4MtYsd4Cx5bsT9iPStbCsTBgTcqiibjGVk50dO(qZb)Gl0CaNu7MrRaec4oqkeiTa(QKO1wAJiGqSu5ZdR5H8ZFzExvSvTvJCpeKspldGQLzakcielv(8WB(vjrRT0graHyPYd4MtYsd4wBPncsWp)dnhWj1Uz0kaHaUdKcbslGVkjYZ(9spSSJIacXsLppSMhYp)L5DvXw1wnY9qqk9SmaQwMbOiGqSu5ZdV5xLe5z)EPhw2rraHyPYd4MtYsd48SFV0dl7OGe87kHMd4KA3mAfGqa3bsHaPfWxLe9uUy3m6yDDS0jzPraHyPYNhwZd5N)Y8UQyRARg5EiiLEwgavlZaueqiwQ85H38RsIEkxSBgDSUow6KS0iGqSu5bCZjzPbCpLl2nJowxhlDswAqc(10qZbCsTBgTcqiG7aPqG0c4RsIUca86LS0iGqSu5ZdR5H8ZFzExvSvTvJCpeKspldGQLzakcielv(8WB(vjrxbaE9swAeqiwQ8aU5KS0aURaaVEjlnibjGVOoZJjHMd(bxO5aU5KS0aoVNySdRCOc4KA3mAfGqqc(5FO5aU5KS0a(IWuEGdI1MUaoP2nJwbieKGFxj0CaNu7MrRaec4oqkeiTaU5KedDiLqsIpp8M)kbCUasNe8dUaU5KS0aUZySJ5KS0dl5saNLC5OgcfWTIcsWVMgAoGtQDZOvacb8fXDGSxYsd4ypNKLopl5cF(UcmVasffjZFt7gMSaX5Xft4ZBaAEUHHwZ3vG5VPUcqZJxES591LCDtaPN0vQTZdPMyCbu9701y3DtLczE8uB9ygiLg(mFj7eyBYP5lDExvSvTvJbCZjzPbCNXyhZjzPhwYLaol5YrnekGlGurrYH3Zs542jhQGe8ZxcnhWj1Uz0kaHaU5KS0aUZySJ5KS0dl5saNLC5OgcfWxeZAqRJasffj8Ge8dYfAoGtQDZOvacbChifcKwahM5xLe5Lh7akjkPdvQTZJg98RsIjspPRuBpotmUaQ(D6SkjkPdvQTZJg98RsI97MkfYHNARhZaP0ikPdvQTZd98xMNxESdF3aR5H38xzE0ONFvsetYOJyPkrjDOsTDE0ONxmgPsKxBpYoD4eT4rsTBgTc4CbKoj4hCbCZjzPbCNXyhZjzPhwYLaol5YrnekGZftocivuKWdsWVRAO5aoP2nJwbieWDGuiqAbCxHHutLOMT7YPZO5VmpmZd)5XyG0UzuuaPIIKdVNLY8OrpVRk2Q2QrE5XoGsIacXsLpp8M3FiBE0ONhM5XyG0UzuuaPIIKtP08xM3vfBvB1iV8yhqjraHyPYNhwZlGurrsuGl6QITQTAeqiwQ85HEE0ONhM5XyG0UzuuaPIIKJSTM)Y8UQyRARg5Lh7akjcielv(8WAEbKkksII)rxvSvTvJacXsLpp0Zd98OrpVRWqQPsedPYEdW8xMhM5H)8ymqA3mkkGurrYH3ZszE0ON3vfBvB1yI0t6k12JZeJlGQFNIacXsLpp8M3FiBE0ONhM5XyG0UzuuaPIIKtP08xM3vfBvB1yI0t6k12JZeJlGQFNIacXsLppSMxaPIIKOax0vfBvB1iGqSu5Zd98OrppmZJXaPDZOOasffjhzBn)L5DvXw1wnMi9KUsT94mX4cO63PiGqSu5ZdR5fqQOijk(hDvXw1wncielv(8qpp0ZJg98WmVRWqQPsujhOyfynpA0Z7kmKAQer1aKMopA0Z7kmKAQe1sP5HE(lZdZ8WFEmgiTBgffqQOi5W7zPmpA0Z7QITQTASF3uPqo8uB9ygiLgraHyPYNhEZ7pKnpA0ZdZ8ymqA3mkkGurrYPuA(lZ7QITQTASF3uPqo8uB9ygiLgraHyPYNhwZlGurrsuGl6QITQTAeqiwQ85HEE0ONhM5XyG0UzuuaPIIKJSTM)Y8UQyRARg73nvkKdp1wpMbsPreqiwQ85H18civuKef)JUQyRARgbeILkFEONh65rJEE4pVymsLy)UPsHC4P26XmqknIKA3mAn)L5HzE4ppgdK2nJIcivuKC49SuMhn65DvXw1wnY9qqk9SmaQwMbOiGqSu5ZdV59hYMhn65HzEmgiTBgffqQOi5ukn)L5DvXw1wnY9qqk9SmaQwMbOiGqSu5ZdR5fqQOijkWfDvXw1wncielv(8qppA0ZdZ8ymqA3mkkGurrYr2wZFzExvSvTvJCpeKspldGQLzakcielv(8WAEbKkksII)rxvSvTvJacXsLpp0ZdDa3CswAa3zm2XCsw6HLCjGZsUCudHc4ldXAPJasffj8Ge8dYhAoGtQDZOvacbCZjzPbCeJrDP7aSEXdqb8fXDGSxYsd4qWdOZZlp288DdS4ZNDZ3LT7Y8jFEJHuCz(cdbc4oqkeiTa(DX5ZFz(USDxoacXsLppSMNGDY5j0rseA(RY88YJD47gyn)L5xLe9uUy3m6yDDS0jzPrjDOsTnib)8vdnhWj1Uz0kaHa(I4oq2lzPb8Mq38UcdPMkZVk5AS7UPsHmpEQTEmdKsJ5t(8apvtT1N59408qsdGQLzaAEPMNGDH018YonVZdaivMNtsa3CswAa3zm2XCsw6HLCjG7aPqG0c4WmVRWqQPsedPYEdW8xMFvsmr6jDLA7XzIXfq1VtNvjrjDOsTD(lZ7QITQTAK7HGu6zzauTmdqraHyPYNhwZ7)8xMhM5xLe73nvkKdp1wpMbsPreqiwQ85H38(ppA0Zd)5fJrQe73nvkKdp1wpMbsPrKu7MrR5HEEONhn65HzExHHutLOMT7YPZO5Vm)QKiV8yhqjrjDOsTD(lZ7QITQTAK7HGu6zzauTmdqraHyPYNhwZ7)8xMhM5xLe73nvkKdp1wpMbsPreqiwQ85H38(ppA0Zd)5fJrQe73nvkKdp1wpMbsPrKu7MrR5HEEONhn65HzEyM3vyi1ujQKduScSMhn65DfgsnvIOAastNhn65DfgsnvIAP08qp)L5xLe73nvkKdp1wpMbsPrushQuBN)Y8RsI97MkfYHNARhZaP0icielv(8WAE)Nh6aol5YrnekGVmaQwMbOtpG6dsWp4GSqZbCsTBgTcqiGViUdK9swAa3xtDaIVp)Qe(8KbynMp7MVTsTD(uLAEBE(UbwZZ7jDLA7897gNc4MtYsd4oJXoMtYspSKlbChifcKwahM5DfgsnvIA2UlNoJM)Y8WF(vjrE5XoGsIs6qLA78xM3vfBvB1iV8yhqjraHyPYNhwZ305HEE0ONhM5DfgsnvIyiv2BaM)Y8WF(vjXePN0vQThNjgxav)oDwLeL0Hk125VmVRk2Q2QXePN0vQThNjgxav)ofbeILkFEynFtNh65rJEEyMhM5DfgsnvIk5afRaR5rJEExHHutLiQgG005rJEExHHutLOwknp0ZFzEXyKkX(DtLc5WtT1JzGuAej1Uz0A(lZd)5xLe73nvkKdp1wpMbsPrushQuBN)Y8UQyRARg73nvkKdp1wpMbsPreqiwQ85H18nDEOd4SKlh1qOa(QKtpG6dsWp4Gl0CaNu7MrRaec4MtYsd4ldG6WlpwaFrChi7LS0aEtOBES7UPsHmpEQTEmdKsJ5t(8s6qLARpZNY8jFEU1rZl18ECAEiPbqnpE5Xc4oqkeiTa(QKy)UPsHC4P26XmqknIs6qLABqc(bN)HMd4KA3mAfGqa3bsHaPfWH)8IXivI97MkfYHNARhZaP0isQDZO18xMhM5xLe5Lh7akjkPdvQTZJg98RsIjspPRuBpotmUaQ(D6SkjkPdvQTZdDa3CswAaFzauhE5XcsWp4UsO5aoP2nJwbieWnNKLgW73nvkKdp1wpMbsPraFrChi7LS0aoEd1np2D3uPqMhp1wpMbsPX8BtzFESJKk7nax7x2UlZ7R0O5DfgsnvMFvIpZxYob2MCAEponFPZ7QITQTAC(Mq38yNi9naKXMhseSutD083EDDZN85t1viP26Z87fBnVNkjB(uWIppGSvJ5Hboi)8CYv6IpV1jeyEpobDa3bsHaPfWDfgsnvIA2UlNoJM)Y8sIqZdV59L5VmVRk2Q2QrE5XoGsIacXsLppSMhU5VmpmZ7QITQTAKq6BaiJDkWsn1rraHyPYNhwZdhKZ)5rJEE4ppD1EzFpTIesFdazStbwQPoAEOdsWp4AAO5aoP2nJwbieWDGuiqAbCxHHutLigsL9gG5VmVKi08WBEFz(lZ7QITQTAmr6jDLA7XzIXfq1VtraHyPYNhwZd38xMhM5DvXw1wnsi9naKXofyPM6OiGqSu5ZdR5HdY5)8Orpp8NNUAVSVNwrcPVbGm2Pal1uhnp0bCZjzPb8(DtLc5WtT1JzGuAeKGFW5lHMd4KA3mAfGqa3CswAaVF3uPqo8uB9ygiLgb8fXDGSxYsd4(roqXkWA(TPSpp23yux6MVjcmzFENXf(897MkfY88uB9ygiLgZN68SuP53MY(8qsYLiMKA78qOysa3bsHaPfWDfgsnvIk5afRaR5VmpWtPUc0sreJrDP7SfyYEKu7MrR5VmVKi08WBEFz(lZ7QITQTACrUeXKuBp3ftIacXsLppSM)kZFzEyM3vfBvB1iH03aqg7uGLAQJIacXsLppSMhoiN)ZJg98WFE6Q9Y(EAfjK(gaYyNcSutD08qhKGFWb5cnhWj1Uz0kaHaU5KS0aE)UPsHC4P26Xmqknc4lI7azVKLgWHeLDcmVRWqQPcFEys1X8wP2oVwAtI9BIZ7h5af0Z7mUmp2fF(sN3vfBvB1aUdKcbslGdZ8UcdPMkrunaPPZJg98UcdPMkrTuAE0ONhM5DfgsnvIk5afRaR5Vmp8Nh4PuxbAPiIXOU0D2cmzpsQDZO18qpp0ZFzEyM3vfBvB1iH03aqg7uGLAQJIacXsLppSMhoiN)ZJg98WFE6Q9Y(EAfjK(gaYyNcSutD08qhKGFWDvdnhWj1Uz0kaHaUdKcbslGFxC(8xMVlB3LdGqSu5ZdR5HdYfWnNKLgW73nvkKdp1wpMbsPrqc(bhKp0CaNu7MrRaec4lI7azVKLgWBcDZJD3nvkK5XtT1JzGuAmFYNxshQuB9z(uWIpVKi08snVhNMVKDcmpI5ROaZVkHhWnNKLgWDgJDmNKLEyjxc4CbKoj4hCbChifcKwaFvsSF3uPqo8uB9ygiLgrjDOsTD(lZdZ8UcdPMkrnB3LtNrZJg98UcdPMkrmKk7naZdDaNLC5OgcfWDfgsnvcsWp48vdnhWj1Uz0kaHaU5KS0aU1wAJaUdKcbslGVkjATL2icielv(8WA(MgWDnCm6igOLeEWp4csWp)HSqZbCZjzPb8DZtLaoP2nJwbieKGF(dxO5aoP2nJwbieWnNKLgW5eTov3XvaGxVKLgWxe3bYEjlnGJxBNx2P5XjAXNV05VY8IbAjHpF2nFkZNCflzENhaqQWAmFQZ3XY2Dz(cmFPZl708IbAjjoFtmL95XZ(9sNh2YoA(uWIpVX4183KieyEPM3JtZJt0A(cdbMhXupJXAmV13ZAKA78xzEiTaaVEjlLhd4oqkeiTaU5KedDiLqsIpp8M3)5VmVymsLiV2EKD6WjAXJKA3mAn)L5H)8RsICIwNQ74kaWRxYsJs6qLA78xMh(ZN6PJLT7sqc(5V)HMd4KA3mAfGqa3bsHaPfWnNKyOdPess85H38(p)L5fJrQe5z)EPhw2rrsTBgTM)Y8WF(vjrorRt1DCfa41lzPrjDOsTD(lZd)5t90XY2Dz(lZVkj6kaWRxYsJacXsLppSMVPbCZjzPbCorRt1DCfa41lzPbj4N)xj0CaNu7MrRaec4oqkeiTaomZZlp2HVBG18WBE4Mhn65nNKyOdPess85H38(pp0ZFzExvSvTvJCpeKspldGQLzakcielv(8WBE48pGBojlnGJjz0rSuLGe8Z)MgAoGtQDZOvacbChifcKwa3CsIHoRsIEkxSBgDSUow6KS053mpKnpA0ZlPdvQTZFz(vjrpLl2nJowxhlDswAeqiwQ85H18nnGBojlnG7PCXUz0X66yPtYsdsWp)9LqZbCsTBgTcqiGBojlnGZZ(9spSSJc4oqkeiTa(QKip73l9WYokcielv(8WA(MgWDnCm6igOLeEWp4csWp)HCHMd4KA3mAfGqa3bsHaPfWH)8UcdPMkrLCGIvGvaNlG0jb)GlGBojlnG7mg7yojl9WsUeWzjxoQHqbCxHHutLGe8Z)RAO5aoP2nJwbieWnNKLgWDfa41lzPbCxdhJoIbAjHh8dUaUdKcbslGBojXqhsjKK4ZdR5B68n58WmVymsLiV2EKD6WjAXJKA3mAnpA0ZlgJujYZ(9spSSJIKA3mAnp0ZFz(vjrxbaE9swAeqiwQ85H18(hWxe3bYEjlnGJ967znMhslaWRxYsNhXupJXAmFPZdxt6)8IbAjH7Z8fy(sN)kZVnL95XE38I5j08qAbaE9swAqc(5pKp0CaNu7MrRaec4MtYsd4igJ6s3by9IhGc4lI7azVKLgWXEDcbMx2P5REsjGpZZ7jDnVnpF3aR53Ut68MmVVmFPZJ9ng1LU591wV4bO5LAEdtLR5lmeWz99P2gWDGuiqAbCE5Xo8DdSMhEZ305VmVKi08WBE)Hlib)83xn0CaNu7MrRaec4lI7azVKLgWBI7KoVwY88gQl125XU7MkfY84P26XmqknMxQ5XosQS3aCTFz7UmVVsJ8zECpeKsNhsAauTmdqZNDZBm28Rs4ZBaAERVNL0kGBojlnG7mg7yojl9WsUeWDGuiqAbCyM3vyi1ujIHuzVby(lZd)5fJrQe73nvkKdp1wpMbsPrKu7MrR5Vm)QKyI0t6k12JZeJlGQFNoRsIs6qLA78xM3vfBvB1i3dbP0ZYaOAzgGIaYwnMh65rJEEyM3vyi1ujQz7UC6mA(lZd)5fJrQe73nvkKdp1wpMbsPrKu7MrR5Vm)QKiV8yhqjrjDOsTD(lZ7QITQTAK7HGu6zzauTmdqrazRgZd98OrppmZdZ8UcdPMkrLCGIvG18OrpVRWqQPsevdqA68OrpVRWqQPsulLMh65VmVRk2Q2QrUhcsPNLbq1YmafbKTAmp0bCwYLJAiuaFzauTmdqNEa1hKGFxbYcnhWj1Uz0kaHaU5KS0a(YaOo8YJfWxe3bYEjlnGdjKtZdjnaQ5Xlp28z38qsdGQLzaA(TLILm)nnpGSvJ5TwlvFMVaZNDZl7eGMFBYyZFtZBY8mY4Y8(ppsbO5HKgavlZa08ECIhWDGuiqAb87IZN)Y8UQyRARg5EiiLEwgavlZaueqiwQ85H38Dz7UCaeILkF(lZdZ8WFEXyKkX(DtLc5WtT1JzGuAej1Uz0AE0ON3vfBvB1y)UPsHC4P26XmqknIacXsLpp8MVlB3LdGqSu5ZdDqc(Df4cnhWj1Uz0kaHaUdKcbslGFxC(8xMh(ZlgJuj2VBQuihEQTEmdKsJiP2nJwZFzExvSvTvJCpeKspldGQLzakcielv(8qCExvSvTvJCpeKspldGQLzakU8aMKLopSMVlB3LdGqSu5bCZjzPb8LbqD4Lhlib)UI)HMd4KA3mAfGqaFrChi7LS0aoKAIBVjngB(uiK594wlnFxbM30gYEQTZRLmpVNCzxsR5jgN2UtakGBojlnG7mg7yojl9WsUeWzjxoQHqb8uiKGe87kxj0CaNu7MrRaec4oqkeiTaUymsLiF3w12dHCdmhfj1Uz0A(lZdZ8l62RRlY3TvT9qi3aZrrUyouZdR5HzE)NVjN3CswAKVBRA75Uysm1thlB3L5HEE0ONFr3EDDr(UTQThc5gyokcielv(8WA(Rmp0bCZjzPbCNXyhZjzPhwYLaol5YrnekGZPGe87knn0CaNu7MrRaec4MtYsd4igJ6s3by9IhGc4lI7azVKLgWHeYP5X(gJ6s38(ARx8a08B3jDEeZxrbMFvcFEdqZ717Z8fy(SBEzNa08BtgB(BAEE2Qzx6mvMxseAEpvs28YonVsWUmp2D3uPqMhp1wpMbsPrC(Mq38EsYsibsTDESVXOU0nFteyYUpZVxS18288DdSMxQ5buhG47Zl7083EDDbChifcKwahM5xLeXKm6iwQsushQuBNhn65xLetKEsxP2ECMyCbu970zvsushQuBNhn65xLe5Lh7akjkPdvQTZd98xMhM5H)8apL6kqlfrmg1LUZwGj7rsTBgTMhn65V966IigJ6s3zlWK9ixmhQ5H18xzE0ONNxESdF3aR5H38Wnp0bj43v8LqZbCsTBgTcqiGBojlnGJymQlDhG1lEakGViUdK9swAahsiNMh7BmQlDZ7RTEXdqZl18iwQIL68YonpIXOU0n)wGj7ZF711nVNkjBE(Ubw85vIwZl18308TKsatO18DfyEzNMxjyxM)2dWL53M6Q2opm(dzZZjxPl(8jFEKcqZl7Mop3RRlDjPY8snFlPeWeA(RmpF3alo0bChifcKwah4PuxbAPiIXOU0D2cmzpsQDZO18xM3vfBvB1iV8yhqjraHyPYNhEZ7pKn)L5V966IigJ6s3zlWK9iGqSu5ZdR5BAqc(DfixO5aoP2nJwbieWnNKLgWrmg1LUdW6fpafWxe3bYEjlnGJ9Tufl15X(gJ6s38nrGj7ZBY8gJnVKieF(UcmVStZ7h5afRaR5lW8yhQbinDExHHutLaUdKcbslGd8uQRaTueXyux6oBbMShj1Uz0A(lZdZ8UcdPMkrLCGIvG18OrpVRWqQPsevdqA68qp)L5V966IigJ6s3zlWK9iGqSu5ZdR5BAqc(DLRAO5aoP2nJwbieWnNKLgWrmg1LUdW6fpafWxe3bYEjlnGdjKtZJ9ng1LU591wV4bO5lDES7UPsHmpEQTEmdKsJ5Dgx4(mpIHk1255EaAEPMNByO5T557gynVuZZfZHAESVXOU0nFteyY(8z38E8uBNpLaUdKcbslGlgJuj2VBQuihEQTEmdKsJiP2nJwZFzEyMFvsSF3uPqo8uB9ygiLgrjDOsTDE0ON3vfBvB1y)UPsHC4P26XmqknIacXsLpp8M3FFzE0ON)U485VmVKi0rQZkP5H18UQyRARg73nvkKdp1wpMbsPreqiwQ85HE(lZdZ8WFEGNsDfOLIigJ6s3zlWK9iP2nJwZJg983EDDreJrDP7SfyYEKlMd18WA(RmpA0ZZlp2HVBG18WBE4Mh6Ge87kq(qZbCsTBgTcqiG7aPqG0c4IXivI8A7r2PdNOfpsQDZOva3CswAahXyux6oaRx8auqc(DfF1qZbCsTBgTcqiGBojlnGVawQhw2rb8fXDGSxYsd4qsGL68Ww2rZN85lL1yEBEij2fF(wl153MY(8nbLWKIDZO5HKesYP5vYaZJyW(8CXCO4X5BcDZ3LT7Y8jFE7U8K5LAEsxZVQ51sMhj58559KUsTDEzNMNlMdfpG7aPqG0c43EDDXujmPy3m6SiKKtrUyouZdV5BkKnpA0ZF711ftLWKIDZOZIqsof96N)Y83fNp)L57Y2D5aielv(8WA(MgKGFnfYcnhWj1Uz0kaHaU5KS0aUZySJ5KS0dl5saNLC5OgcfWDfgsnvcsWVMcxO5aoP2nJwbieWnNKLgWT2sBeWDGuiqAbCa1bi(UDZOaURHJrhXaTKWd(bxqc(1u)dnhWj1Uz0kaHaUdKcbslGBojXqNvjrpLl2nJowxhlDsw68BMhYMhn65L0Hk125VmpG6aeF3Uzua3CswAa3t5IDZOJ11XsNKLgKGFn9kHMd4KA3mAfGqa3CswAaNN97LEyzhfWDGuiqAbCa1bi(UDZOaURHJrhXaTKWd(bxqc(10MgAoGtQDZOvacbCZjzPbCxbaE9swAa3bsHaPfWbuhG472nJM)Y8Mtsm0Hucjj(8WA(MoFtopmZlgJujYRThzNoCIw8iP2nJwZJg98IXivI8SFV0dl7OiP2nJwZdDa31WXOJyGws4b)Glib)AQVeAoGtQDZOvacbCZjzPb8ogX3DaRtc4oqkeiTaoV8y3PUIykMjjJo8IHHujsQDZOvapvHaaVE5KDb8BVUUiMIzsYOdVyyivIE9bj4xtHCHMd4Pkea41lbC4c4MtYsd4lGL6HxESaoP2nJwbieKGFn9QgAoGBojlnGZ3TvT9CxmjGtQDZOvacbjib8Ea5kKBtcnh8dUqZbCsTBgTcqiG7aPqG0c4sIqZdV5HS5Vmp8NVNKOXsm08xMh(ZF711fBbjsLa6uDhU5azx6OOxFa3CswAaVJyNvHKQjzPbj4N)HMd4MtYsd4CpeKspDeB3tfceWj1Uz0kaHGe87kHMd4KA3mAfGqaxnekGlfcDQUdsPCbuE8JRuUa8CswkpGBojlnGlfcDQUdsPCbuE8JRuUa8Cswkpib)AAO5aoP2nJwbieWvdHc48Ir2o)WjhGKJqUDnVApkGBojlnGZlgz78dNCasoc5218Q9OGe8ZxcnhWj1Uz0kaHaUdKcbslGlgJuj2csKkb0P6oCZbYU0rrsTBgTc4MtYsd4TGePsaDQUd3CGSlDuqc(b5cnhWnNKLgW7yeF3bSojGtQDZOvacbj43vn0CaNu7MrRaec4vFaNtsa3CswAahJbs7MrbCmgZJc4Mtsm0zvs0vaGxVKLop8MhYM)Y8Mtsm0zvs0AlTX8WBEiB(lZBojXqNvjrpLl2nJowxhlDsw68WBEiB(lZdZ8WFEXyKkrE2Vx6HLDuKu7MrR5rJEEZjjg6SkjYZ(9spSSJMhEZdzZd98xMhM5xLe73nvkKdp1wpMbsPrushQuBNhn65H)8IXivI97MkfYHNARhZaP0isQDZO18qhWXyGJAiuaFvc)aiB1iib)G8HMd4KA3mAfGqaxnekGBqcW3nGXpDLkNQ70xBjqa3CswAa3GeGVBaJF6kvov3PV2sGGe8Zxn0CaNu7MrRaec4MtYsd4CIwNQ74kaWRxYsd4oqkeiTaoVNySJyGws4rorRt1DCfa41lzPhRO5H3M5VsaNLkDCRaoCqwqc(bhKfAoGBojlnGVBEQeWj1Uz0kaHGe8do4cnhWnNKLgW9uUy3m6yDDS0jzPbCsTBgTcqiibjGBffAo4hCHMd4MtYsd497MkfYHNARhZaP0iGtQDZOvacbj4N)HMd4MtYsd47MNkbCsTBgTcqiib)UsO5aoP2nJwbieWDGuiqAbCxHHutLigsL9gG5Vm)QKyI0t6k12JZeJlGQFNoRsIs6qLA78xM3vfBvB1i3dbP0ZYaOAzgGIaYwnM)Y8Wm)QKy)UPsHC4P26XmqknIacXsLpp8M3)5rJEE4pVymsLy)UPsHC4P26XmqknIKA3mAnp0ZJg98UcdPMkrnB3LtNrZFz(vjrE5XoGsIs6qLA78xM3vfBvB1i3dbP0ZYaOAzgGIaYwnM)Y8Wm)QKy)UPsHC4P26XmqknIacXsLpp8M3)5rJEE4pVymsLy)UPsHC4P26XmqknIKA3mAnp0ZJg98WmVRWqQPsujhOyfynpA0Z7kmKAQer1aKMopA0Z7kmKAQe1sP5HE(lZVkj2VBQuihEQTEmdKsJOKouP2o)L5xLe73nvkKdp1wpMbsPreqiwQ85H18(hWnNKLgWDgJDmNKLEyjxc4SKlh1qOa(YaOAzgGo9aQpib)AAO5aoP2nJwbieWDGuiqAbCXyKkrET9i70Ht0Ihj1Uz0A(lZ7m9WjAfWnNKLgW5eTov3XvaGxVKLgKGF(sO5aoP2nJwbieWDGuiqAbC4pVymsLiV2EKD6WjAXJKA3mAn)L5H)8RsICIwNQ74kaWRxYsJs6qLA78xMh(ZN6PJLT7Y8xMFvs0vaGxVKLgbuhG472nJc4MtYsd4CIwNQ74kaWRxYsdsWpixO5aoP2nJwbieWnNKLgWT2sBeWDGuiqAbCZjjg6SkjATL2yEynFtN)Y8WF(vjrRT0grjDOsTnG7A4y0rmqlj8GFWfKGFx1qZbCsTBgTcqiGBojlnGBTL2iG7aPqG0c4Mtsm0zvs0AlTX8WBZ8nD(lZdOoaX3TBgn)L5xLeT2sBeL0Hk12aURHJrhXaTKWd(bxqc(b5dnhWj1Uz0kaHaUdKcbslGBojXqNvjrpLl2nJowxhlDsw68BMhYMhn65L0Hk125VmpG6aeF3Uzua3CswAa3t5IDZOJ11XsNKLgKGF(QHMd4KA3mAfGqa3CswAa3t5IDZOJ11XsNKLgWDGuiqAbC4pVKouP2o)L57X0lgJujcmKEtLJ11XsNKLYJKA3mAn)L5nNKyOZQKONYf7MrhRRJLojlDEyn)vc4UgogDed0scp4hCbj4hCqwO5aoP2nJwbieWDGuiqAbCE5Xo8DdSMhEZdxa3CswAahtYOJyPkbj4hCWfAoGtQDZOvacbChifcKwah(Z7kmKAQevYbkwbwbCUasNe8dUaU5KS0aUZySJ5KS0dl5saNLC5OgcfWDfgsnvcsWp48p0CaNu7MrRaec4oqkeiTaomZ7kmKAQeXqQS3am)L5HzExvSvTvJjspPRuBpotmUaQ(DkciB1yE0ONFvsmr6jDLA7XzIXfq1VtNvjrjDOsTDEON)Y8UQyRARg5EiiLEwgavlZaueq2QX8xMhM5xLe73nvkKdp1wpMbsPreqiwQ85H38(ppA0Zd)5fJrQe73nvkKdp1wpMbsPrKu7MrR5HEEON)Y8WmpmZ7kmKAQevYbkwbwZJg98UcdPMkrunaPPZJg98UcdPMkrTuAEON)Y8UQyRARg5EiiLEwgavlZaueqiwQ85H18(p)L5Hz(vjX(DtLc5WtT1JzGuAebeILkFE4nV)ZJg98WFEXyKkX(DtLc5WtT1JzGuAej1Uz0AEONh65rJEEyM3vyi1ujQz7UC6mA(lZdZ8UQyRARg5Lh7akjciB1yE0ONFvsKxESdOKOKouP2op0ZFzExvSvTvJCpeKspldGQLzakcielv(8WAE)N)Y8Wm)QKy)UPsHC4P26XmqknIacXsLpp8M3)5rJEE4pVymsLy)UPsHC4P26XmqknIKA3mAnp0ZdDa3CswAa3zm2XCsw6HLCjGZsUCudHc4ldGQLza60dO(Ge8dUReAoGtQDZOvacbChifcKwa)U485VmVRk2Q2QrUhcsPNLbq1YmafbeILkFE4nFx2UlhaHyPYN)Y8Wmp8NxmgPsSF3uPqo8uB9ygiLgrsTBgTMhn65DvXw1wn2VBQuihEQTEmdKsJiGqSu5ZdV57Y2D5aielv(8qhWnNKLgWxga1HxESGe8dUMgAoGtQDZOvacbChifcKwa)U485VmVRk2Q2QrUhcsPNLbq1YmafbeILkFEioVRk2Q2QrUhcsPNLbq1YmafxEatYsNhwZ3LT7YbqiwQ8aU5KS0a(YaOo8YJfKGFW5lHMd4KA3mAfGqa3CswAa3zm2XCsw6HLCjGZsUCudHc4Pqibj4hCqUqZbCsTBgTcqiGBojlnG7mg7yojl9WsUeWzjxoQHqb8fXSg06iGurrcpib)G7QgAoGtQDZOvacbCZjzPbCNXyhZjzPhwYLaol5YrnekGVmeRLocivuKWdsWp4G8HMd4KA3mAfGqa3bsHaPfWxLe73nvkKdp1wpMbsPrushQuBNhn65H)8IXivI97MkfYHNARhZaP0isQDZOvaNlG0jb)GlGBojlnG7mg7yojl9WsUeWzjxoQHqbCUyYraPIIeEqc(bNVAO5aoP2nJwbieWDGuiqAb8vjrmjJoILQeL0Hk12aU5KS0aoIXOU0DawV4bOGe8ZFil0CaNu7MrRaec4oqkeiTa(QKiV8yhqjrjDOsTD(lZd)5fJrQe512JSthorlEKu7MrRaU5KS0aoIXOU0DawV4bOGe8ZF4cnhWj1Uz0kaHaUdKcbslGd)5fJrQeXKm6iwQsKu7MrRaU5KS0aoIXOU0DawV4bOGe8ZF)dnhWj1Uz0kaHaUdKcbslGZlp2HVBG18WB(MgWnNKLgWrmg1LUdW6fpafKGF(FLqZbCsTBgTcqiGBojlnGZZ(9spSSJc4oqkeiTaU5KedDwLe5z)EPhw2rZdRnZFL5VmpG6aeF3Uz08xMh(ZVkjYZ(9spSSJIs6qLABa31WXOJyGws4b)Glib)8VPHMd4KA3mAfGqa3bsHaPfWDfgsnvIk5afRaRaoxaPtc(bxa3CswAa3zm2XCsw6HLCjGZsUCudHc4UcdPMkbj4N)(sO5aoP2nJwbieWDGuiqAb8BVUUyQeMuSBgDwesYPixmhQ5H3M59fiBE0ON)U485Vm)Txxxmvctk2nJolcj5u0RF(lZ3LT7YbqiwQ85H18(Y8Orp)Txxxmvctk2nJolcj5uKlMd18WBZ8xXxM)Y8RsI8YJDaLeL0Hk12aU5KS0a(cyPEyzhfKGF(d5cnhWj1Uz0kaHaU5KS0aEhJ47oG1jbChifcKwaNxES7uxrmfZKKrhEXWqQej1Uz0kGNQqaGxVCYUa(TxxxetXmjz0HxmmKkrV(Ge8Z)RAO5aEQcbaE9sahUaU5KS0a(cyPE4LhlGtQDZOvacbj4N)q(qZbCZjzPbC(UTQTN7IjbCsTBgTcqiibjGNcHeAo4hCHMd4MtYsd4EC6KcHWd4KA3mAfGqqcsaNtHMd(bxO5aU5KS0a(U5PsaNu7MrRaecsWp)dnhWj1Uz0kaHaEQcbaE9Yj7c4l62RRlY3TvT9qi3aZrrUyouWBZvc4MtYsd4lGL6HxESaEQcbaE9YPLv3glGdxqc(DLqZbCZjzPbC(UTQTN7IjbCsTBgTcqiibjGZftocivuKWdnh8dUqZbCsTBgTcqiGRgcfWtL7aEIDZOZv7zQ4HCweM0rbCZjzPb8u5oGNy3m6C1EMkEiNfHjDuqc(5FO5aoP2nJwbieWvdHc4PYfGNtka)SsmPsNBIXc4MtYsd4PYfGNtka)SsmPsNBIXcsWVReAoGtQDZOvacbC1qOaEHHaDSABQThtte74SwkGBojlnGxyiqhR2MA7X0eXooRLcsWVMgAoGtQDZOvacbC1qOa(YaOqQsplYH607jaI7i1rbCZjzPb8LbqHuLEwKd1P3tae3rQJcsWpFj0CaNu7MrRaec4QHqbCeZz3a6W3jsoiE80fWnNKLgWrmNDdOdFNi5G4Xtxqc(b5cnhWj1Uz0kaHaUAiuaVJzi0P6o3MimkGBojlnG3Xme6uDNBtegfKGFx1qZbCsTBgTcqiGRgcfW3AOiLa8thO0va3CswAaFRHIucWpDGsxbj4hKp0CaNu7MrRaec4QHqbCXUzKCQUZI49wcc4MtYsd4IDZi5uDNfX7TeeKGF(QHMd4KA3mAfGqaxnekGZtTZJDmEFcmv4NBB1sNQ70rGYLsJaU5KS0aop1op2X49jWuHFUTvlDQUthbkxkncsWp4GSqZbCsTBgTcqiGRgcfW5P25XoTmBLMua(52wT0P6oDeOCP0iGBojlnGZtTZJDAz2knPa8ZTTAPt1D6iq5sPrqc(bhCHMd4MtYsd43SQwNopqJaoP2nJwbieKGFW5FO5aU5KS0aExcOBwvRaoP2nJwbieKGFWDLqZbCZjzPb8BcWjaQuBd4KA3mAfGqqcsqc4MNSxGaoEIaPbjiHaa]] )


end