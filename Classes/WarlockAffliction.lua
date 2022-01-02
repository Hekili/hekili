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


    spec:RegisterPack( "Affliction", 20211227, [[deLlFdqikvSicuepcsKnbI(ebmkivNcszvGa8kvrMfHYTufODjXVuf1WGeCmiPLjj8mkv10uf01OujBdKk9ncu14ab5CuQuzDqIAEGuUNK0(iqoibQSqvHEiiKjQkGlcsf2iiG6JGasJeeqCscuALGKxsGIKzcsv3eeu7Kq1pbPIgkiqlLsLYtHyQsIUkLkvTvcuOVcjuJLsv2RG)QQgSkhMQfRk9ykMSsDzKnlKpReJwsDArRMaf1RjOzd1Tb1Uj9BfdxjDCiHSCGNt00rDDkz7eY3fQgpiuNxOSEcuW8PuUpbksTFPoGAOYaY2zkiEfOqfvGcOIcvuqfcvbecfEyaHJTsbKv3i0xOaI6WuarWffHtdNJgqw9y4X3HkdiYXcyOasnZRsu(5NxsU26Tyg4NLjSf25CudWJ4NLjS55aYRvIzbRgEdiBNPG4vGcvubkGkkurbviufqOaICLmbXRa6AxbK6CVjn8gq2K0eqeCrr40W5O9HIDaEmcBOEaYqWVeOVke8I1xfOqfO2q1qbr1UUqsuUH6b7tWT30UpKvcJ7d6hJWsd1d2NGBVPDFpajASa9bH9L0uAOEW(eC7nT77fqUqtTRkH7dplPPVOb03da8u7dzSWLgQhSVkJtUW(GWoMIstF2nFLTauF4zjn9XtFXhGW(YO(InwcaO(GtPm1L(8(yhtk3xQ9X1o3hyIxAOEW(Gou)ft9z3C4vx5(eCrr40W5OY(GGIGG9XoMuU0q9G9vzCYfk7JN(CrtU77fpXtDPVhWbcxWoG6l1(GTWC(GSdwiUV4pp99aqNvk7ZAT0q9G9brJUjvs9jhyQVhWbcxWoG6dccO1(mogl7JN(a02Yq9zg4vl25C0(4eMknupyFie3NCGP(mog)DdNJ(XPK7JugKKSpE6tYG0W9XtFUOj39zQjJWux6dNsw2hx7CFXhvaUVxQpa5MAA3h6(INQDqR0q9G9bDQ4y9Hq0UVrnuFRa6bxTW4sd1d2NGBly2sY9jyYRfq7dIEazFVu0aO(iD33e1xuUuZcM0hEwstF80NVUIJ13O4y9XtFVJu2xuUuZY(qxhUpg4Y6(wDJqjALgQhSpiWyswBaEe)SGXb7CIP(qgSis5(mUAi8pJ6Zu76cT7JN(sLjaWAL)zuPH6b7tWQmTaCM6tCYaM(GWO4(wb5asowF4uYLaYkyIsmfqqjuQpbxueonCoAFOyhGhJWgkucL67bidb)sG(QqWlwFvGcvGAdvdfkHs9br1UUqsuUHcLqP(EW(eC7nT7dzLW4(G(XiS0qHsOuFpyFcU9M299aKOXc0he2xstPHcLqP(EW(eC7nT77fqUqtTRkH7dplPPVOb03da8u7dzSWLgkucL67b7RY4KlSpiSJPO00NDZxzla1hEwstF80x8biSVmQVyJLaaQp4uktDPpVp2XKY9LAFCTZ9bM4LgkucL67b7d6q9xm1NDZHxDL7tWffHtdNJk7dckcc2h7ys5sdfkHs99G9vzCYfk7JN(CrtU77fpXtDPVhWbcxWoG6l1(GTWC(GSdwiUV4pp99aqNvk7ZAT0qHsOuFpyFq0OBsLuFYbM67bCGWfSdO(GGaATpJJXY(4PpaTTmuFMbE1IDohTpoHPsdfkHs99G9HqCFYbM6Z4y83nCo6hNsUpszqsY(4Ppjdsd3hp95IMC3NPMmctDPpCkzzFCTZ9fFub4(EP(aKBQPDFO7lEQ2bTsdfkHs99G9bDQ4y9Hq0UVrnuFRa6bxTW4sdfkHs99G9j42cMTKCFcM8Ab0(GOhq23lfnaQps39nr9fLl1SGj9HNL00hp95RR4y9nkowF8037iL9fLl1SSp01H7JbUSUVv3iuIwPHcLqP(EW(GaJjzTb4r8ZcghSZjM6dzWIiL7Z4QHW)mQptTRl0UpE6lvMaaRv(NrLgkucL67b7tWQmTaCM6tCYaM(GWO4(wb5asowF4uYLgQgk3W5OYYkGmd8RZvJi8FpWP6CoQyzuvoHjbHcqANvIloofrqANxROOYciHNeq)j6lDdiJsdvSwBOCdNJklRaYmWVo)u1NLwWWJ(xjUHYnCoQSSciZa)68tvF2ss)KjyXuhMQYdm9NOp8OsgmwYVzujdSmCoQSHYnCoQSSciZa)68tvF2ss)KjyXuhMQkhm51YVKmaI)mzQ1efzrnuUHZrLLvazg4xNFQ6ZlGeEsa9NOV0nGmknKyzuv2XKYLfqcpjG(t0x6gqgLgQqQ)IPDdLB4CuzzfqMb(15NQ(CeMK1gGhXnuUHZrLLvazg4xNFQ6ZICq6Vysm1HPQ7HLFa57yIjYXwuv3WPi6VhUygaWALZrfekaPB4ue93dx8LrJjiuas3WPi6VhUyPs2FX03JIWPHZrfekaj62HDmPCrMR1J(Xzevi1FX02Mn3WPi6VhUiZ16r)4mIeekGgKOVhUSw7kpWFzQlwyhKCScNgHPUyZMDyhtkxwRDLh4Vm1flSdsowHu)ftB0AOCdNJklRaYmWVo)u1NTK0pzcwm1HPQUGbzTdC5pAu(pr)1jobAOCdNJklRaYmWVo)u1NLeT)t03maG1kNJkgov6B2vrffelJQkxjm(ZoyHyzrs0(prFZaawRCo63hsqvTFdLB4CuzzfqMb(15NQ(CTBPCdLB4CuzzfqMb(15NQ(SLkz)ftFpkcNgohTHQHcLqP(GoGyYyX0UpsebI1hNWuFCn1NB4b0xk7Zf5j2FXuPHYnCoQSQCLW4pEmcBOCdNJkFQ6ZBs0yb(W(sAAOCdNJkFQ6ZghJ)UHZr)4uYIPomv1hsmjdsdxfvXYOQUHtr0NucojPGSFdfk1he5yCFsA1bot95gohTpCk5(IgqFItgWGhWUpimkUVu7dPYsFqKfaqkJJ13O4y9nRCcNcgODFrdOplj1x8KR7dcIuAOCdNJkFQ6Zal97goh9JtjlM6WuvLmG5dhxmjdsdxfvXYOQMrePUYfLmGbpGnKalLIgWcvGDmfLMFCGZ1q6gofrFsj4KKvrfs2XKYL1Ax5b(ltDXc7GKJ1qHs9j4mCoAF4uYY(IgqFmivHe33lv7IYbu6dHDw2NdO(KUiA3x0a67LIga1hYyH7ZUn8Zcw4vs3PU0he5SlzWSwtpdbRDLh4(qsDXc7GKJjwFdxtG4PK6B0(mZG3tCT0q5gohv(u1Nnog)DdNJ(XPKftDyQkdsviXF5ko5VPMmcBOCdNJkFQ6ZghJ)UHZr)4uYIPomvDtypgT)mivHelBOCdNJkFQ6ZghJ)UHZr)4uYIPomvvYo)zqQcjwkMKbPHRIQyzuv03dxKJf(dgUWPryQl2SThUKWRKUtD5BC2LmywRP)E4cNgHPUyZ2E4YATR8a)LPUyHDqYXkCAeM6cAqkhl8xw7GTGSVnB7HlIsm9zpvUWPryQl2SXoMuUiN4FUM(sI2Ygk3W5OYNQ(SXX4VB4C0poLSyQdtv3oSVqFgKQqILILrvnJisDLlAUuZ)iNGeD7iYbP)IPcdsviXF5kozB2mZG3tCTihl8hmCbqWEQsbvbkyZg6ICq6VyQWGufs8FucsZm49exlYXc)bdxaeSNQeAmivHexqTyMbVN4AbqWEQs0SzdDroi9xmvyqQcj(ZXhinZG3tCTihl8hmCbqWEQsOXGufsCPIIzg8EIRfab7PkrdnB2mJisDLlIiLRJbGeD7iYbP)IPcdsviXF5kozB2mZG3tCTKWRKUtD5BC2LmywRPcGG9uLcQcuWMn0f5G0FXuHbPkK4)OeKMzW7jUws4vs3PU8no7sgmR1ubqWEQsOXGufsCb1Izg8EIRfab7PkrZMn0f5G0FXuHbPkK4phFG0mdEpX1scVs6o1LVXzxYGzTMkac2tvcngKQqIlvumZG3tCTaiypvjAOzZg6MrePUYfLmGbpGTnBMrePUYfHXaPR2SzgrK6kx0rj0GeD7iYbP)IPcdsviXF5kozB2mZG3tCTSw7kpWFzQlwyhKCScGG9uLcQcuWMn0f5G0FXuHbPkK4)OeKMzW7jUwwRDLh4Vm1flSdsowbqWEQsOXGufsCb1Izg8EIRfab7PkrZMn0f5G0FXuHbPkK4phFG0mdEpX1YATR8a)LPUyHDqYXkac2tvcngKQqIlvumZG3tCTaiypvjAOzZMDyhtkxwRDLh4Vm1flSdsowHu)ftBir3oICq6VyQWGufs8xUIt2MnZm49exlsly4r)BhiCb7aQaiypvPGQafSzdDroi9xmvyqQcj(pkbPzg8EIRfPfm8O)TdeUGDavaeSNQeAmivHexqTyMbVN4AbqWEQs0SzdDroi9xmvyqQcj(ZXhinZG3tCTiTGHh9VDGWfSdOcGG9uLqJbPkK4sffZm49exlac2tvIgAnuOuFpAb0(KJfUpzTd2Y(YO(IYLAUVu2NJHhj33iIanuUHZrLpv9zyhtrP5d8v2cqILrvFhPeYOCPM)ac2tvcncIjJftFoHjia5yH)YAhSHCpCXsLS)IPVhfHtdNJw40im1LgkuQpbBuFMrePUY9Th(ziyTR8a3hsQlwyhKCS(szFalvtDrS(SKuFpGdeUGDa1hp9rqmt6UpUM6ZybaKY9jjUHYnCoQ8PQpBCm(7goh9JtjlM6Wu1TdeUGDa9xb0Qyzuv0nJisDLlIiLRJbGCpCjHxjDN6Y34SlzWSwt)9WfonctDbsZm49exlsly4r)BhiCb7aQaiypvj0Qas03dxwRDLh4Vm1flSdsowbqWEQsbvHnB2HDmPCzT2vEG)YuxSWoi5yOHMnBOBgrK6kx0CPM)rob5E4ICSWFWWfonctDbsZm49exlsly4r)BhiCb7aQaiypvj0Qas03dxwRDLh4Vm1flSdsowbqWEQsbvHnB2HDmPCzT2vEG)YuxSWoi5yOHMnBOJUzerQRCrjdyWdyBZMzerQRCrymq6QnBMrePUYfDucni3dxwRDLh4Vm1flSdsowHtJWuxGCpCzT2vEG)YuxSWoi5yfab7PkHwfO1qHs9z3OiajR7BpSSpYb4y9Lr9TmPU0xQ80N3NS2b7(KRKUtDPV1AxsnuUHZrLpv9zJJXF3W5OFCkzXuhMQUh(VcOvXYOQOBgrK6kx0CPM)robPD2dxKJf(dgUWPryQlqAMbVN4Arow4py4cGG9uLq7HOzZg6MrePUYfrKY1XaqAN9WLeEL0DQlFJZUKbZAn93dx40im1finZG3tCTKWRKUtD5BC2LmywRPcGG9uLq7HOzZg6OBgrK6kxuYag8a22SzgrK6kxegdKUAZMzerQRCrhLqds2XKYL1Ax5b(ltDXc7GKJbPD2dxwRDLh4Vm1flSdsowHtJWuxG0mdEpX1YATR8a)LPUyHDqYXkac2tvcThIwdfk1NGnQpiyTR8a3hsQlwyhKCS(szFCAeM6Iy9LCFPSpPhr9XtFwsQVhWbc7dzSWnuUHZrLpv95Tde(LJfwSmQ6E4YATR8a)LPUyHDqYXkCAeM6sdLB4Cu5tvFE7aHF5yHflJQAh2XKYL1Ax5b(ltDXc7GKJbj67HlYXc)bdx40im1fB22dxs4vs3PU8no7sgmR10FpCHtJWuxqRHcL6djMA6dcw7kpW9HK6If2bjhRV4jx3NGrs56yGNfpxQ5(Ga7uFMrePUY9ThwS(gUMaXtj1NLK6B0(mZG3tCT0NGnQpOd41yaYX9bDc2QRgQVxROO(szFPAg4uxeRV6bV7Zs5e3xYci7dq(owFOJkeQpjzgDl7ZJyc0NLKqRHYnCoQ8PQpVw7kpWFzQlwyhKCmXYOQMrePUYfnxQ5FKtqYjmji7csZm49exlYXc)bdxaeSNQeAOcj6mivHexi41yaYX)bSvxnuXmdEpX1cGG9uLqdvOBf2SzhcfzLRR0UqWRXaKJ)dyRUAi0AOCdNJkFQ6ZR1UYd8xM6If2bjhtSmQQzerQRCrePCDmaKCctcYUG0mdEpX1scVs6o1LVXzxYGzTMkac2tvcnuHeDgKQqIle8Ama54)a2QRgQyMbVN4AbqWEQsOHk0TcB2SdHISY1vAxi41yaYX)bSvxneAnuOuFItgWGhWUV4jx3he2XuuA6dfdCUUpJlzzFR1UYdCFYuxSWoi5y9LAF4uP(INCDFpazsyNtDPVhhm3q5gohv(u1NxRDLh4Vm1flSdsoMyzuvZiIux5IsgWGhWgsGLsrdyHkWoMIsZpoW5Ai5eMeKDbPzg8EIRLnzsyNtD5)oyUaiypvj0SpKOZGufsCHGxJbih)hWwD1qfZm49exlac2tvcnuHUvyZMDiuKvUUs7cbVgdqo(pGT6QHqRHcL6d6KRjqFMrePUYY(qpvd2AN6sF6Opiegf3N4KbmO1NXLCFqqK(gTpZm49exBOCdNJkFQ6ZR1UYd8xM6If2bjhtSmQk6MrePUYfHXaPR2SzgrK6kx0rjB2q3mIi1vUOKbm4bSH0oalLIgWcvGDmfLMFCGZ1OHgKOZGufsCHGxJbih)hWwD1qfZm49exlac2tvcnuHUvyZMDiuKvUUs7cbVgdqo(pGT6QHqRHYnCoQ8PQpVw7kpWFzQlwyhKCmXYOQVJuczuUuZFab7PkHgQq3gkuQpbBuFqWAx5bUpKuxSWoi5y9LY(40im1fX6lzbK9Xjm1hp9zjP(gUMa9b7cMhqF7HLnuUHZrLpv9zJJXF3W5OFCkzXuhMQAgrK6klMKbPHRIQyzu19WL1Ax5b(ltDXc7GKJv40im1fir3mIi1vUO5sn)JCYMnZiIux5Iis56ya0AOCdNJkFQ6Z(YOXeZeZGPp7GfILvrvSmQ6E4IVmAScGG9uLq7HnuUHZrLpv95A3s5gkuQpKjEFCn1hcrBzFJ2N97JDWcXY(YO(sUVuQcW9zSaaszCS(sTViCUuZ9nG(gTpUM6JDWcXL(qXjx3hsUwpAFqFgr9LSaY(CSC67LyMa9XtFwsQpeI29nIiqFWUA5yCS(81vCSux6Z(9brdayTY5OYsdLB4Cu5tvFws0(prFZaawRCoQyzuv3WPi6tkbNKuqvaj7ys5ICI)5A6ljAlH0o7HlsI2)j6BgaWALZrlCAeM6cK2j1FeoxQ5gk3W5OYNQ(SKO9FI(MbaSw5CuXYOQUHtr0NucojPGQas2XKYfzUwp6hNreK2zpCrs0(prFZaawRCoAHtJWuxG0oP(JW5snd5E4IzaaRvohTaiypvj0EydLB4Cu5tvFwuIPp7PYILrvrxow4VS2bBbHQnBUHtr0NucojPGQaninZG3tCTiTGHh9VDGWfSdOcGG9uLcc1kAOCdNJkFQ6ZwQK9xm99OiCA4CuXYOQUHtr0FpCXsLS)IPVhfHtdNJwffSzJtJWuxGCpCXsLS)IPVhfHtdNJwaeSNQeApSHYnCoQ8PQplZ16r)4mIeZeZGPp7GfILvrvSmQ6E4ImxRh9JZiQaiypvj0EydLB4Cu5tvF24y83nCo6hNswm1HPQMrePUYIjzqA4QOkwgv1oMrePUYfLmGbpGDdfk1NGBDfhRpiAaaRvohTpyxTCmowFJ2hQpyf9XoyHyPy9nG(gTp73x8KR7tW9khSft9brdayTY5OnuUHZrLpv9zZaawRCoQyMygm9zhSqSSkQILrvDdNIOpPeCssO9WheD2XKYf5e)Z10xs0wAZg7ys5ImxRh9JZicni3dxmdayTY5Ofab7PkHwfnuOuFcUiMa9X1uFZkPeqS(KRKU7Z7tw7GDFXRjTpN7ZU6B0(GWoMIstF2nFLTauF80NlAYDFJicy811uxAOCdNJkFQ6ZWoMIsZh4RSfGelJQkhl8xw7GTGEiKCctcQcuBOqP(qX1K2NoCFYyQj1L(GG1UYdCFiPUyHDqYX6JN(emskxhd8S45sn3heyNeRpely4r77bCGWfSdO(YO(CmUV9WY(Ca1NVUItA3q5gohv(u1Nnog)DdNJ(XPKftDyQ62bcxWoG(RaAvSmQk6MrePUYfrKY1XaqAh2XKYL1Ax5b(ltDXc7GKJb5E4scVs6o1LVXzxYGzTM(7HlCAeM6cKMzW7jUwKwWWJ(3oq4c2bubq(ogA2SHUzerQRCrZLA(h5eK2HDmPCzT2vEG)YuxSWoi5yqUhUihl8hmCHtJWuxG0mdEpX1I0cgE0)2bcxWoGkaY3XqZMn0r3mIi1vUOKbm4bSTzZmIi1vUimgiD1MnZiIux5IokHgKMzW7jUwKwWWJ(3oq4c2bubq(ogAnuOuF29sQVhWbc7dzSW9Lr99aoq4c2buFXhvaUVxQpa57y95lEQI13a6lJ6JRja1x8eJ77L6Z5(WKl5(QOp4bq99aoq4c2buFwss2q5gohv(u1N3oq4xowyXYOQVJucPzg8EIRfPfm8O)TdeUGDavaeSNQuqr5sn)beSNQes0Td7ys5YATR8a)LPUyHDqYXSzZmdEpX1YATR8a)LPUyHDqYXkac2tvkOOCPM)ac2tvIwdLB4Cu5tvFE7aHF5yHflJQ(osjK2HDmPCzT2vEG)YuxSWoi5yqAMbVN4ArAbdp6F7aHlyhqfab7PkFYmdEpX1I0cgE0)2bcxWoGkBlGZ5OqlkxQ5pGG9uLnuOuFqKZM6h0X4(sMG7Zs6luFrdOpxJX1PU0NoCFYvYKrjT7JWskEnbOgk3W5OYNQ(SXX4VB4C0poLSyQdtvtMGBOqjuQp7gfbizDFi1(EI3h0b8lWnuFVu0aO(KRKUtDPpzTd2Y(gTpiSJPO00NDZxzla1q5gohv(u1Nnog)DdNJ(XPKftDyQQKelJQYoMuUiR99e)tWVa3qfs9xmTHe9n9AffvK1(EI)j4xGBOIKDJqOHEfpOB4C0IS23t8)7G5sQ)iCUuZOzZ2METIIkYAFpX)e8lWnubqWEQsOzF0AOqP(S7LuFqyhtrPPp7MVYwaQV41K2hSlyEa9Thw2NdO(SwfRVb0xg1hxtaQV4jg33l1Nmx0mknUY9Xjm1NLYjUpUM6tjiM7dcw7kpW9HK6If2bjhR0NGnQploXPGHux6dc7ykkn9HIboxlwF1dE3N3NS2b7(4PpafbizDFCn13RvuudLB4Cu5tvFg2XuuA(aFLTaKyzuv03dxeLy6ZEQCHtJWuxSzBpCjHxjDN6Y34SlzWSwt)9WfonctDXMT9Wf5yH)GHlCAeM6cAqIUDawkfnGfQa7ykkn)4aNRTz71kkQa7ykkn)4aNRls2ncHM9Tztow4VS2bBbHkAnuOuF29sQpiSJPO00NDZxzla1hp9b7PYEQ9X1uFWoMIstFXbox33RvuuFwkN4(K1oyl7tjA3hp99s9TqkbCM29fnG(4AQpLGyUVxlGK7lEQ7jEFOxbk0NKmJUL9LY(Gha1hx7AFsROO0KKY9XtFlKsaNP(SFFYAhSLO1q5gohv(u1NHDmfLMpWxzlajwgvfyPu0awOcSJPO08JdCUgsZm49exlYXc)bdxaeSNQuqvGcq(AffvGDmfLMFCGZ1fab7PkH2dBOqP(GWEQSNAFqyhtrPPpumW56(CUphJ7Jtys2x0a6JRP(eNmGbpGDFdOpbtfdKU2NzerQRCdLB4Cu5tvFg2XuuA(aFLTaKyzuvGLsrdyHkWoMIsZpoW5Air3mIi1vUOKbm4bSTzZmIi1vUimgiDfniFTIIkWoMIsZpoW56cGG9uLq7HnuOuF29sQpiSJPO00NDZxzla13O9bbRDLh4(qsDXc7GKJ1NXLSuS(GDHPU0N0cq9XtFsxe1N3NS2b7(4Ppj7gH9bHDmfLM(qXaNR7lJ6ZsM6sFj3q5gohv(u1NHDmfLMpWxzlajwgvLDmPCzT2vEG)YuxSWoi5yqI(E4YATR8a)LPUyHDqYXkCAeM6InBMzW7jUwwRDLh4Vm1flSdsowbqWEQsbvHDzZ27iLqYjm955VtcAMzW7jUwwRDLh4Vm1flSdsowbqWEQs0GeD7aSukAalub2XuuA(XboxBZ2Rvuub2XuuA(XboxxKSBecn7BZMCSWFzTd2ccv0AOCdNJkFQ6ZWoMIsZh4RSfGelJQYoMuUiN4FUM(sI2YgkuQVha4P2h0NruFPSVrXX6Z77bGGi9T4P2x8KR7tWQKOK9xm13dqWPK6tjh0hSdX9jz3iuw6tWg1xuUuZ9LY(83XI7JN(iD33E6thUp4uk7tUs6o1L(4AQpj7gHYgk3W5OYNQ(8g4P(Xzejwgv91kkQKkjkz)ft)nbNsQiz3iuqpefSz71kkQKkjkz)ft)nbNsQyTc57iLqgLl18hqWEQsO9Wgk3W5OYNQ(SXX4VB4C0poLSyQdtvnJisDLBOCdNJkFQ6Z(YOXeZeZGPp7GfILvrvSmQkGIaKS2FXudLB4Cu5tvF2sLS)IPVhfHtdNJkwgv1nCkI(7HlwQK9xm99OiCA4C0QOGnBCAeM6cKakcqYA)ftnuUHZrLpv9zzUwp6hNrKyMygm9zhSqSSkQILrvbueGK1(lMAOCdNJkFQ6ZMbaSw5CuXmXmy6ZoyHyzvuflJQcOiajR9xmbPB4ue9jLGtscTh(GOZoMuUiN4FUM(sI2sB2yhtkxK5A9OFCgrO1q5gohv(u1NJWKS2a8iwSmQQCSWVPUlIgSZjM(YblIuwSuzcaSw5Fgv91kkQiAWoNy6lhSis5I1AdLB4Cu5tvFEd8u)YXclwQmbawRCvuBOCdNJkFQ6ZYAFpX)VdMBOAOCdNJkl(qvxRDLh4Vm1flSdsowdLB4CuzXh6PQpx7wk3q5gohvw8HEQ6ZghJ)UHZr)4uYIPomvD7aHlyhq)vaTkwgv1mIi1vUiIuUogaY9WLeEL0DQlFJZUKbZAn93dx40im1finZG3tCTiTGHh9VDGWfSdOcG8DmirFpCzT2vEG)YuxSWoi5yfab7Pkfuf2Szh2XKYL1Ax5b(ltDXc7GKJHMnBMrePUYfnxQ5FKtqUhUihl8hmCHtJWuxG0mdEpX1I0cgE0)2bcxWoGkaY3XGe99WL1Ax5b(ltDXc7GKJvaeSNQuqvyZMDyhtkxwRDLh4Vm1flSdsogA2SHUzerQRCrjdyWdyBZMzerQRCrymq6QnBMrePUYfDucni3dxwRDLh4Vm1flSdsowHtJWuxGCpCzT2vEG)YuxSWoi5yfab7PkHwfnuUHZrLfFONQ(SKO9FI(MbaSw5CuXYOQSJjLlYj(NRPVKOTesJRFjr7gk3W5OYIp0tvFws0(prFZaawRCoQyzuv7WoMuUiN4FUM(sI2siTZE4IKO9FI(MbaSw5C0cNgHPUaPDs9hHZLAgY9WfZaawRCoAbqrasw7VyQHYnCoQS4d9u1N9LrJjMjMbtF2blelRIQyzuv3WPi6VhU4lJgdApes7ShU4lJgRWPryQlnuUHZrLfFONQ(SVmAmXmXmy6ZoyHyzvuflJQ6gofr)9WfFz0ycQ6dHeqrasw7VycY9WfFz0yfonctDPHYnCoQS4d9u1NTuj7Vy67rr40W5OILrvDdNIO)E4ILkz)ftFpkcNgohTkkyZgNgHPUajGIaKS2FXudLB4CuzXh6PQpBPs2FX03JIWPHZrfZeZGPp7GfILvrvSmQQD40im1fixfTYoMuUaC4vx5VhfHtdNJklK6VyAdPB4ue93dxSuj7Vy67rr40W5OqZ(nuUHZrLfFONQ(SOetF2tLflJQkhl8xw7GTGqTHYnCoQS4d9u1Nnog)DdNJ(XPKftDyQQzerQRSysgKgUkQILrvTJzerQRCrjdyWdy3q5gohvw8HEQ6ZghJ)UHZr)4uYIPomvD7aHlyhq)vaTkwgvfDZiIux5Iis56yair3mdEpX1scVs6o1LVXzxYGzTMkaY3XSzBpCjHxjDN6Y34SlzWSwt)9WfonctDbninZG3tCTiTGHh9VDGWfSdOcG8DmirFpCzT2vEG)YuxSWoi5yfab7Pkfuf2Szh2XKYL1Ax5b(ltDXc7GKJHgAqIo6MrePUYfLmGbpGTnBMrePUYfHXaPR2SzgrK6kx0rj0G0mdEpX1I0cgE0)2bcxWoGkac2tvcTkGe99WL1Ax5b(ltDXc7GKJvaeSNQuqvyZMDyhtkxwRDLh4Vm1flSdsogAOzZg6MrePUYfnxQ5FKtqIUzg8EIRf5yH)GHlaY3XSzBpCrow4py4cNgHPUGgKMzW7jUwKwWWJ(3oq4c2bubqWEQsOvbKOVhUSw7kpWFzQlwyhKCScGG9uLcQcB2Sd7ys5YATR8a)LPUyHDqYXqdTgk3W5OYIp0tvFE7aHF5yHflJQ(osjKMzW7jUwKwWWJ(3oq4c2bubqWEQsbfLl18hqWEQsir3oSJjLlR1UYd8xM6If2bjhZMnZm49exlR1UYd8xM6If2bjhRaiypvPGIYLA(diypvjAnuUHZrLfFONQ(82bc)YXclwgv9DKsinZG3tCTiTGHh9VDGWfSdOcGG9uLpzMbVN4ArAbdp6F7aHlyhqLTfW5CuOfLl18hqWEQYgk3W5OYIp0tvF24y83nCo6hNswm1HPQjtWnuUHZrLfFONQ(SXX4VB4C0poLSyQdtv3e2Jr7pdsviXYgk3W5OYIp0tvF24y83nCo6hNswm1HPQBh2xOpdsviXYgk3W5OYIp0tvF24y83nCo6hNswm1HPQs25pdsviXsXKminCvuflJQUhUSw7kpWFzQlwyhKCScNgHPUyZMDyhtkxwRDLh4Vm1flSdsowdLB4CuzXh6PQpd7ykknFGVYwasSmQ6E4IOetF2tLlCAeM6sdLB4CuzXh6PQpd7ykknFGVYwasSmQ6E4ICSWFWWfonctDbs7WoMuUiN4FUM(sI2Ygk3W5OYIp0tvFg2XuuA(aFLTaKyzuv7WoMuUikX0N9u5gk3W5OYIp0tvFg2XuuA(aFLTaKyzuv5yH)YAhSf0dBOCdNJkl(qpv9zzUwp6hNrKyMygm9zhSqSSkQILrvDdNIO)E4ImxRh9JZicAvTpKakcqYA)ftqAN9WfzUwp6hNruHtJWuxAOCdNJkl(qpv9zJJXF3W5OFCkzXuhMQAgrK6klMKbPHRIQyzuvZiIux5IsgWGhWUHYnCoQS4d9u1N3ap1poJiXYOQVwrrLujrj7Vy6Vj4usfj7gHcQQDHc2S9osjKVwrrLujrj7Vy6Vj4usfRviJYLA(diypvj0SlB2ETIIkPsIs2FX0FtWPKks2ncfuv7BxqUhUihl8hmCHtJWuxAOCdNJkl(qpv95imjRnapIflJQkhl8BQ7IOb7CIPVCWIiLflvMaaRv(NrvFTIIkIgSZjM(YblIuUyT2q5gohvw8HEQ6ZBGN6xowyXsLjaWALRIAdLB4CuzXh6PQplR99e))oyUHQHYnCoQSygrK6kxnHxjDN6Y34SlzWSwtILrvTd7ys5YATR8a)LPUyHDqYXGeDZm49exlsly4r)BhiCb7aQaiypvj0qffSzZmdEpX1I0cgE0)2bcxWoGkac2tvki7cfSzZmdEpX1I0cgE0)2bcxWoGkac2tvkOkSlinJUTsUygaWALtD5JjcGwdLB4CuzXmIi1v(PQpNWRKUtD5BC2LmywRjXYOQSJjLlR1UYd8xM6If2bjhdY9WL1Ax5b(ltDXc7GKJv40im1Lgk3W5OYIzerQR8tvFEtMe25ux(VdMflJQAMbVN4ArAbdp6F7aHlyhqfab7PkfKDbj6B61kkQu7wkxaeSNQuqp0Mn7WoMuUu7wkJwdLB4CuzXmIi1v(PQplhl8hmSyzuv7WoMuUSw7kpWFzQlwyhKCmir3mdEpX1I0cgE0)2bcxWoGkac2tvcn7YMnZm49exlsly4r)BhiCb7aQaiypvPGSluWMnZm49exlsly4r)BhiCb7aQaiypvPGQWUG0m62k5IzaaRvo1LpMiaAnuUHZrLfZiIux5NQ(SCSWFWWILrvzhtkxwRDLh4Vm1flSdsogK7HlR1UYd8xM6If2bjhRWPryQlnuUHZrLfZiIux5NQ(S0mwGux(CY1udvdLB4Cuzz7W(c9zqQcjww1ss)KjyXuhMQkhl8px0KjqdLB4Cuzz7W(c9zqQcjw(u1NTK0pzcwm1HPQBa57OeqFrKus4gk3W5OYY2H9f6ZGufsS8PQpBjPFYeSyQdtvxWXwR)t03LYeoXoNJ2q5gohvw2oSVqFgKQqILpv9zlj9tMGftDyQQLAQ9uP9Fb7705bi)YA3ietYgk3W5OYY2H9f6ZGufsS8PQpBjPFYeSyQdtvP3rLJf(lknudvdLB4Cuzz7aHlyhq)vaTwvuIPp7PYnuUHZrLLTdeUGDa9xb06tvFE7aHF5yHBOCdNJklBhiCb7a6VcO1NQ(86W5OnuUHZrLLTdeUGDa9xb06tvFokb0lEMDdLB4Cuzz7aHlyhq)vaT(u1NFXZS)rwGynuUHZrLLTdeUGDa9xb06tvF(Lascim1Lgk3W5OYY2bcxWoG(RaA9PQpBCm(7goh9JtjlM6WuvZiIuxzXKminCvuflJQAhZiIux5IsgWGhWUHYnCoQSSDGWfSdO)kGwFQ6Zsly4r)BhiCb7aQHQHYnCoQSSjShJ2FgKQqILvTK0pzcwm1HPQe8Ama54)a2QRgsSmQk6MrePUYfnxQ5FKtqAMbVN4Arow4py4cGG9uLqRcuanB2q3mIi1vUiIuUogasZm49exlj8kP7ux(gNDjdM1AQaiypvj0QafqZMn0nJisDLlkzadEaBB2mJisDLlcJbsxTzZmIi1vUOJsO1q5gohvw2e2Jr7pdsviXYNQ(SLK(jtWIPomvvAPV4z2FhM46yswSmQk6MrePUYfnxQ5FKtqAMbVN4Arow4py4cGG9uLqd6IMnBOBgrK6kxerkxhdaPzg8EIRLeEL0DQlFJZUKbZAnvaeSNQeAqx0SzdDZiIux5IsgWGhW2MnZiIux5IWyG0vB2mJisDLl6OeAnuUHZrLLnH9y0(ZGufsS8PQpBjPFYeSyQdtvLJfgtmN6Yhy9gtSmQk6MrePUYfnxQ5FKtqAMbVN4Arow4py4cGG9uLqdcHMnBOBgrK6kxerkxhdaPzg8EIRLeEL0DQlFJZUKbZAnvaeSNQeAqi0SzdDZiIux5IsgWGhW2MnZiIux5IWyG0vB2mJisDLl6OeAnuUHZrLLnH9y0(ZGufsS8PQpBjPFYeSyQdtvL1(EIt7)aE)t0NhamPSyzuv0nJisDLlAUuZ)iNG0mdEpX1ICSWFWWfab7PkH2drZMn0nJisDLlIiLRJbG0mdEpX1scVs6o1LVXzxYGzTMkac2tvcThIMnBOBgrK6kxuYag8a22SzgrK6kxegdKUAZMzerQRCrhLqRHQHYnCoQSSh(VcO1Q(YOXelJQUhU4lJgRaiypvj0GqqAMbVN4ArAbdp6F7aHlyhqfab7Pkf0E4IVmAScGG9uLnuUHZrLL9W)vaT(u1NL5A9OFCgrILrv3dxK5A9OFCgrfab7PkHgecsZm49exlsly4r)BhiCb7aQaiypvPG2dxK5A9OFCgrfab7PkBOCdNJkl7H)RaA9PQpBPs2FX03JIWPHZrflJQUhUyPs2FX03JIWPHZrlac2tvcnieKMzW7jUwKwWWJ(3oq4c2bubqWEQsbThUyPs2FX03JIWPHZrlac2tv2q5gohvw2d)xb06tvF2maG1kNJkwgvDpCXmaG1kNJwaeSNQeAqiinZG3tCTiTGHh9VDGWfSdOcGG9uLcApCXmaG1kNJwaeSNQSHQHYnCoQSKmbx1ss)KjyzdvdLB4Cuzrjdy(WXRkYbP)IjXuhMQUhw(50im1fXe5ylQ6E4IzaaRvohTaiypvPGQaY9WfFz0yfab7PkfufqUhUyPs2FX03JIWPHZrlac2tvkOkGeD7WoMuUiZ16r)4mISzBpCrMR1J(XzevaeSNQuqvGwdfk1xLGufsSSphNlAFXtUUpiisFrdOpKAFpX7d6a(f4gsS(EGh7lAa9bbIBPCPHYnCoQSOKbmF44pv9zroi9xmjM6WuvgKQqI)Bc7XetKJTOQMzW7jUwwRDLh4Vm1flSdsowbqWEQsXe5yl6tyjv1mdEpX1YMmjSZPU8FhmxaeSNQuSzTQK4msmZO7KZrRYoMuUiR99e)tWVa3qILrvnJisDLlkzadEa7gkuQVhTaAFYXc3NS2bBzFzuFCn1xuUuZ9fpX4(EP(iDN6sFYz0sdLB4Cuzrjdy(WXFQ6ZWoMIsZh4RSfGelJQYjm955VtcAeetglM(CctqaYXc)L1oyd5E4ILkz)ftFpkcNgohTWPryQlnuOuFqKl5(QDlL7JN(aueGK199srdG6lYX4jkQ0q5gohvwuYaMpC8NQ(CTBPSyzu19WLA3s5cGG9uLqRINiiMmwm95eMAOqP(GajxQ77b7BfKdi5y9bHrX9bOiajR7lJ6tUs6o1L(gL6BbpVoUV4JfE3NXTKuFwY(4Pp4uk7JRP(M11bWwAYX6JN(aueGK19bHrXL(AOCdNJklkzaZho(tvFg2XuuA(aFLTaKyzuvoHjbj4H81kkQa7ykkn)4aNRlac2tvcTfZUa7q8teetglM(CctnuOuFqGta13MWEmA3hdsviXY(sTpx50KRoNJ23e13dqMe25ux67XbZLgk3W5OYIsgW8HJ)u1NTK0pzcwm1HPQe8Ama54)a2QRgsSmQQihK(lMkmivHe)3e2JbTkqHgk3W5OYIsgW8HJ)u1NTK0pzcwm1HPQsl9fpZ(7WexhtYILrvf5G0FXuHbPkK4)MWEmObDBOCdNJklkzaZho(tvF2ss)KjyXuhMQkhlmMyo1LpW6nMyzuvroi9xmvyqQcj(VjShdAqOgk3W5OYIsgW8HJ)u1NTK0pzcwm1HPQQdtvL1(EIt7)aE)t0NhamPSyzuvroi9xmvyqQcj(VjShdApSHcL6tWg1hxt9TI9yeOVu2NLm1L(GaXTuwS(Isa1heePVr7ZmdEpX1(4As7lAW4jEFXtUUVh4Xgk3W5OYIsgW8HJ)u1NxRDLh4Vm1flSdsoMyzuv2XKYLA3szif5G0FXuzpS8ZPryQlnuUHZrLfLmG5dh)PQpVjtc7CQl)3bZILrvzhtkxQDlLH0mdEpX1YATR8a)LPUyHDqYXkac2tvkiuOHcL6tWg1hxt9TI9yeOVu2NLm1L(qGoeRVOeq99ap23O9zMbVN4AFCnP9fny8ep1L(INCDFqqKgk3W5OYIsgW8HJ)u1N3KjHDo1L)7GzXYOQSJjLlYAFpX)e8lWneKICq6VyQShw(50im1Lgk3W5OYIsgW8HJ)u1NxRDLh4Vm1flSdsoMyzuv2XKYfzTVN4Fc(f4gcsZm49exlBYKWoN6Y)DWCbqWEQsbHcnuUHZrLfLmG5dh)PQpBPs2FX03JIWPHZrflJQUhUyPs2FX03JIWPHZrlac2tvcnOBdLB4Cuzrjdy(WXFQ6Z(YOXelJQUhU4lJgRaiypvj0EydLB4Cuzrjdy(WXFQ6ZYCTE0poJiXYOQ7HlYCTE0poJOcGG9uLq7HnuUHZrLfLmG5dh)PQpBgaWALZrflJQUhUygaWALZrlac2tvcTh2qHs9z3OiajR7dcJI7ZJyc0hxt9nRKsG(YO(2oq4c2b0FfqR9fFSW7(mULK6Zs2hp9bNszFEFqyuCFakcqY6gk3W5OYIsgW8HJ)u1NHDmfLMpWxzlajwgvLtysqcEiFTIIkWoMIsZpoW56cGG9uLqRciGfZUa7q8teetglM(CctnuOuFqKJX9TDGWfSdO)kGw7lJ6dcw7kpW9HK6If2bjhRVu2NXcaiLXX6JtJWuxAOCdNJklkzaZho(tvF24y83nCo6hNswm1HPQBhiCb7a6VcOvXKminCvuflJQUhUSw7kpWFzQlwyhKCScNgHPU0qHs9z3Zjofmq95AS(gUMa9jzN7JbPkKyzFzuFqWAx5bUpKuxSWoi5y9LY(40im1Lgk3W5OYIsgW8HJ)u1Nnog)DdNJ(XPKftDyQQKD(ZGufsSumjdsdxfvXYOQ7HlR1UYd8xM6If2bjhRWPryQlnuOuFiSBe2he2XuuA6dfdCUUpE6Z(I13a6dqrasw3x8As7BHyo1L(Wt8(qp3KJXX6dpJWux6lAa959zCSXc7mT7tTGFjGy99AX99WIDj7dqWEQPU0xk7JRP(aK0cZ9nr9XKKtDPV4jx3xLvi4rRHYnCoQSOKbmF44pv9zyhtrP5d8v2cqILrv5eMeKGhs0FTIIkWoMIsZpoW56IKDJqOzFB2ETIIkWoMIsZpoW56cGG9uLq7Hf7cTgkuQpb3ENCoQJ7dcB36tUs6w2x8As7JGyg49jRDWw2NdO(CrEI9xm1NR7(OKRjqFqWAx5bUpKuxSWoi5y9LY(40im1fX6Ba9X1uFr5sn3xk7J0DQlLgk3W5OYIsgW8HJ)u1NHDmfLMpWxzlajwgvf99WL1Ax5b(ltDXc7GKJv40im1fB24eM(883jbnZm49exlR1UYd8xM6If2bjhRaiypvjAqI(Rvuub2XuuA(XboxxKSBecn7BZMCSWFzTd2ccv0AOqP(eC7DY5OoUVha4P2hYyH7Z4sUV41K2heePVu2hNgHPU0q5gohvwuYaMpC8NQ(8g4P(LJfwSmQ6E4YATR8a)LPUyHDqYXkCAeM6sdfk1h0pX77b7BfKdi5y9ThUpafbizDFXRjTpafbizT)IPsdLB4Cuzrjdy(WXFQ6Z(YOXelJQcOiajR9xm1q5gohvwuYaMpC8NQ(SLkz)ftFpkcNgohvSmQkGIaKS2FXudLB4Cuzrjdy(WXFQ6ZMbaSw5CuXYOQakcqYA)ftnuUHZrLfLmG5dh)PQplZ16r)4mIelJQYoMuUiZ16r)4mIGeqrasw7VyQHcL6dcmMK1gGhX9XtFWEQSNAFcghSZjM6dzWIiLlnuUHZrLfLmG5dh)PQphHjzTb4rSyzuv5yHFtDxenyNtm9LdwePSygxne(NrvFTIIkIgSZjM(YblIu(xBb76K7I1Adfk1h0pXFWvqoGKJ1xTBPCFakcqY6sdLB4Cuzrjdy(WXFQ6Z1ULYILrv3dxQDlLlac2tvcn73qHs9z3RPYeayTY5lM67bq6Zu7Qs4(YO(It9v7IO(4AQVh4X(ETIIknuUHZrLfLmG5dh)PQpVbEQF5yHflJQ(Affv2KjHDo1L)7G5I1AdLB4Cuzrjdy(WXFQ6ZBGN6xowyXYOQSJjLlYAFpX)e8lWneKB61kkQiR99e)tWVa3qfab7PkHM9TzBtVwrrfzTVN4Fc(f4gQiz3ieA2xSuzcaSw5FgvDtVwrrfzTVN4Fc(f4gQiz3iuqvTpKB61kkQiR99e)tWVa3qfab7PkfK9BOCdNJklkzaZho(tvFEd8u)YXclwQmbawRCvuBOCdNJklkzaZho(tvFww77j()DWCdvdLB4CuzrsvRDlLBOCdNJkls6PQpVbEQF5yHflvMaaRv(VGNxhxfvXsLjaWAL)zu1n9AffvK1(EI)j4xGBOIKDJqbv1(nuUHZrLfj9u1NL1(EI)Fhm3q1q5gohvwKSZFgKQqILvTK0pzcwm1HPQPknal2FX0hfz5kBb)3KO0qnuUHZrLfj78NbPkKy5tvF2ss)KjyXuhMQMQKbwgEaY)ofLk9FjmUHYnCoQSizN)mivHelFQ6Zws6NmblM6Wu1rebIWt8ux(UMW(34ludLB4CuzrYo)zqQcjw(u1NTK0pzcwm1HPQBhieEg9VjJW)QfdiPHud1q5gohvwKSZFgKQqILpv9zlj9tMGftDyQkSB8xa9L1eXFylzAAOCdNJkls25pdsviXYNQ(SLK(jtWIPomvnc7W0FI(VoZyQHYnCoQSizN)mivHelFQ6Zws6NmblM6Wu14UqsjG8hbgD3q5gohvwKSZFgKQqILpv9zlj9tMGftDyQk7VyI)t0FtYvpbnuUHZrLfj78NbPkKy5tvF2ss)KjyXuhMQktnYc)D5AcCLL)xFVq)j6hrGXKCSgk3W5OYIKD(ZGufsS8PQpBjPFYeSyQdtvLPgzH)lyFNopa5)13l0FI(reymjhRHYnCoQSizN)mivHelFQ6ZV4z2)ilqSgk3W5OYIKD(ZGufsS8PQphLa6fpZUHYnCoQSizN)mivHelFQ6ZVeqsaHPU0q1qHs9HIP(2Jka3N0ADDaCFTGP7ZL9zpOt7wFP2h0B5I1NC6tWkGiQpZOIiat7(46u2hp95GKRHjonLgk3W5OYcdsviXF5ko5VPMmcRkYbP)IjXuhMQkxjt64pHISY1vAlMihBrvrhDuHaiuKvUUs7cbVgdqo(pGT6QHq7j0rfcGqrw56kTlPknal2FX0hfz5kBb)3KO0qO9e6OcbqOiRCDL2f5yHXeZPU8bwVXq7j0rfcGqrw56kTlsl9fpZ(7WexhtYOHwvuBOCdNJklmivHe)LR4K)MAYi8PQplYbP)IjXuhMQYGufs8Fusmro2IQIodsviXful1U8VcgdKmivHexqTu7YVzg8EIRO1q5gohvwyqQcj(lxXj)n1Kr4tvFwKds)ftIPomvLbPkK4phFetKJTOQOZGufsCPIsTl)RGXajdsviXLkk1U8BMbVN4kAnuUHZrLfgKQqI)YvCYFtnze(u1Nf5G0FXKyQdtv3oSVqFgKQqIftKJTOQOBh0zqQcjUGAP2L)vWyGKbPkK4cQLAx(nZG3tCfn0SzdD7GodsviXLkk1U8VcgdKmivHexQOu7YVzg8EIROHMnBekYkxxPDzbhBT(prFxkt4e7CoAdLB4CuzHbPkK4VCfN83utgHpv9zroi9xmjM6WuvgKQqI)YvCYIjYXwuv0f5G0FXuHbPkK4)OeKICq6VyQSDyFH(mivHeJMnBOlYbP)IPcdsviXFo(aPihK(lMkBh2xOpdsviXOzZg6OcbiYbP)IPcdsviX)rj0EcDuHae5G0FXurUsM0XFcfzLRR0gTQOAZg6OcbiYbP)IPcdsviXFo(G2tOJkeGihK(lMkYvYKo(tOiRCDL2Ovf1aIiciZrdIxbkubQOwbki4diXDGM6ImGGIfC2nXfSIdbkk3xFvwt9LWRdG7lAa9jadsviXF5ko5VPMmcfOpaHISsaT7toWuFUfpWot7(m1UUqYsdf0Nk1xfOCFq0OIiat7(eGbPkK4cQf7jqF80NamivHexyul2tG(qVcigTsdf0Nk1N9r5(GOrfraM29jadsviXLkk2tG(4PpbyqQcjUWvuSNa9HEfqmALgkOpvQVhIY9brJkIamT7tagKQqIlOwSNa9XtFcWGufsCHrTypb6d9kGy0knuqFQuFpeL7dIgvebyA3NamivHexQOypb6JN(eGbPkK4cxrXEc0h6vaXOvAOAOqXco7M4cwXHafL7RVkRP(s41bW9fnG(eWmIi1vwG(aekYkb0Up5at95w8a7mT7Zu76cjlnuqFQuFOIY9brJkIamT7ta2XKYf7jqF80NaSJjLl2RqQ)IPTa9HoQqmALgkOpvQpur5(GOrfraM29jGz0TvYf7jqF80NaMr3wjxSxHu)ftBb6dDuHy0knuqFQuFvGY9brJkIamT7ta2XKYf7jqF80NaSJjLl2RqQ)IPTa9HoQqmALgkOpvQp7JY9brJkIamT7ta2XKYf7jqF80NaSJjLl2RqQ)IPTa9HoQqmALgkOpvQVhIY9brJkIamT7ta2XKYf7jqF80NaSJjLl2RqQ)IPTa9HoQqmALgkOpvQVhIY9brJkIamT7taZOBRKl2tG(4PpbmJUTsUyVcP(lM2c0h6OcXOvAOG(uP(SluUpiAureGPDFcWoMuUypb6JN(eGDmPCXEfs9xmTfOp0rfIrR0q1qHIfC2nXfSIdbkk3xFvwt9LWRdG7lAa9jWMIClmlqFacfzLaA3NCGP(ClEGDM29zQDDHKLgkOpvQVhIY9brJkIamT7ta2XKYf7jqF80NaSJjLl2RqQ)IPTa95CFqhqNqFFOJkeJwPHc6tL67HOCFq0OIiat7(eayPu0awOI9eOpE6taGLsrdyHk2RqQ)IPTa9HoQqmALgkOpvQpbpk3henQicW0UpbyhtkxSNa9XtFcWoMuUyVcP(lM2c0NZ9bDaDc99HoQqmALgkOpvQpiek3henQicW0UpbyqQcjUGAXEc0hp9jadsviXfg1I9eOp0FieJwPHc6tL6dcHY9brJkIamT7tagKQqIlvuSNa9XtFcWGufsCHROypb6d9hcXOvAOG(uP(qffq5(GOrfraM29ja7ys5I9eOpE6ta2XKYf7vi1FX0wG(qVcigTsdf0Nk1hQOIY9brJkIamT7ta2XKYf7jqF80NaSJjLl2RqQ)IPTa9HoQqmALgkOpvQpuTpk3henQicW0UpbyhtkxSNa9XtFcWoMuUyVcP(lM2c0h6OcXOvAOG(uP(q9HOCFq0OIiat7(eGbPkK4I)AkMzW7jUkqF80NaMzW7jUw8xJa9HoQqmALgkOpvQpuTluUpiAureGPDFcWGufsCXFnfZm49exfOpE6taZm49exl(RrG(qhvigTsdf0Nk1hQqxuUpiAureGPDFcaSukAaluXEc0hp9jaWsPObSqf7vi1FX0wG(qhvigTsdf0Nk1hQqxuUpiAureGPDFcWGufsCXFnfZm49exfOpE6taZm49exl(RrG(qhvigTsdf0Nk1hQcEuUpiAureGPDFcaSukAaluXEc0hp9jaWsPObSqf7vi1FX0wG(qhvigTsdf0Nk1hQcEuUpiAureGPDFcWGufsCXFnfZm49exfOpE6taZm49exl(RrG(qhvigTsdf0Nk1xfvGY9brJkIamT7ta2XKYf7jqF80NaSJjLl2RqQ)IPTa9HoQqmALgkOpvQVkSpk3henQicW0UpbyhtkxSNa9XtFcWoMuUyVcP(lM2c0h6OcXOvAOG(uP(QacHY9brJkIamT7ta2XKYf7jqF80NaSJjLl2RqQ)IPTa9HEfqmALgkOpvQp7JcOCFq0OIiat7(eGDmPCXEc0hp9ja7ys5I9kK6VyAlqFOxbeJwPHc6tL6Z(OIY9brJkIamT7ta2XKYf7jqF80NaSJjLl2RqQ)IPTa9HoQqmALgkOpvQp7xbk3henQicW0UpbyhtkxSNa9XtFcWoMuUyVcP(lM2c0h6OcXOvAOG(uP(SVDHY9brJkIamT7taGLsrdyHk2tG(4PpbawkfnGfQyVcP(lM2c0h6OcXOvAOG(uP(Sp0fL7dIgvebyA3NaalLIgWcvSNa9XtFcaSukAaluXEfs9xmTfOp0rfIrR0qb9Ps9zFbpk3henQicW0UpbawkfnGfQypb6JN(eayPu0awOI9kK6VyAlqFOJkeJwPHc6tL6Z(qiuUpiAureGPDFcWoMuUypb6JN(eGDmPCXEfs9xmTfOp0rfIrR0qb9Ps9zFiek3henQicW0UpbawkfnGfQypb6JN(eayPu0awOI9kK6VyAlqFOJkeJwPHc6tL6Z(2DOCFq0OIiat7(eGDmPCXEc0hp9ja7ys5I9kK6VyAlqFo3h0b0j03h6OcXOvAOG(uP(EODHY9brJkIamT7ta2XKYf7jqF80NaSJjLl2RqQ)IPTa9HEfqmALgkOpvQVhcDr5(GOrfraM29jGCSWVPUl2tG(4PpbKJf(n1DXEfs9xmTfOpN7d6a6e67dDuHy0knunuOybNDtCbR4qGIY91xL1uFj86a4(IgqFc4djqFacfzLaA3NCGP(ClEGDM29zQDDHKLgkOpvQp7JY9brJkIamT7ta2XKYf7jqF80NaSJjLl2RqQ)IPTa9HEfqmALgkOpvQVhIY9brJkIamT7ta2XKYf7jqF80NaSJjLl2RqQ)IPTa9HoQqmALgkOpvQp7cL7dIgvebyA3NaSJjLl2tG(4PpbyhtkxSxHu)ftBb6dDuHy0knuqFQuFOwbk3henQicW0UpbyhtkxSNa9XtFcWoMuUyVcP(lM2c0h62hIrR0qb9Ps9HQ9r5(GOrfraM29ja7ys5I9eOpE6ta2XKYf7vi1FX0wG(qhvigTsdf0Nk1hQqiuUpiAureGPDFcWoMuUypb6JN(eGDmPCXEfs9xmTfOpN7d6a6e67dDuHy0knuqFQuFvGcOCFq0OIiat7(eGDmPCXEc0hp9ja7ys5I9kK6VyAlqFo3h0b0j03h6OcXOvAOG(uP(QavuUpiAureGPDFcWoMuUypb6JN(eGDmPCXEfs9xmTfOpN7d6a6e67dDuHy0knuqFQuFvaDr5(GOrfraM29jGCSWVPUl2tG(4PpbKJf(n1DXEfs9xmTfOpN7d6a6e67dDuHy0knunuOybNDtCbR4qGIY91xL1uFj86a4(IgqFcOKbmF44c0hGqrwjG29jhyQp3IhyNPDFMAxxizPHc6tL6dvuUpiAureGPDFcWoMuUypb6JN(eGDmPCXEfs9xmTfOp0rfIrR0qb9Ps9vbk3henQicW0UpbyhtkxSNa9XtFcWoMuUyVcP(lM2c0NZ9bDaDc99HoQqmALgkOpvQpurbuUpiAureGPDFcWoMuUypb6JN(eGDmPCXEfs9xmTfOp0rfIrR0qb9Ps9HkQOCFq0OIiat7(eGDmPCXEc0hp9ja7ys5I9kK6VyAlqFOJkeJwPHc6tL6d1kq5(GOrfraM29ja7ys5I9eOpE6ta2XKYf7vi1FX0wG(qhvigTsdf0Nk1hQ2hL7dIgvebyA3NaSJjLl2tG(4PpbyhtkxSxHu)ftBb6dDuHy0knuqFQuFvi4r5(GOrfraM29ja7ys5I9eOpE6ta2XKYf7vi1FX0wG(qhvigTsdf0Nk1xfqiuUpiAureGPDFcihl8BQ7I9eOpE6ta5yHFtDxSxHu)ftBb6Z5(GoGoH((qhvigTsdf0Nk1N9rfL7dIgvebyA3NaSJjLl2tG(4PpbyhtkxSxHu)ftBb6dDuHy0knunucw41bW0UpuTFFUHZr7dNswwAOciUfxpGacscdrbeCkzzOYaIKD(ZGufsSmuzqCudvgqi1FX0o8yarDykGKQ0aSy)ftFuKLRSf8FtIsdfqCdNJgqsvAawS)IPpkYYv2c(VjrPHcCq8kcvgqi1FX0o8yarDykGKQKbwgEaY)ofLk9FjmoG4gohnGKQKbwgEaY)ofLk9FjmoWbXTFOYacP(lM2HhdiQdtbKrebIWt8ux(UMW(34luaXnCoAazerGi8ep1LVRjS)n(cf4G4pmuzaHu)ft7WJbe1HPaY2bcHNr)BYi8VAXasAi1qbe3W5ObKTdecpJ(3Kr4F1IbK0qQHcCqC7kuzaHu)ft7WJbe1HPacSB8xa9L1eXFylzAciUHZrdiWUXFb0xwte)HTKPjWbXHUHkdiK6VyAhEmGOomfqIWom9NO)RZmMciUHZrdiryhM(t0)1zgtboiUGpuzaHu)ft7WJbe1HPasCxiPeq(JaJUdiUHZrdiXDHKsa5pcm6oWbXHqHkdiK6VyAhEmGOomfqy)ft8FI(BsU6jiG4gohnGW(lM4)e93KC1tqGdIB3fQmGqQ)IPD4XaI6WuarMAKf(7Y1e4kl)V(EH(t0pIaJj5ybe3W5ObezQrw4VlxtGRS8)67f6pr)icmMKJf4G4OIcHkdiK6VyAhEmGOomfqKPgzH)lyFNopa5)13l0FI(reymjhlG4gohnGitnYc)xW(oDEaY)RVxO)e9JiWysowGdIJkQHkdiUHZrdiV4z2)ilqSacP(lM2HhdCqCuRiuzaXnCoAajkb0lEMDaHu)ft7WJboioQ2puzaXnCoAa5Lascim1LacP(lM2HhdCGdimivHe)LR4K)MAYimuzqCudvgqi1FX0o8yazwdisIdiUHZrdiICq6VykGiYXwuab9(qVpu7dcOpcfzLRR0UqWRXaKJ)dyRUAO(qRVN6d9(qTpiG(iuKvUUs7sQsdWI9xm9rrwUYwW)njknuFO13t9HEFO2heqFekYkxxPDrowymXCQlFG1BS(qRVN6d9(qTpiG(iuKvUUs7I0sFXZS)omX1XKCFO1hA9vTpudiBsAa5kNJgqqXuF7rfG7tATUoaUVaIih8vhMciYvYKo(tOiRCDL2boiEfHkdiK6VyAhEmGmRbejXbe3W5Oberoi9xmfqe5ylkGGEFmivHexyul1U8VcgtFq2hdsviXfg1sTl)MzW7jU2hAbero4RomfqyqQcj(pkf4G42puzaHu)ft7WJbKznGijoG4gohnGiYbP)IPaIihBrbe07JbPkK4cxrP2L)vWy6dY(yqQcjUWvuQD53mdEpX1(qlGiYbF1HPacdsviXFo(e4G4pmuzaHu)ft7WJbKznGijoG4gohnGiYbP)IPaIihBrbe07Zo9HEFmivHexyul1U8VcgtFq2hdsviXfg1sTl)MzW7jU2hA9HwF2S1h69zN(qVpgKQqIlCfLAx(xbJPpi7JbPkK4cxrP2LFZm49ex7dT(qRpB26Jqrw56kTll4yR1)j67szcNyNZrdiICWxDykGSDyFH(mivHeh4G42vOYacP(lM2HhdiZAarsCaXnCoAarKds)ftbero2IciO3NihK(lMkmivHe)hL6dY(e5G0FXuz7W(c9zqQcjUp06ZMT(qVproi9xmvyqQcj(ZXN(GSproi9xmv2oSVqFgKQqI7dT(SzRp07d1(Ga6tKds)ftfgKQqI)Js9HwFp1h69HAFqa9jYbP)IPICLmPJ)ekYkxxPDFO1x1(qTpB26d9(qTpiG(e5G0FXuHbPkK4phF6dT(EQp07d1(Ga6tKds)ftf5kzsh)juKvUUs7(qRVQ9HAarKd(QdtbegKQqI)YvCYboWbKTd7l0NbPkKyzOYG4OgQmGqQ)IPD4XaI6Wuarow4FUOjtGaIB4C0aICSW)CrtMaboiEfHkdiK6VyAhEmGOomfq2aY3rjG(IiPKWbe3W5ObKnG8DucOViskjCGdIB)qLbes9xmTdpgquhMcil4yR1)j67szcNyNZrdiUHZrdil4yR1)j67szcNyNZrdCq8hgQmGqQ)IPD4XaI6WuaXsn1EQ0(VG9D68aKFzTBeIjzaXnCoAaXsn1EQ0(VG9D68aKFzTBeIjzGdIBxHkdiK6VyAhEmGOomfqO3rLJf(lknuaXnCoAaHEhvow4VO0qboWbKnH9y0(ZGufsSmuzqCudvgqi1FX0o8yaXnCoAaHGxJbih)hWwD1qbedizcKEab9(mJisDLlAUuZ)iN6dY(mZG3tCTihl8hmCbqWEQY(GwFvGc9HwF2S1h69zgrK6kxerkxhd0hK9zMbVN4AjHxjDN6Y34SlzWSwtfab7Pk7dA9vbk0hA9zZwFO3NzerQRCrjdyWdy3NnB9zgrK6kxegdKU2NnB9zgrK6kx0rP(qlGOomfqi41yaYX)bSvxnuGdIxrOYacP(lM2HhdiUHZrdisl9fpZ(7WexhtYbedizcKEab9(mJisDLlAUuZ)iN6dY(mZG3tCTihl8hmCbqWEQY(GwFq3(qRpB26d9(mJisDLlIiLRJb6dY(mZG3tCTKWRKUtD5BC2LmywRPcGG9uL9bT(GU9HwF2S1h69zgrK6kxuYag8a29zZwFMrePUYfHXaPR9zZwFMrePUYfDuQp0ciQdtbePL(INz)DyIRJj5ahe3(HkdiK6VyAhEmG4gohnGihlmMyo1LpW6nwaXasMaPhqqVpZiIux5IMl18pYP(GSpZm49exlYXc)bdxaeSNQSpO1heQp06ZMT(qVpZiIux5Iis56yG(GSpZm49exlj8kP7ux(gNDjdM1AQaiypvzFqRpiuFO1NnB9HEFMrePUYfLmGbpGDF2S1NzerQRCrymq6AF2S1NzerQRCrhL6dTaI6WuarowymXCQlFG1BSahe)HHkdiK6VyAhEmG4gohnGiR99eN2)b8(NOppays5aIbKmbspGGEFMrePUYfnxQ5FKt9bzFMzW7jUwKJf(dgUaiypvzFqRVh2hA9zZwFO3NzerQRCrePCDmqFq2Nzg8EIRLeEL0DQlFJZUKbZAnvaeSNQSpO13d7dT(SzRp07ZmIi1vUOKbm4bS7ZMT(mJisDLlcJbsx7ZMT(mJisDLl6OuFOfquhMciYAFpXP9FaV)j6ZdaMuoWboGSDGWfSdO)kGwdvgeh1qLbe3W5OberjM(SNkhqi1FX0o8yGdIxrOYaIB4C0aY2bc)YXchqi1FX0o8yGdIB)qLbe3W5ObK1HZrdiK6VyAhEmWbXFyOYaIB4C0asucOx8m7acP(lM2HhdCqC7kuzaXnCoAa5fpZ(hzbIfqi1FX0o8yGdIdDdvgqCdNJgqEjGKactDjGqQ)IPD4XahexWhQmGqQ)IPD4XaIbKmbspGyN(mJisDLlkzadEa7aIKbPHdIJAaXnCoAaX4y83nCo6hNsoGGtj)vhMciMrePUYboioekuzaXnCoAarAbdp6F7aHlyhqbes9xmTdpg4ahqmJisDLdvgeh1qLbes9xmTdpgqmGKjq6be70h7ys5YATR8a)LPUyHDqYXkK6VyA3hK9HEFMzW7jUwKwWWJ(3oq4c2bubqWEQY(GwFOIc9zZwFMzW7jUwKwWWJ(3oq4c2bubqWEQY(euF2fk0NnB9zMbVN4ArAbdp6F7aHlyhqfab7Pk7tq9vHD1hK9zgDBLCXmaG1kN6YhteOqQ)IPDFOfqCdNJgqs4vs3PU8no7sgmR1uGdIxrOYacP(lM2HhdigqYei9ac7ys5YATR8a)LPUyHDqYXkK6VyA3hK9ThUSw7kpWFzQlwyhKCScNgHPUeqCdNJgqs4vs3PU8no7sgmR1uGdIB)qLbes9xmTdpgqmGKjq6beZm49exlsly4r)BhiCb7aQaiypvzFcQp7Qpi7d9(20RvuuP2TuUaiypvzFcQVh2NnB9zN(yhtkxQDlLlK6VyA3hAbe3W5ObKnzsyNtD5)oyoWbXFyOYacP(lM2HhdigqYei9aID6JDmPCzT2vEG)YuxSWoi5yfs9xmT7dY(qVpZm49exlsly4r)BhiCb7aQaiypvzFqRp7QpB26ZmdEpX1I0cgE0)2bcxWoGkac2tv2NG6ZUqH(SzRpZm49exlsly4r)BhiCb7aQaiypvzFcQVkSR(GSpZOBRKlMbaSw5ux(yIafs9xmT7dTaIB4C0aICSWFWWboiUDfQmGqQ)IPD4XaIbKmbspGWoMuUSw7kpWFzQlwyhKCScP(lM29bzF7HlR1UYd8xM6If2bjhRWPryQlbe3W5Obe5yH)GHdCqCOBOYaIB4C0aI0mwGux(CY1uaHu)ft7WJboWbK9W)vaTgQmioQHkdiK6VyAhEmGyajtG0di7Hl(YOXkac2tv2h06dc1hK9zMbVN4ArAbdp6F7aHlyhqfab7Pk7tq9ThU4lJgRaiypvzaXnCoAaXxgnwGdIxrOYacP(lM2HhdigqYei9aYE4ImxRh9JZiQaiypvzFqRpiuFq2Nzg8EIRfPfm8O)TdeUGDavaeSNQSpb13E4ImxRh9JZiQaiypvzaXnCoAarMR1J(Xzef4G42puzaHu)ft7WJbedizcKEazpCXsLS)IPVhfHtdNJwaeSNQSpO1heQpi7ZmdEpX1I0cgE0)2bcxWoGkac2tv2NG6BpCXsLS)IPVhfHtdNJwaeSNQmG4gohnGyPs2FX03JIWPHZrdCq8hgQmGqQ)IPD4XaIbKmbspGShUygaWALZrlac2tv2h06dc1hK9zMbVN4ArAbdp6F7aHlyhqfab7Pk7tq9ThUygaWALZrlac2tvgqCdNJgqmdayTY5OboWbKnf5wyouzqCudvgqCdNJgqKReg)XJryaHu)ft7WJboiEfHkdiUHZrdiBs0yb(W(sAciK6VyAhEmWbXTFOYacP(lM2HhdigqYei9aIB4ue9jLGts2NG6Z(bejdsdheh1aIB4C0aIXX4VB4C0poLCabNs(Romfq8HcCq8hgQmGqQ)IPD4XaYMKgqUY5ObeiYX4(K0QdCM6ZnCoAF4uY9fnG(eNmGbpGDFqyuCFP2hsLL(GilaGughRVrXX6Bw5eofmq7(IgqFwsQV4jx3heePeqCdNJgqaw63nCo6hNsoGizqA4G4OgqmGKjq6beZiIux5IsgWGhWUpi7dyPu0awOcSJPO08JdCUUqQ)IPDFq2NB4ue9jLGts2x1(qTpi7JDmPCzT2vEG)YuxSWoi5yfs9xmTdi4uYF1HPaIsgW8HJh4G42vOYacP(lM2HhdiBsAa5kNJgqeCgohTpCkzzFrdOpgKQqI77LQDr5ak9HWol7ZbuFsxeT7lAa99srdG6dzSW9z3g(zbl8kP7ux6dIC2LmywRPNHG1UYdCFiPUyHDqYXeRVHRjq8us9nAFMzW7jUwciUHZrdighJ)UHZr)4uYbeCk5V6WuaHbPkK4VCfN83utgHboio0nuzaHu)ft7WJbe3W5ObeJJXF3W5OFCk5acoL8xDykGSjShJ2FgKQqILboiUGpuzaHu)ft7WJbedizcKEab9(2dxKJf(dgUWPryQl9zZwF7Hlj8kP7ux(gNDjdM1A6VhUWPryQl9zZwF7HlR1UYd8xM6If2bjhRWPryQl9HwFq2NCSWFzTd29jO(SFF2S13E4IOetF2tLlCAeM6sF2S1h7ys5ICI)5A6ljAllK6VyAhqKminCqCudiUHZrdighJ)UHZr)4uYbeCk5V6WuarYo)zqQcjwg4G4qOqLbes9xmTdpgqmGKjq6beZiIux5IMl18pYP(GSp07Zo9jYbP)IPcdsviXF5ko5(SzRpZm49exlYXc)bdxaeSNQSpb1xfOqF2S1h69jYbP)IPcdsviX)rP(GSpZm49exlYXc)bdxaeSNQSpO1hdsviXfg1Izg8EIRfab7Pk7dT(SzRp07tKds)ftfgKQqI)C8Ppi7ZmdEpX1ICSWFWWfab7Pk7dA9XGufsCHROyMbVN4AbqWEQY(qRp06ZMT(mJisDLlIiLRJb6dY(qVp70NihK(lMkmivHe)LR4K7ZMT(mZG3tCTKWRKUtD5BC2LmywRPcGG9uL9jO(Qaf6ZMT(qVproi9xmvyqQcj(pk1hK9zMbVN4AjHxjDN6Y34SlzWSwtfab7Pk7dA9XGufsCHrTyMbVN4AbqWEQY(qRpB26d9(e5G0FXuHbPkK4phF6dY(mZG3tCTKWRKUtD5BC2LmywRPcGG9uL9bT(yqQcjUWvumZG3tCTaiypvzFO1hA9zZwFO3NzerQRCrjdyWdy3NnB9zgrK6kxegdKU2NnB9zgrK6kx0rP(qRpi7d9(StFICq6VyQWGufs8xUItUpB26ZmdEpX1YATR8a)LPUyHDqYXkac2tv2NG6RcuOpB26d9(e5G0FXuHbPkK4)OuFq2Nzg8EIRL1Ax5b(ltDXc7GKJvaeSNQSpO1hdsviXfg1Izg8EIRfab7Pk7dT(SzRp07tKds)ftfgKQqI)C8Ppi7ZmdEpX1YATR8a)LPUyHDqYXkac2tv2h06JbPkK4cxrXmdEpX1cGG9uL9HwFO1NnB9zN(yhtkxwRDLh4Vm1flSdsowHu)ft7(GSp07Zo9jYbP)IPcdsviXF5ko5(SzRpZm49exlsly4r)BhiCb7aQaiypvzFcQVkqH(SzRp07tKds)ftfgKQqI)Js9bzFMzW7jUwKwWWJ(3oq4c2bubqWEQY(GwFmivHexyulMzW7jUwaeSNQSp06ZMT(qVproi9xmvyqQcj(ZXN(GSpZm49exlsly4r)BhiCb7aQaiypvzFqRpgKQqIlCffZm49exlac2tv2hA9HwaXnCoAaX4y83nCo6hNsoGGtj)vhMciBh2xOpdsviXYahe3UluzaHu)ft7WJbe3W5ObeyhtrP5d8v2cqbKnjnGCLZrdipAb0(KJfUpzTd2Y(YO(IYLAUVu2NJHhj33iIabedizcKEa5DKY(GSVOCPM)ac2tv2h06JGyYyX0NtyQpiG(KJf(lRDWUpi7BpCXsLS)IPVhfHtdNJw40im1LahehvuiuzaHu)ft7WJbKnjnGCLZrdic2O(mJisDL7Bp8ZqWAx5bUpKuxSWoi5y9LY(awQM6Iy9zjP(EahiCb7aQpE6JGyM0DFCn1NXcaiL7tsCaXnCoAaX4y83nCo6hNsoGyajtG0diO3NzerQRCrePCDmqFq23E4scVs6o1LVXzxYGzTM(7HlCAeM6sFq2Nzg8EIRfPfm8O)TdeUGDavaeSNQSpO1xf9bzFO33E4YATR8a)LPUyHDqYXkac2tv2NG6RI(SzRp70h7ys5YATR8a)LPUyHDqYXkK6VyA3hA9HwF2S1h69zgrK6kx0CPM)ro1hK9ThUihl8hmCHtJWux6dY(mZG3tCTiTGHh9VDGWfSdOcGG9uL9bT(QOpi7d9(2dxwRDLh4Vm1flSdsowbqWEQY(euFv0NnB9zN(yhtkxwRDLh4Vm1flSdsowHu)ft7(qRp06ZMT(qVp07ZmIi1vUOKbm4bS7ZMT(mJisDLlcJbsx7ZMT(mJisDLl6OuFO1hK9ThUSw7kpWFzQlwyhKCScNgHPU0hK9ThUSw7kpWFzQlwyhKCScGG9uL9bT(QOp0ci4uYF1HPaY2bcxWoG(RaAnWbXrf1qLbes9xmTdpgq2K0aYvohnGy3OiajR7BpSSpYb4y9Lr9TmPU0xQ80N3NS2b7(KRKUtDPV1Axsbe3W5ObeJJXF3W5OFCk5aIbKmbspGGEFMrePUYfnxQ5FKt9bzF2PV9Wf5yH)GHlCAeM6sFq2Nzg8EIRf5yH)GHlac2tv2h067H9HwF2S1h69zgrK6kxerkxhd0hK9zN(2dxs4vs3PU8no7sgmR10FpCHtJWux6dY(mZG3tCTKWRKUtD5BC2LmywRPcGG9uL9bT(EyFO1NnB9HEFO3NzerQRCrjdyWdy3NnB9zgrK6kxegdKU2NnB9zgrK6kx0rP(qRpi7JDmPCzT2vEG)YuxSWoi5yfs9xmT7dY(StF7HlR1UYd8xM6If2bjhRWPryQl9bzFMzW7jUwwRDLh4Vm1flSdsowbqWEQY(GwFpSp0ci4uYF1HPaYE4)kGwdCqCuRiuzaHu)ft7WJbe3W5ObKTde(LJfoGSjPbKRCoAarWg1heS2vEG7dj1flSdsowFPSponctDrS(sUVu2N0JO(4Pplj13d4aH9Hmw4aIbKmbspGShUSw7kpWFzQlwyhKCScNgHPUe4G4OA)qLbes9xmTdpgqmGKjq6be70h7ys5YATR8a)LPUyHDqYXkK6VyA3hK9HEF7HlYXc)bdx40im1L(SzRV9WLeEL0DQlFJZUKbZAn93dx40im1L(qlG4gohnGSDGWVCSWboioQpmuzaHu)ft7WJbe3W5ObK1Ax5b(ltDXc7GKJfq2K0aYvohnGGetn9bbRDLh4(qsDXc7GKJ1x8KR7tWiPCDmWZINl1CFqGDQpZiIux5(2dlwFdxtG4PK6Zss9nAFMzW7jUw6tWg1h0b8Ama54(GobB1vd13RvuuFPSVundCQlI1x9G39zPCI7lzbK9biFhRp0rfc1NKmJUL95rmb6ZssOfqmGKjq6beZiIux5IMl18pYP(GSpoHP(euF2vFq2Nzg8EIRf5yH)GHlac2tv2h06d1(GSp07ZmdEpX1cbVgdqo(pGT6QHkac2tv2h06dvOBf9zZwF2PpcfzLRR0UqWRXaKJ)dyRUAO(qlWbXr1Ucvgqi1FX0o8yaXasMaPhqmJisDLlIiLRJb6dY(4eM6tq9zx9bzFMzW7jUws4vs3PU8no7sgmR1ubqWEQY(GwFO2hK9HEFMzW7jUwi41yaYX)bSvxnubqWEQY(GwFOcDROpB26Zo9rOiRCDL2fcEngGC8FaB1vd1hAbe3W5ObK1Ax5b(ltDXc7GKJf4G4OcDdvgqi1FX0o8yaXnCoAazT2vEG)YuxSWoi5ybKnjnGCLZrdiItgWGhWUV4jx3he2XuuA6dfdCUUpJlzzFR1UYdCFYuxSWoi5y9LAF4uP(INCDFpazsyNtDPVhhmhqmGKjq6beZiIux5IsgWGhWUpi7dyPu0awOcSJPO08JdCUUqQ)IPDFq2hNWuFcQp7Qpi7ZmdEpX1YMmjSZPU8FhmxaeSNQSpO1N97dY(qVpZm49exle8Ama54)a2QRgQaiypvzFqRpuHUv0NnB9zN(iuKvUUs7cbVgdqo(pGT6QH6dTahehvbFOYacP(lM2HhdiUHZrdiR1UYd8xM6If2bjhlGSjPbKRCoAab6KRjqFMrePUYY(qpvd2AN6sF6Opiegf3N4KbmO1NXLCFqqK(gTpZm49exdigqYei9ac69zgrK6kxegdKU2NnB9zgrK6kx0rP(SzRp07ZmIi1vUOKbm4bS7dY(StFalLIgWcvGDmfLMFCGZ1fs9xmT7dT(qRpi7d9(mZG3tCTqWRXaKJ)dyRUAOcGG9uL9bT(qf6wrF2S1ND6Jqrw56kTle8Ama54)a2QRgQp0cCqCuHqHkdiK6VyAhEmGyajtG0diVJu2hK9fLl18hqWEQY(GwFOcDdiUHZrdiR1UYd8xM6If2bjhlWbXr1UluzaHu)ft7WJbKnjnGCLZrdic2O(GG1UYdCFiPUyHDqYX6lL9XPryQlI1xYci7JtyQpE6Zss9nCnb6d2fmpG(2dldiUHZrdighJ)UHZr)4uYbejdsdheh1aIbKmbspGShUSw7kpWFzQlwyhKCScNgHPU0hK9HEFMrePUYfnxQ5FKt9zZwFMrePUYfrKY1Xa9HwabNs(RomfqmJisDLdCq8kqHqLbes9xmTdpgqCdNJgq8LrJfqmGKjq6bK9WfFz0yfab7Pk7dA99WaIjMbtF2bleldIJAGdIxbQHkdiUHZrdi1ULYbes9xmTdpg4G4vurOYacP(lM2HhdiUHZrdisI2)j6BgaWALZrdiBsAa5kNJgqqM49X1uFieTL9nAF2Vp2blel7lJ6l5(sPka3NXcaiLXX6l1(IW5sn33a6B0(4AQp2blex6dfNCDFi5A9O9b9ze1xYci7ZXYPVxIzc0hp9zjP(qiA33iIa9b7QLJXX6ZxxXXsDPp73henaG1kNJklbedizcKEaXnCkI(KsWjj7tq9vrFq2h7ys5ICI)5A6ljAllK6VyA3hK9zN(2dxKeT)t03maG1kNJw40im1L(GSp70xQ)iCUuZboiEf2puzaHu)ft7WJbedizcKEaXnCkI(KsWjj7tq9vrFq2h7ys5ImxRh9JZiQqQ)IPDFq2ND6BpCrs0(prFZaawRCoAHtJWux6dY(StFP(JW5sn3hK9ThUygaWALZrlac2tv2h067Hbe3W5Obejr7)e9ndayTY5OboiEfpmuzaHu)ft7WJbedizcKEab9(KJf(lRDWUpb1hQ9zZwFUHtr0NucojzFcQVk6dT(GSpZm49exlsly4r)BhiCb7aQaiypvzFcQpuRiG4gohnGikX0N9u5aheVc7kuzaHu)ft7WJbedizcKEaXnCkI(7HlwQK9xm99OiCA4C0(Q2hk0NnB9XPryQl9bzF7HlwQK9xm99OiCA4C0cGG9uL9bT(EyaXnCoAaXsLS)IPVhfHtdNJg4G4vaDdvgqi1FX0o8yaXnCoAarMR1J(XzefqmGKjq6bK9WfzUwp6hNrubqWEQY(GwFpmGyIzW0NDWcXYG4Og4G4vi4dvgqi1FX0o8yaXasMaPhqStFMrePUYfLmGbpGDarYG0WbXrnG4gohnGyCm(7goh9JtjhqWPK)QdtbeZiIux5aheVciuOYacP(lM2HhdiUHZrdiMbaSw5C0aIjMbtF2bleldIJAaXasMaPhqCdNIOpPeCsY(GwFpSVhSp07JDmPCroX)Cn9LeTLfs9xmT7ZMT(yhtkxK5A9OFCgrfs9xmT7dT(GSV9WfZaawRCoAbqWEQY(GwFveq2K0aYvohnGi4wxXX6dIgaWALZr7d2vlhJJ13O9H6dwrFSdwiwkwFdOVr7Z(9fp56(eCVYbBXuFq0aawRCoAGdIxHDxOYacP(lM2HhdiUHZrdiWoMIsZh4RSfGciBsAa5kNJgqeCrmb6JRP(MvsjGy9jxjD3N3NS2b7(IxtAFo3ND13O9bHDmfLM(SB(kBbO(4Ppx0K7(greW4RRPUeqmGKjq6be5yH)YAhS7tq99W(GSpoHP(euFvGAGdIBFuiuzaHu)ft7WJbKnjnGCLZrdiO4As7thUpzm1K6sFqWAx5bUpKuxSWoi5y9XtFcgjLRJbEw8CPM7dcStI1hIfm8O99aoq4c2buFzuFog33EyzFoG6ZxxXjTdiUHZrdighJ)UHZr)4uYbedizcKEab9(mJisDLlIiLRJb6dY(StFSJjLlR1UYd8xM6If2bjhRqQ)IPDFq23E4scVs6o1LVXzxYGzTM(7HlCAeM6sFq2Nzg8EIRfPfm8O)TdeUGDavaKVJ1hA9zZwFO3NzerQRCrZLA(h5uFq2ND6JDmPCzT2vEG)YuxSWoi5yfs9xmT7dY(2dxKJf(dgUWPryQl9bzFMzW7jUwKwWWJ(3oq4c2bubq(owFO1NnB9HEFO3NzerQRCrjdyWdy3NnB9zgrK6kxegdKU2NnB9zgrK6kx0rP(qRpi7ZmdEpX1I0cgE0)2bcxWoGkaY3X6dTacoL8xDykGSDGWfSdO)kGwdCqC7JAOYacP(lM2HhdiUHZrdiBhi8lhlCaztsdix5C0aIDVK67bCGW(qglCFzuFpGdeUGDa1x8rfG77L6dq(owF(INQy9nG(YO(4Acq9fpX4(EP(CUpm5sUVk6dEauFpGdeUGDa1NLKKbedizcKEa5DKY(GSpZm49exlsly4r)BhiCb7aQaiypvzFcQVOCPM)ac2tv2hK9HEF2Pp2XKYL1Ax5b(ltDXc7GKJvi1FX0UpB26ZmdEpX1YATR8a)LPUyHDqYXkac2tv2NG6lkxQ5pGG9uL9HwGdIB)kcvgqi1FX0o8yaXasMaPhqEhPSpi7Zo9XoMuUSw7kpWFzQlwyhKCScP(lM29bzFMzW7jUwKwWWJ(3oq4c2bubqWEQY(EQpZm49exlsly4r)BhiCb7aQSTaoNJ2h06lkxQ5pGG9uLbe3W5ObKTde(LJfoWbXTV9dvgqi1FX0o8yaztsdix5C0ace5SP(bDmUVKj4(SK(c1x0a6Z1yCDQl9Pd3NCLmzus7(iSKIxtakG4gohnGyCm(7goh9JtjhqWPK)QdtbKKj4ahe3(pmuzaHu)ft7WJbedizcKEaHDmPCrw77j(NGFbUHkK6VyA3hK9HEFB61kkQiR99e)tWVa3qfj7gH9bT(qVVk67b7ZnCoArw77j()DWCj1FeoxQ5(qRpB26BtVwrrfzTVN4Fc(f4gQaiypvzFqRp73hAbe3W5ObeJJXF3W5OFCk5acoL8xDykGiPahe3(2vOYacP(lM2HhdiUHZrdiWoMIsZh4RSfGciBsAa5kNJgqS7LuFqyhtrPPp7MVYwaQV41K2hSlyEa9Thw2NdO(SwfRVb0xg1hxtaQV4jg33l1Nmx0mknUY9Xjm1NLYjUpUM6tjiM7dcw7kpW9HK6If2bjhR0NGnQploXPGHux6dc7ykkn9HIboxlwF1dE3N3NS2b7(4PpafbizDFCn13RvuuaXasMaPhqqVV9WfrjM(SNkx40im1L(SzRV9WLeEL0DQlFJZUKbZAn93dx40im1L(SzRV9Wf5yH)GHlCAeM6sFO1hK9HEF2PpGLsrdyHkWoMIsZpoW56cP(lM29zZwFVwrrfyhtrP5hh4CDrYUryFqRp73NnB9jhl8xw7GDFcQpu7dTahe3(q3qLbes9xmTdpgqCdNJgqGDmfLMpWxzlafq2K0aYvohnGy3lP(GWoMIstF2nFLTauF80hSNk7P2hxt9b7ykkn9fh4CDFVwrr9zPCI7tw7GTSpLODF803l13cPeWzA3x0a6JRP(ucI5(ETasUV4PUN49HEfOqFsYm6w2xk7dEauFCTR9jTIIstsk3hp9TqkbCM6Z(9jRDWwIwaXasMaPhqawkfnGfQa7ykkn)4aNRlK6VyA3hK9zMbVN4Arow4py4cGG9uL9jO(Qaf6dY(ETIIkWoMIsZpoW56cGG9uL9bT(EyGdIBFbFOYacP(lM2HhdiUHZrdiWoMIsZh4RSfGciBsAa5kNJgqGWEQSNAFqyhtrPPpumW56(CUphJ7Jtys2x0a6JRP(eNmGbpGDFdOpbtfdKU2NzerQRCaXasMaPhqawkfnGfQa7ykkn)4aNRlK6VyA3hK9HEFMrePUYfLmGbpGDF2S1NzerQRCrymq6AFO1hK99AffvGDmfLMFCGZ1fab7Pk7dA99Wahe3(qOqLbes9xmTdpgqCdNJgqGDmfLMpWxzlafq2K0aYvohnGy3lP(GWoMIstF2nFLTauFJ2heS2vEG7dj1flSdsowFgxYsX6d2fM6sFsla1hp9jDruFEFYAhS7JN(KSBe2he2XuuA6dfdCUUVmQplzQl9LCaXasMaPhqyhtkxwRDLh4Vm1flSdsowHu)ft7(GSp07BpCzT2vEG)YuxSWoi5yfonctDPpB26ZmdEpX1YATR8a)LPUyHDqYXkac2tv2NG6Rc7QpB267DKY(GSpoHPpp)Ds9bT(mZG3tCTSw7kpWFzQlwyhKCScGG9uL9HwFq2h69zN(awkfnGfQa7ykkn)4aNRlK6VyA3NnB99AffvGDmfLMFCGZ1fj7gH9bT(SFF2S1NCSWFzTd29jO(qTp0cCqC7B3fQmGqQ)IPD4XaIbKmbspGWoMuUiN4FUM(sI2YcP(lM2be3W5ObeyhtrP5d8v2cqboi(drHqLbes9xmTdpgqCdNJgq2ap1poJOaYMKgqUY5ObKha4P2h0NruFPSVrXX6Z77bGGi9T4P2x8KR7tWQKOK9xm13dqWPK6tjh0hSdX9jz3iuw6tWg1xuUuZ9LY(83XI7JN(iD33E6thUp4uk7tUs6o1L(4AQpj7gHYaIbKmbspG8AffvsLeLS)IP)MGtjvKSBe2NG67HOqF2S13RvuujvsuY(lM(BcoLuXATpi77DKY(GSVOCPM)ac2tv2h067Hboi(drnuzaHu)ft7WJbe3W5ObeJJXF3W5OFCk5acoL8xDykGygrK6kh4G4pSIqLbes9xmTdpgqCdNJgq8LrJfqmGKjq6beafbizT)IPaIjMbtF2bleldIJAGdI)q7hQmGqQ)IPD4XaIbKmbspG4gofr)9WflvY(lM(EueonCoAFv7df6ZMT(40im1L(GSpafbizT)IPaIB4C0aILkz)ftFpkcNgohnWbXF4ddvgqi1FX0o8yaXnCoAarMR1J(XzefqmGKjq6beafbizT)IPaIjMbtF2bleldIJAGdI)q7kuzaHu)ft7WJbe3W5ObeZaawRCoAaXasMaPhqaueGK1(lM6dY(CdNIOpPeCsY(GwFpSVhSp07JDmPCroX)Cn9LeTLfs9xmT7ZMT(yhtkxK5A9OFCgrfs9xmT7dTaIjMbtF2bleldIJAGdI)qOBOYacP(lM2HhdiUHZrdiryswBaEehqmGKjq6be5yHFtDxenyNtm9LdwePCHu)ft7asQmbawR8pJciVwrrfrd25etF5GfrkxSwdCq8hk4dvgqsLjaWALdiOgqCdNJgq2ap1VCSWbes9xmTdpg4G4pecfQmG4gohnGiR99e))oyoGqQ)IPD4Xah4aYkGmd8RZHkdIJAOYacP(lM2HhdigqYei9acNWuFcQpuOpi7Zo9TsCXXPiQpi7Zo99Affvwaj8Ka6prFPBazuAOI1AaXnCoAajIW)9aNQZ5OboiEfHkdiUHZrdisly4r)reU2szceqi1FX0o8yGdIB)qLbes9xmTdpgquhMci8at)j6dpQKbJL8BgvYaldNJkdiUHZrdi8at)j6dpQKbJL8BgvYaldNJkdCq8hgQmGqQ)IPD4XaI6WuaroyYRLFjzae)zYuRjkYIciUHZrdiYbtET8ljdG4ptMAnrrwuGdIBxHkdiK6VyAhEmGyajtG0diSJjLllGeEsa9NOV0nGmknuHu)ft7aIB4C0aYciHNeq)j6lDdiJsdf4G4q3qLbe3W5ObKimjRnapIdiK6VyAhEmWbXf8HkdiK6VyAhEmGmRbejXbe3W5Oberoi9xmfqe5ylkG4gofr)9WfZaawRCoAFcQpuOpi7ZnCkI(7Hl(YOX6tq9Hc9bzFUHtr0FpCXsLS)IPVhfHtdNJ2NG6df6dY(qVp70h7ys5ImxRh9JZiQqQ)IPDF2S1NB4ue93dxK5A9OFCgr9jO(qH(qRpi7d9(2dxwRDLh4Vm1flSdsowHtJWux6ZMT(StFSJjLlR1UYd8xM6If2bjhRqQ)IPDFOfqe5GV6WuazpS8diFhlWbXHqHkdiK6VyAhEmGOomfqCbdYAh4YF0O8FI(RtCceqCdNJgqCbdYAh4YF0O8FI(RtCce4G42DHkdiK6VyAhEmG4gohnGijA)NOVzaaRvohnGyajtG0diYvcJ)SdwiwwKeT)t03maG1kNJ(9H6tqv7Z(beCQ03SdiOIcboioQOqOYaIB4C0asTBPCaHu)ft7WJboioQOgQmG4gohnGyPs2FX03JIWPHZrdiK6VyAhEmWboG4dfQmioQHkdiUHZrdiR1UYd8xM6If2bjhlGqQ)IPD4XaheVIqLbe3W5ObKA3s5acP(lM2HhdCqC7hQmGqQ)IPD4XaIbKmbspGygrK6kxerkxhd0hK9ThUKWRKUtD5BC2LmywRP)E4cNgHPU0hK9zMbVN4ArAbdp6F7aHlyhqfa57y9bzFO33E4YATR8a)LPUyHDqYXkac2tv2NG6RI(SzRp70h7ys5YATR8a)LPUyHDqYXkK6VyA3hA9zZwFMrePUYfnxQ5FKt9bzF7HlYXc)bdx40im1L(GSpZm49exlsly4r)BhiCb7aQaiFhRpi7d9(2dxwRDLh4Vm1flSdsowbqWEQY(euFv0NnB9zN(yhtkxwRDLh4Vm1flSdsowHu)ft7(qRpB26d9(mJisDLlkzadEa7(SzRpZiIux5IWyG01(SzRpZiIux5Iok1hA9bzF7HlR1UYd8xM6If2bjhRWPryQl9bzF7HlR1UYd8xM6If2bjhRaiypvzFqRVkciUHZrdighJ)UHZr)4uYbeCk5V6Wuaz7aHlyhq)vaTg4G4pmuzaHu)ft7WJbedizcKEaHDmPCroX)Cn9LeTLfs9xmT7dY(mU(LeTdiUHZrdisI2)j6BgaWALZrdCqC7kuzaHu)ft7WJbedizcKEaXo9XoMuUiN4FUM(sI2YcP(lM29bzF2PV9Wfjr7)e9ndayTY5OfonctDPpi7Zo9L6pcNl1CFq23E4IzaaRvohTaOiajR9xmfqCdNJgqKeT)t03maG1kNJg4G4q3qLbes9xmTdpgqCdNJgq8LrJfqmGKjq6be3WPi6VhU4lJgRpO13d7dY(StF7Hl(YOXkCAeM6saXeZGPp7GfILbXrnWbXf8HkdiK6VyAhEmG4gohnG4lJglGyajtG0diUHtr0FpCXxgnwFcQAFpSpi7dqrasw7VyQpi7BpCXxgnwHtJWuxciMygm9zhSqSmioQboioekuzaHu)ft7WJbedizcKEaXnCkI(7HlwQK9xm99OiCA4C0(Q2hk0NnB9XPryQl9bzFakcqYA)ftbe3W5ObelvY(lM(EueonCoAGdIB3fQmGqQ)IPD4XaIB4C0aILkz)ftFpkcNgohnGyajtG0di2PponctDPpi7Bv0k7ys5cWHxDL)EueonCoQSqQ)IPDFq2NB4ue93dxSuj7Vy67rr40W5O9bT(SFaXeZGPp7GfILbXrnWbXrffcvgqi1FX0o8yaXasMaPhqKJf(lRDWUpb1hQbe3W5OberjM(SNkh4G4OIAOYacP(lM2HhdigqYei9aID6ZmIi1vUOKbm4bSdisgKgoioQbe3W5ObeJJXF3W5OFCk5acoL8xDykGygrK6kh4G4OwrOYacP(lM2HhdigqYei9ac69zgrK6kxerkxhd0hK9HEFMzW7jUws4vs3PU8no7sgmR1ubq(owF2S13E4scVs6o1LVXzxYGzTM(7HlCAeM6sFO1hK9zMbVN4ArAbdp6F7aHlyhqfa57y9bzFO33E4YATR8a)LPUyHDqYXkac2tv2NG6RI(SzRp70h7ys5YATR8a)LPUyHDqYXkK6VyA3hA9HwFq2h69HEFMrePUYfLmGbpGDF2S1NzerQRCrymq6AF2S1NzerQRCrhL6dT(GSpZm49exlsly4r)BhiCb7aQaiypvzFqRVk6dY(qVV9WL1Ax5b(ltDXc7GKJvaeSNQSpb1xf9zZwF2Pp2XKYL1Ax5b(ltDXc7GKJvi1FX0Up06dT(SzRp07ZmIi1vUO5sn)JCQpi7d9(mZG3tCTihl8hmCbq(owF2S13E4ICSWFWWfonctDPp06dY(mZG3tCTiTGHh9VDGWfSdOcGG9uL9bT(QOpi7d9(2dxwRDLh4Vm1flSdsowbqWEQY(euFv0NnB9zN(yhtkxwRDLh4Vm1flSdsowHu)ft7(qRp0ciUHZrdighJ)UHZr)4uYbeCk5V6Wuaz7aHlyhq)vaTg4G4OA)qLbes9xmTdpgqmGKjq6bK3rk7dY(mZG3tCTiTGHh9VDGWfSdOcGG9uL9jO(IYLA(diypvzFq2h69zN(yhtkxwRDLh4Vm1flSdsowHu)ft7(SzRpZm49exlR1UYd8xM6If2bjhRaiypvzFcQVOCPM)ac2tv2hAbe3W5ObKTde(LJfoWbXr9HHkdiK6VyAhEmGyajtG0diVJu2hK9zMbVN4ArAbdp6F7aHlyhqfab7Pk77P(mZG3tCTiTGHh9VDGWfSdOY2c4CoAFqRVOCPM)ac2tvgqCdNJgq2oq4xow4ahehv7kuzaHu)ft7WJbe3W5ObeJJXF3W5OFCk5acoL8xDykGKmbh4G4OcDdvgqi1FX0o8yaXnCoAaX4y83nCo6hNsoGGtj)vhMciBc7XO9NbPkKyzGdIJQGpuzaHu)ft7WJbe3W5ObeJJXF3W5OFCk5acoL8xDykGSDyFH(mivHeldCqCuHqHkdiK6VyAhEmGyajtG0di7HlR1UYd8xM6If2bjhRWPryQl9zZwF2Pp2XKYL1Ax5b(ltDXc7GKJvi1FX0oGizqA4G4OgqCdNJgqmog)DdNJ(XPKdi4uYF1HPaIKD(ZGufsSmWbXr1UluzaHu)ft7WJbedizcKEazpCruIPp7PYfonctDjG4gohnGa7ykknFGVYwakWbXRafcvgqi1FX0o8yaXasMaPhq2dxKJf(dgUWPryQl9bzF2Pp2XKYf5e)Z10xs0wwi1FX0oG4gohnGa7ykknFGVYwakWbXRa1qLbes9xmTdpgqmGKjq6be70h7ys5IOetF2tLlK6VyAhqCdNJgqGDmfLMpWxzlaf4G4vurOYacP(lM2HhdigqYei9aICSWFzTd29jO(EyaXnCoAab2XuuA(aFLTauGdIxH9dvgqi1FX0o8yaXnCoAarMR1J(XzefqmGKjq6be3WPi6VhUiZ16r)4mI6dAv7Z(9bzFakcqYA)ft9bzF2PV9WfzUwp6hNruHtJWuxciMygm9zhSqSmioQboiEfpmuzaHu)ft7WJbedizcKEaXmIi1vUOKbm4bSdisgKgoioQbe3W5ObeJJXF3W5OFCk5acoL8xDykGygrK6kh4G4vyxHkdiK6VyAhEmGyajtG0diVwrrLujrj7Vy6Vj4usfj7gH9jOQ9zxOqF2S137iL9bzFVwrrLujrj7Vy6Vj4usfR1(GSVOCPM)ac2tv2h06ZU6ZMT(ETIIkPsIs2FX0FtWPKks2nc7tqv7Z(2vFq23E4ICSWFWWfonctDjG4gohnGSbEQFCgrboiEfq3qLbes9xmTdpgqCdNJgqIWKS2a8ioGyajtG0diYXc)M6UiAWoNy6lhSis5cP(lM2bKuzcaSw5FgfqETIIkIgSZjM(YblIuUyTg4G4vi4dvgqsLjaWALdiOgqCdNJgq2ap1VCSWbes9xmTdpg4G4vaHcvgqCdNJgqK1(EI)Fhmhqi1FX0o8yGdCarsHkdIJAOYaIB4C0asTBPCaHu)ft7WJboiEfHkdiK6VyAhEmGKktaG1k)ZOaYMETIIkYAFpX)e8lWnurYUrOGQA)aIB4C0aYg4P(LJfoGKktaG1k)xWZRJdiOg4G42puzaXnCoAarw77j()DWCaHu)ft7WJboWbKKj4qLbXrnuzaXnCoAaXss)KjyzaHu)ft7WJboWbeLmG5dhpuzqCudvgqi1FX0o8yazwdisIdiUHZrdiICq6VykGiYXwuazpCXmaG1kNJwaeSNQSpb1xf9bzF7Hl(YOXkac2tv2NG6RI(GSV9WflvY(lM(EueonCoAbqWEQY(euFv0hK9HEF2Pp2XKYfzUwp6hNruHu)ft7(SzRV9WfzUwp6hNrubqWEQY(euFv0hAbero4Romfq2dl)CAeM6sGdIxrOYacP(lM2HhdiZAarsCgfqmGKjq6beZiIux5IsgWGhWoGSjPbKRCoAaPsqQcjw2NJZfTV4jx3heePVOb0hsTVN49bDa)cCdjwFpWJ9fnG(GaXTuUeqe5GV6WuaHbPkK4)MWESaIB4C0aIihK(lMciICSf9jSKciMzW7jUw2KjHDo1L)7G5cGG9uLbero2IciMzW7jUwwRDLh4Vm1flSdsowbqWEQYahe3(HkdiK6VyAhEmG4gohnGa7ykknFGVYwakGSjPbKRCoAa5rlG2NCSW9jRDWw2xg1hxt9fLl1CFXtmUVxQps3PU0NCgTeqmGKjq6beoHPpp)Ds9bT(iiMmwm95eM6dcOp5yH)YAhS7dY(2dxSuj7Vy67rr40W5OfonctDjWbXFyOYacP(lM2HhdiUHZrdi1ULYbKnjnGCLZrdiqKl5(QDlL7JN(aueGK199srdG6lYX4jkQeqmGKjq6bK9WLA3s5cGG9uL9bT(QOVN6JGyYyX0NtykWbXTRqLbes9xmTdpgqCdNJgqGDmfLMpWxzlafq2K0aYvohnGabsUu33d23kihqYX6dcJI7dqrasw3xg1NCL0DQl9nk13cEEDCFXhl8UpJBjP(SK9XtFWPu2hxt9nRRdGT0KJ1hp9bOiajR7dcJIl9fqmGKjq6beoHP(euFc((GSVxROOcSJPO08JdCUUaiypvzFqRVfZUa7qCFp1hbXKXIPpNWuGdIdDdvgqi1FX0o8yaztsdix5C0ace4eq9TjShJ29XGufsSSVu7Zvon5QZ5O9nr99aKjHDo1L(ECWCjGOomfqi41yaYX)bSvxnuaXasMaPhqe5G0FXuHbPkK4)MWES(GwFvGcbe3W5ObecEngGC8FaB1vdf4G4c(qLbes9xmTdpgqCdNJgqKw6lEM93HjUoMKdigqYei9aIihK(lMkmivHe)3e2J1h06d6gquhMcisl9fpZ(7WexhtYboioekuzaHu)ft7WJbe3W5Obe5yHXeZPU8bwVXcigqYei9aIihK(lMkmivHe)3e2J1h06dcfquhMciYXcJjMtD5dSEJf4G42DHkdiK6VyAhEmG4gohnGyjPFYeCaXasMaPhqe5G0FXuHbPkK4)MWES(GwFpmGOomfquhMQkR99eN2)b8(NOppays5ahehvuiuzaHu)ft7WJbe3W5ObK1Ax5b(ltDXc7GKJfq2K0aYvohnGiyJ6JRP(wXEmc0xk7ZsM6sFqG4wklwFrjG6dcI03O9zMbVN4AFCnP9fny8eVV4jx33d8yaXasMaPhqyhtkxQDlLlK6VyA3hK9jYbP)IPYEy5NtJWuxcCqCurnuzaHu)ft7WJbedizcKEaHDmPCP2TuUqQ)IPDFq2Nzg8EIRL1Ax5b(ltDXc7GKJvaeSNQSpb1hkeqCdNJgq2KjHDo1L)7G5aheh1kcvgqi1FX0o8yaXnCoAaztMe25ux(VdMdiBsAa5kNJgqeSr9X1uFRypgb6lL9zjtDPpeOdX6lkbuFpWJ9nAFMzW7jU2hxtAFrdgpXtDPV4jx3heejGyajtG0diSJjLlYAFpX)e8lWnuHu)ft7(GSproi9xmv2dl)CAeM6sGdIJQ9dvgqi1FX0o8yaXasMaPhqyhtkxK1(EI)j4xGBOcP(lM29bzFMzW7jUw2KjHDo1L)7G5cGG9uL9jO(qHaIB4C0aYATR8a)LPUyHDqYXcCqCuFyOYacP(lM2HhdigqYei9aYE4ILkz)ftFpkcNgohTaiypvzFqRpOBaXnCoAaXsLS)IPVhfHtdNJg4G4OAxHkdiK6VyAhEmGyajtG0di7Hl(YOXkac2tv2h067Hbe3W5ObeFz0yboioQq3qLbes9xmTdpgqmGKjq6bK9WfzUwp6hNrubqWEQY(GwFpmG4gohnGiZ16r)4mIcCqCuf8HkdiK6VyAhEmGyajtG0di7HlMbaSw5C0cGG9uL9bT(EyaXnCoAaXmaG1kNJg4G4OcHcvgqi1FX0o8yaXnCoAab2XuuA(aFLTauaztsdix5C0aIDJIaKSUpimkUppIjqFCn13Sskb6lJ6B7aHlyhq)vaT2x8XcV7Z4wsQplzF80hCkL959bHrX9bOiajRdigqYei9acNWuFcQpbFFq23Rvuub2XuuA(XboxxaeSNQSpO1xf9bb03IzxGDiUVN6JGyYyX0NtykWbXr1UluzaHu)ft7WJbKnjnGCLZrdiqKJX9TDGWfSdO)kGw7lJ6dcw7kpW9HK6If2bjhRVu2NXcaiLXX6JtJWuxciUHZrdighJ)UHZr)4uYbejdsdheh1aIbKmbspGShUSw7kpWFzQlwyhKCScNgHPUeqWPK)QdtbKTdeUGDa9xb0AGdIxbkeQmGqQ)IPD4XaYMKgqUY5Obe7EoXPGbQpxJ13W1eOpj7CFmivHel7lJ6dcw7kpW9HK6If2bjhRVu2hNgHPUeqCdNJgqmog)DdNJ(XPKdisgKgoioQbedizcKEazpCzT2vEG)YuxSWoi5yfonctDjGGtj)vhMcis25pdsviXYaheVcudvgqi1FX0o8yaXnCoAab2XuuA(aFLTauaztsdix5C0acc7gH9bHDmfLM(qXaNR7JN(SVy9nG(aueGK19fVM0(wiMtDPp8eVp0Zn5yCS(WZim1L(IgqFEFghBSWot7(ul4xciwFVwCFpSyxY(aeSNAQl9LY(4AQpajTWCFtuFmj5ux6lEY19vzfcE0cigqYei9acNWuFcQpbFFq2h699AffvGDmfLMFCGZ1fj7gH9bT(SFF2S13Rvuub2XuuA(XboxxaeSNQSpO13dl2vFOf4G4vurOYacP(lM2HhdiUHZrdiWoMIsZh4RSfGciBsAa5kNJgqeC7DY5OoUpiSDRp5kPBzFXRjTpcIzG3NS2bBzFoG6Zf5j2FXuFUU7JsUMa9bbRDLh4(qsDXc7GKJ1xk7JtJWuxeRVb0hxt9fLl1CFPSps3PUucigqYei9ac69ThUSw7kpWFzQlwyhKCScNgHPU0NnB9Xjm955VtQpO1Nzg8EIRL1Ax5b(ltDXc7GKJvaeSNQSp06dY(qVVxROOcSJPO08JdCUUiz3iSpO1N97ZMT(KJf(lRDWUpb1hQ9HwGdIxH9dvgqi1FX0o8yaXnCoAazd8u)YXchq2K0aYvohnGi427KZrDCFpaWtTpKXc3NXLCFXRjTpiisFPSponctDjGyajtG0di7HlR1UYd8xM6If2bjhRWPryQlboiEfpmuzaHu)ft7WJbe3W5ObeFz0ybKnjnGCLZrdiq)eVVhSVvqoGKJ13E4(aueGK19fVM0(aueGK1(lMkbedizcKEabqrasw7VykWbXRWUcvgqi1FX0o8yaXasMaPhqaueGK1(lMciUHZrdiwQK9xm99OiCA4C0aheVcOBOYacP(lM2HhdigqYei9acGIaKS2FXuaXnCoAaXmaG1kNJg4G4vi4dvgqi1FX0o8yaXasMaPhqyhtkxK5A9OFCgrfs9xmT7dY(aueGK1(lMciUHZrdiYCTE0poJOaheVciuOYacP(lM2HhdiUHZrdiryswBaEehqsLjaWAL)zua51kkQiAWoNy6lhSis5FTfSRtUlwRbedizcKEarow43u3frd25etF5Gfrkxi1FX0oGSjPbKRCoAabcmMK1gGhX9XtFWEQSNAFcghSZjM6dzWIiLlboiEf2DHkdiK6VyAhEmG4gohnGu7wkhq2K0aYvohnGa9t8hCfKdi5y9v7wk3hGIaKSUeqmGKjq6bK9WLA3s5cGG9uL9bT(SFGdIBFuiuzaHu)ft7WJbe3W5ObKnWt9lhlCaztsdix5C0aIDVMktaG1kNVyQVhaPptTRkH7lJ6lo1xTlI6JRP(EGh771kkQeqmGKjq6bKxROOYMmjSZPU8FhmxSwdCqC7JAOYacP(lM2HhdiUHZrdiBGN6xow4aIbKmbspGWoMuUiR99e)tWVa3qfs9xmT7dY(20Rvuurw77j(NGFbUHkac2tv2h06Z(9zZwFB61kkQiR99e)tWVa3qfj7gH9bT(SFajvMaaRv(NrbKn9AffvK1(EI)j4xGBOIKDJqbv1(qUPxROOIS23t8pb)cCdvaeSNQuq2pWbXTFfHkdiPYeayTYbeudiUHZrdiBGN6xow4acP(lM2HhdCqC7B)qLbe3W5ObezTVN4)3bZbes9xmTdpg4ah4ah4qa]] )


end