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


    spec:RegisterPack( "Affliction", 20210707, [[davLZcqiqvTiqKqpcfHnPu6tOOgfO4uGuRIQsvVceAwuvClvsyxc9lvsnmqehduzzsHEMkjnnPiDnuKABGOY3OQuACGOQZrvjP1HIO5bk5Ekf7duLdsvjSqqWdbrzIGi1frrI2ivLe9ruKaNKQsXkbjVefjiZeuk3KQs0oLc(jisAOOiPLsvj1trPPkf1vbrI2kksOVsvPYyLIyVc(RkgSQomLfRs9yQmzLCzKnlv(SuA0kvNw0QPQKWRHKzd1THy3K(TKHlvDCvs0YbEoQMoX1PkBhs9DvIXdkvNNQQ1dIemFu4(Oib1(vCaUqZb2LjuOHgHKgHds8TqIVncjqEMUr4AAGv83tb2EZHYAPaRAiuG1x01HtNKLgy7n)4YwHMdS8Yd4Oa7Ui9CM86RBtz37o6kKR5jIh2KSuhW6KR5jI76a7TxIfFJgUdSltOqdncjnchK4BHeFBesG8mDJqIVAGL3tUqdnc5y6a7EUwKgUdSlI7cS(IUoC6KS059Dgaxouduq5H9pVV1N5BesAeUbQbkiB30wIZKduxX8(I1IwZZ2ty88Ww5qfhOUI59fRfTMhstOlpW8(sRnDXbQRyEFXArR5VbKHYTBQs45XvB6MVRaZdPbwQZZwE44a1vmFZxid18(sdtDPBEFT1lEaAEC1MU5LA(lfa18z38(lpMb08ijNNA7828IHjvMp15LDtMhuxIduxX8mLQDJP591gsVPY8(IUoC6KSu(8mv0m15fdtQehOUI5B(czO4Zl18g6kxZFJRlP2opK2aOAXgGMp15r8WsEfIbAjz(lxxZdPHuBMpVxFCG6kMhYkDrkNMNxi08qAdGQfBaAEMkG6N3zymFEPMhqlphnVRq69etYsNxsekoqDfZZsY88cHM3zy8XCsw6bNCzEsfqs85LAEUasNmVuZBORCnVBNCOsTDECYf(8YUjZFPuML5VP5bK52P18WyTwQWh64a1vmpKQI9pplrR5l1rZ3dORO3dJJduxX8(ILVcpUmpKI3EaDEidsZN)M6kanpPR5RU57Y2DbsX5XvB6MxQ5T(ES)5lf7FEPM)U4857Y2DHppmAjZlaJVpFV5qXHooqDfZ7Ret8DhW6KRzkwytsmnpBHrtQmVZuhHpz38UDtBP18snFQcbaE9Yj7Ib2Eq1LykWYemX8(IUoC6KS059DgaxoudumbtmpuEy)Z7B9z(gHKgHBGAGIjyI5HSDtBjotoqXemX8xX8(I1IwZZ2ty88Ww5qfhOycMy(RyEFXArR5H0e6YdmVV0AtxCGIjyI5VI59fRfTM)gqgk3UPkHNhxTPB(UcmpKgyPopB5HJdumbtm)vmFZxid18(sdtDPBEFT1lEaAEC1MU5LA(lfa18z38(lpMb08ijNNA7828IHjvMp15LDtMhuxIdumbtm)vmptPA3yAEFTH0BQmVVORdNojlLpptfntDEXWKkXbkMGjM)kMV5lKHIpVuZBORCn)nUUKA78qAdGQfBaA(uNhXdl5vigOLK5VCDnpKgsTz(8E9XbkMGjM)kMhYkDrkNMNxi08qAdGQfBaAEMkG6N3zymFEPMhqlphnVRq69etYsNxsekoqXemX8xX8SKmpVqO5DggFmNKLEWjxMNubKeFEPMNlG0jZl18g6kxZ72jhQuBNhNCHpVSBY8xkLzz(BAEazUDAnpmwRLk8HooqXemX8xX8qQk2)8SeTMVuhnFpGUIEpmooqXemX8xX8(ILVcpUmpKI3EaDEidsZN)M6kanpPR5RU57Y2DbsX5XvB6MxQ5T(ES)5lf7FEPM)U4857Y2DHppmAjZlaJVpFV5qXHooqXemX8xX8(kXeF3bSo5AMIf2KetZZwy0KkZ7m1r4t2nVB30wAnVuZNQqaGxVCYU4a1aL5KSuEShqUc52KnDe(SkKunjl1NSBJKie8GKTWVNKOHt00w4F711fBbjsLa6uDhU5azx6OOx)aL5KSuEShqUc52eiU5AUhcsPNEsgOmNKLYJ9aYvi3MaXnx7XPtkeIpQHqBKcHov3bPuUakp(XvkxaEojlLpqzojlLh7bKRqUnbIBU2JtNuieFudH2Wlmz78dNCasoc5218k9ObkZjzP8ypGCfYTjqCZ1TGePsaDQUd3CGSlDKpz3gXWKkXwqIujGov3HBoq2LoksQDJP1aL5KSuEShqUc52eiU56omX3DaRtgOmNKLYJ9aYvi3MaXnxJ2aPDJjFudH2SkHFaKT87dAd7rBmNKOPZQKORaaVEjlfEqYwZjjA6SkjATL6hEqYwZjjA6Skj6PCXUX0X66WPtYsHhKSfg4lgMujYZ(9sp4SJIKA3yAXGH5KenDwLe5z)EPhC2rWdsGElmRsI97MkfYHNARh2aP4pkPdvQTmyaFXWKkX(DtLc5WtT1dBGu8hj1UX0c6bkZjzP8ypGCfYTjqCZ1EC6KcH4JAi0gdsb(Ubm(PRu5uDN(6cbgOmNKLYJ9aYvi3MaXnxZjADQUJRaaVEjl1hCQ0XT2ahK4t2TH3ty8rmqlj8iNO1P6oUca86LS0Jve82C1bkZjzP8ypGCfYTjqCZ17MNkduMtYs5XEa5kKBtG4MR9uUy3y6yDD40jzPdudumbtmptjStopHwZtOjG)5LeHMx2P5nNuG5t(8gAlX2nMIduMtYs5B49egFWLd1aL5KSuoe3C9IqxEGdI1MUbkZjzPCiU5ANHXhZjzPhCYfFudH2yf5dxaPt2aNpz3gZjjA6qkHKehExDGIjM3x4KS05Xjx4Z3vG5fqQOiz(BA3qNfiopRycFEdqZZn00A(Ucm)n1vaAE2YdpVVUKR9ni9KUsTDEiZeJlGQFNUMPUBQuiZZMARh2aP43N5lzNaxsonFPZ7QcVQl6aL5KSuoe3CTZW4J5KS0do5IpQHqBeqQOi5W7XPCC7Kd1aL5KSuoe3CTZW4J5KS0do5IpQHqBwe28tRJasffj8bkZjzPCiU5ANHXhZjzPhCYfFudH2WftocivuKW9HlG0jBGZNSBdmRsI8YdFaLeL0Hk1wgmwLetKEsxP2ECMyCbu970zvsushQuBzWyvsSF3uPqo8uB9Wgif)rjDOsTf6T8YdF47gybVRYGXQKi6ethXsvIs6qLAldgIHjvI86Yr2PdNOfFGYCswkhIBU2zy8XCsw6bNCXh1qOnldXAPJasffjCFYUnUcnPMkrnB3LtNrBHb(OnqA3ykkGurrYH3JtHbdxv4vDrJ8YdFaLebeILkhEncjmyadAdK2nMIcivuKCkL26QcVQlAKxE4dOKiGqSu5WsaPIIKiCrxv4vDrJacXsLdndgWG2aPDJPOasffjh5sT1vfEvx0iV8WhqjraHyPYHLasffjXgJUQWR6IgbeILkhAOzWWvOj1ujIMuz3pylmWhTbs7gtrbKkkso8ECkmy4QcVQlAmr6jDLA7XzIXfq1VtraHyPYHxJqcdgWG2aPDJPOasffjNsPTUQWR6IgtKEsxP2ECMyCbu97ueqiwQCyjGurrseUORk8QUOraHyPYHMbdyqBG0UXuuaPIIKJCP26QcVQlAmr6jDLA7XzIXfq1VtraHyPYHLasffjXgJUQWR6IgbeILkhAOzWagxHMutLOsoqHlWIbdxHMutLik)G0ugmCfAsnvIAPe0BHb(OnqA3ykkGurrYH3JtHbdxv4vDrJ97MkfYHNARh2aP4pcielvo8AesyWag0giTBmffqQOi5ukT1vfEvx0y)UPsHC4P26Hnqk(JacXsLdlbKkksIWfDvHx1fncielvo0myadAdK2nMIcivuKCKl1wxv4vDrJ97MkfYHNARh2aP4pcielvoSeqQOij2y0vfEvx0iGqSu5qdndgWxmmPsSF3uPqo8uB9Wgif)rsTBmT2cd8rBG0UXuuaPIIKdVhNcdgUQWR6Ig5EiiLEwgavl2aueqiwQC41iKWGbmOnqA3ykkGurrYPuARRk8QUOrUhcsPNLbq1InafbeILkhwcivuKeHl6QcVQlAeqiwQCOzWag0giTBmffqQOi5ixQTUQWR6Ig5EiiLEwgavl2aueqiwQCyjGurrsSXORk8QUOraHyPYHg6bkMyEi4b055LhEE(Ubw85ZU57Y2Dz(KpVHrkUmFHMaduMtYs5qCZ1igM6s3by9IhG8j72CxC(2USDxoacXsLdlc2jNNqhjriFpV8Wh(UbwBxLe9uUy3y6yDD40jzPrjDOsTDGIjM330nVRqtQPY8RsUMPUBQuiZZMARh2aP4F(KppWt1uB9zEponpK2aOAXgGMxQ5jyxiDnVStZ78aasL55KmqzojlLdXnx7mm(yojl9GtU4JAi0MLbq1InaD6buVpz3gyCfAsnvIOjv29d2UkjMi9KUsT94mX4cO63PZQKOKouP2U1vfEvx0i3dbP0ZYaOAXgGIacXsLdRg3cZQKy)UPsHC4P26Hnqk(JacXsLdVgzWa(IHjvI97MkfYHNARh2aP4hAOzWagxHMutLOMT7YPZOTRsI8YdFaLeL0Hk12TUQWR6Ig5EiiLEwgavl2aueqiwQCy14wywLe73nvkKdp1wpSbsXFeqiwQC41idgWxmmPsSF3uPqo8uB9Wgif)qdndgWaJRqtQPsujhOWfyXGHRqtQPseLFqAkdgUcnPMkrTuc6TRsI97MkfYHNARh2aP4pkPdvQTBxLe73nvkKdp1wpSbsXFeqiwQCy1i0dumX8(AQdq895xLWNNma2)8z38TvQTZNQuZBZZ3nWAEEpPRuBNVF340aL5KSuoe3CTZW4J5KS0do5IpQHqBwLC6buVpz3gyCfAsnvIA2UlNoJ2c)vjrE5HpGsIs6qLA7wxv4vDrJ8YdFaLebeILkhwnfAgmGXvOj1ujIMuz3pyl8xLetKEsxP2ECMyCbu970zvsushQuB36QcVQlAmr6jDLA7XzIXfq1VtraHyPYHvtHMbdyGXvOj1ujQKdu4cSyWWvOj1ujIYpinLbdxHMutLOwkb9wXWKkX(DtLc5WtT1dBGu8Vf(RsI97MkfYHNARh2aP4pkPdvQTBDvHx1fn2VBQuihEQTEydKI)iGqSu5WQPqpqXeZ7B6MNPUBQuiZZMARh2aP4F(KpVKouP26Z8PmFYNNBD08snVhNMhsBauZZwE4bkZjzPCiU56LbqD4Lh2NSBZQKy)UPsHC4P26Hnqk(Js6qLA7aL5KSuoe3C9YaOo8Yd7t2Tb(IHjvI97MkfYHNARh2aP4FlmRsI8YdFaLeL0Hk1wgmwLetKEsxP2ECMyCbu970zvsushQuBHEGIjMN1V6MNPUBQuiZZMARh2aP4F(lPSpptrsLD)GRBiB3L59vA08UcnPMkZVkXN5lzNaxsonVhNMV05DvHx1fnoVVPBEMsKE)aYWZdPcwQPoA(BVUU5t(8P6kKuB9z(9cVM3tLepFkmZNhq2Y)8WahKFEo5kDXN36ecmVhNGEGYCswkhIBUUF3uPqo8uB9Wgif)(KDBCfAsnvIA2UlNoJ2kjcbpMERRk8QUOrE5HpGsIacXsLdl42cJasffjrcP3pGm8Pal1uhfDvHx1fncielvoSGdY1idgWNUsVSVNwrcP3pGm8Pal1uhb9aL5KSuoe3CD)UPsHC4P26Hnqk(9j724k0KAQertQS7hSvsecEm9wxv4vDrJjspPRuBpotmUaQ(DkcielvoSGBlmcivuKejKE)aYWNcSutDu0vfEvx0iGqSu5WcoixJmyaF6k9Y(EAfjKE)aYWNcSutDe0dumX8nqoqHlWA(lPSpVV0Wux6M33bmzFENXf(897MkfY88uB9Wgif)ZN684uP5VKY(8qAYLiMKA78qOWYaL5KSuoe3CD)UPsHC4P26Hnqk(9j724k0KAQevYbkCbwBbEk1vGwkIyyQlDNlat23kjcbpMERRk8QUOXf5setsT9CxyjcielvoSU6wyeqQOijsi9(bKHpfyPM6OORk8QUOraHyPYHfCqUgzWa(0v6L990ksi9(bKHpfyPM6iOhOyI5HuLDcmVRqtQPcFEys1H9wP2oVw6v4l9DZ3a5af0Z7mUmptLD(sN3vfEvx0bkZjzPCiU56(DtLc5WtT1dBGu87t2TbgxHMutLik)G0ugmCfAsnvIAPedgW4k0KAQevYbkCbwBHpWtPUc0sredtDP7CbyYo0qVfgbKkksIesVFaz4tbwQPok6QcVQlAeqiwQCybhKRrgmGpDLEzFpTIesVFaz4tbwQPoc6bkZjzPCiU56(DtLc5WtT1dBGu87t2T5U48TDz7UCaeILkhwWb5gOyI59nDZZu3nvkK5ztT1dBGu8pFYNxshQuB9z(uyMpVKi08snVhNMVKDcmpI5ROaZVkHpqzojlLdXnx7mm(yojl9GtU4JAi0gxHMutfFYUnRsI97MkfYHNARh2aP4pkPdvQTBHXvOj1ujQz7UC6mIbdxHMutLiAsLD)aOhOmNKLYH4MRT2s97JZVdthXaTKW3aNpz3MvjrRTu)raHyPYHvthOmNKLYH4MR3npvgOyI5zRlZl708SeT4Zx68xDEXaTKWNp7MpL5tUYSmVZdaivW(Np157Wz7UmFbMV05LDAEXaTKeN33LY(8Sz)EPZdBzhnFkmZN3W8A(BsecmVuZ7XP5zjAnFHMaZJyQNHX(N367X(tTD(RopKvaGxVKLYJduMtYs5qCZ1CIwNQ74kaWRxYs9j72yojrthsjKK4WRXTIHjvI86Yr2PdNOfFl8xLe5eTov3XvaGxVKLgL0Hk12TWp1thoB3LbkZjzPCiU5AorRt1DCfa41lzP(KDBmNKOPdPessC414wXWKkrE2Vx6bND0w4VkjYjADQUJRaaVEjlnkPdvQTBHFQNoC2UlBxLeDfa41lzPraHyPYHvthOmNKLYH4MRrNy6iwQIpz3gy4Lh(W3nWcEWXGH5KenDiLqsIdVgHERRk8QUOrUhcsPNLbq1InafbeILkhEW14aL5KSuoe3CTNYf7gthRRdNojl1NSBJ5KenDwLe9uUy3y6yDD40jzPBGegmK0Hk12TRsIEkxSBmDSUoC6KS0iGqSu5WQPduMtYs5qCZ18SFV0do7iFC(Dy6igOLe(g48j72SkjYZ(9sp4SJIacXsLdRMoqzojlLdXnx7mm(yojl9GtU4JAi0gxHMutfF4ciDYg48j72aFxHMutLOsoqHlWAGIjM3x03J9ppKvaGxVKLopIPEgg7F(sNhUROX5fd0sc3N5lW8Lo)vN)sk7Z7lU5f2tO5HSca86LS0bkZjzPCiU5AxbaE9swQpo)omDed0scFdC(KDBmNKOPdPessCy10RagXWKkrED5i70Ht0IZGHyysLip73l9GZoc6TRsIUca86LS0iGqSu5WQXbkMyEFrNqG5LDA(QNuc4Z88EsxZBZZ3nWA(l7KoVjZZ0Zx68(sdtDPBEFT1lEaAEPM3qx5A(cnbCwFFQTduMtYs5qCZ1igM6s3by9IhG8j72Wlp8HVBGf8A6wjri41iCdumX8(UDsNxlzEUF1LA78m1DtLczE2uB9Wgif)Zl18mfjv29dUUHSDxM3xPr(mpRhcsPZdPnaQwSbO5ZU5nmE(vj85nanV13JtAnqzojlLdXnx7mm(yojl9GtU4JAi0MLbq1InaD6buVpz3gyCfAsnvIOjv29d2cFXWKkX(DtLc5WtT1dBGu8VDvsmr6jDLA7XzIXfq1VtNvjrjDOsTDRRk8QUOrUhcsPNLbq1InafbKT8dndgW4k0KAQe1SDxoDgTf(IHjvI97MkfYHNARh2aP4F7QKiV8WhqjrjDOsTDRRk8QUOrUhcsPNLbq1InafbKT8dndgWaJRqtQPsujhOWfyXGHRqtQPseLFqAkdgUcnPMkrTuc6TUQWR6Ig5EiiLEwgavl2aueq2Yp0dumX8qk508qAdGAE2YdpF2npK2aOAXgGM)sPmlZFtZdiB5FER1s1N5lW8z38YobO5VKy88308MmpMmUmFJZJuaAEiTbq1InanVhN4duMtYs5qCZ1ldG6WlpSpz3M7IZ36QcVQlAK7HGu6zzauTydqraHyPYHxx2UlhaHyPY3cd8fdtQe73nvkKdp1wpSbsXpdgUQWR6Ig73nvkKdp1wpSbsXFeqiwQC41LT7YbqiwQCOhOmNKLYH4MRxga1HxEyFYUn3fNVf(IHjvI97MkfYHNARh2aP4FRRk8QUOrUhcsPNLbq1InafbeILkhIUQWR6Ig5EiiLEwgavl2auC5bmjlfwDz7UCaeILkFGIjMhYmXTFfggpFkeY8ECRLMVRaZBQFzp1251sMN3tUSlP18eMtx2janqzojlLdXnx7mm(yojl9GtU4JAi0MuiKbkMGjM3xtDaIVpp7UTQlZZuICdmhn)n1vaAEEpPRuBNNVBGfF(sN3xAyQlDZ7RTEXdqduMtYs5qCZ1odJpMtYsp4Kl(OgcTHt(KDBedtQe572QUCiKBG5OiP2nMwBHzr3EDDr(UTQlhc5gyokYfZHcwW04vyojlnY3TvD5CxyjM6PdNT7c0mySOBVUUiF3w1LdHCdmhfbeILkhwxf6bkMyEiLCAEFPHPU0nVV26fpan)LDsNhX8vuG5xLWN3a08E9(mFbMp7Mx2jan)LeJN)MMNNTA2LotL5LeHM3tLepVStZReSlZZu3nvkK5ztT1dBGu8hN330nVNK4esHuBN3xAyQlDZ77aMS7Z87fEnVnpF3aR5LAEa1bi((8Yon)Txx3aL5KSuoe3CnIHPU0DawV4biFYUnWSkjIoX0rSuLOKouP2YGXQKyI0t6k12JZeJlGQFNoRsIs6qLAldgRsI8YdFaLeL0Hk1wO3cd8bEk1vGwkIyyQlDNlat2zW42RRlIyyQlDNlat2JCXCOG1vzWGxE4dF3al4bh0dumX8qk508(sdtDPBEFT1lEaAEPMhXsvSuNx2P5rmm1LU5VamzF(BVUU59ujXZZ3nWIpVs0AEPM)MMVLucycTMVRaZl708kb7Y83EaUm)Lux1L5HPrizEo5kDXNp5ZJuaAEz3055EDDPljvMxQ5BjLaMqZF1557gyXHEGYCswkhIBUgXWux6oaRx8aKpz3gGNsDfOLIigM6s35cWK9TUQWR6Ig5Lh(akjcielvo8Aes2E711frmm1LUZfGj7raHyPYHvthOyI59LwQIL68(sdtDPBEFhWK95nzEdJNxseIpFxbMx2P5BGCGcxG18fyEMc5hKMoVRqtQPYaL5KSuoe3CnIHPU0DawV4biFYUnapL6kqlfrmm1LUZfGj7BHXvOj1ujQKdu4cSyWWvOj1ujIYpinf6T3EDDredtDP7CbyYEeqiwQCy10bkMyEiLCAEFPHPU0nVV26fpanFPZZu3nvkK5ztT1dBGu8pVZ4c3N5rmuP2op3dqZl18CdnnVnpF3aR5LAEUyouZ7lnm1LU59Dat2Np7M3JNA78PmqzojlLdXnxJyyQlDhG1lEaYNSBJyysLy)UPsHC4P26Hnqk(3cZQKy)UPsHC4P26Hnqk(Js6qLAldgUQWR6Ig73nvkKdp1wpSbsXFeqiwQC41itZGXDX5BLeHosDwjblxv4vDrJ97MkfYHNARh2aP4pcielvo0BHb(apL6kqlfrmm1LUZfGj7myC711frmm1LUZfGj7rUyouW6QmyWlp8HVBGf8Gd6bkZjzPCiU5AedtDP7aSEXdq(KDBedtQe51LJSthorl(aftmpKgyPopSLD08jF(sX(N3MhsZuzNV1sD(lPSpVVrj0Py3yAEinHKCAELmW8igSppxmhkECEFt38Dz7UmFYN3UlpzEPMN018RAETK5rsoFEEpPRuBNx2P55I5qXhOmNKLYH4MRxal1do7iFYUn3EDDXuj0Py3y6SiKKtrUyouWRPqcdg3EDDXuj0Py3y6SiKKtrV(T3fNVTlB3LdGqSu5WQPduMtYs5qCZ1odJpMtYsp4Kl(OgcTXvOj1uzGYCswkhIBU2Al1Vpo)omDed0scFdC(KDBauhG472nMgOmNKLYH4MR9uUy3y6yDD40jzP(KDBmNKOPZQKONYf7gthRRdNojlDdKWGHKouP2UfqDaIVB3yAGYCswkhIBUMN97LEWzh5JZVdthXaTKW3aNpz3ga1bi(UDJPbkZjzPCiU5AxbaE9swQpo)omDed0scFdC(KDBauhG472nM2AojrthsjKK4WQPxbmIHjvI86Yr2PdNOfNbdXWKkrE2Vx6bNDe0duMtYs5qCZ1DyIV7awN4t2THxE47uxr0f2KethEHrtQ4tQcbaE9Yj72C711frxytsmD4fgnPs0RFGYCswkhIBUEbSup8Yd7tQcbaE9Yg4gOmNKLYH4MR572QUCUlSmqnqzojlLhTI20VBQuihEQTEydKI)bkZjzP8Ovee3C9U5PYaL5KSuE0kcIBU2zy8XCsw6bNCXh1qOnldGQfBa60dOEFYUnUcnPMkr0Kk7(bBxLetKEsxP2ECMyCbu970zvsushQuB36QcVQlAK7HGu6zzauTydqrazl)BHzvsSF3uPqo8uB9Wgif)raHyPYHxJmyaFXWKkX(DtLc5WtT1dBGu8dndgUcnPMkrnB3LtNrBxLe5Lh(akjkPdvQTBDvHx1fnY9qqk9SmaQwSbOiGSL)TWSkj2VBQuihEQTEydKI)iGqSu5WRrgmGVyysLy)UPsHC4P26Hnqk(HMbdyCfAsnvIk5afUalgmCfAsnvIO8dstzWWvOj1ujQLsqVDvsSF3uPqo8uB9Wgif)rjDOsTD7QKy)UPsHC4P26Hnqk(JacXsLdRghOmNKLYJwrqCZ1CIwNQ74kaWRxYs9j72igMujYRlhzNoCIw8TotpCIwduMtYs5rRiiU5AorRt1DCfa41lzP(KDBGVyysLiVUCKD6WjAX3c)vjrorRt1DCfa41lzPrjDOsTDl8t90HZ2Dz7QKORaaVEjlncOoaX3TBmnqzojlLhTIG4MRT2s97JZVdthXaTKW3aNpz3gZjjA6SkjATL6hwnDl8xLeT2s9hL0Hk12bkZjzP8Ovee3CT1wQFFC(Dy6igOLe(g48j72yojrtNvjrRTu)WBtt3cOoaX3TBmTDvs0Al1FushQuBhOmNKLYJwrqCZ1EkxSBmDSUoC6KSuFYUnMts00zvs0t5IDJPJ11HtNKLUbsyWqshQuB3cOoaX3TBmnqzojlLhTIG4MR9uUy3y6yDD40jzP(487W0rmqlj8nW5t2Tb(s6qLA72E09IHjvIadP3u5yDD40jzP8iP2nMwBnNKOPZQKONYf7gthRRdNojlfwxDGYCswkpAfbXnxJoX0rSufFYUn8YdF47gybp4gOmNKLYJwrqCZ1odJpMtYsp4Kl(OgcTXvOj1uXhUasNSboFYUnW3vOj1ujQKdu4cSgOmNKLYJwrqCZ1odJpMtYsp4Kl(OgcTzzauTydqNEa17t2TbgxHMutLiAsLD)GTW4QcVQlAmr6jDLA7XzIXfq1Vtrazl)mySkjMi9KUsT94mX4cO63PZQKOKouP2c9wxv4vDrJCpeKspldGQfBakciB5FlmRsI97MkfYHNARh2aP4pcielvo8AKbd4lgMuj2VBQuihEQTEydKIFOHElmW4k0KAQevYbkCbwmy4k0KAQer5hKMYGHRqtQPsulLGERRk8QUOrUhcsPNLbq1InafbeILkhwnUfMvjX(DtLc5WtT1dBGu8hbeILkhEnYGb8fdtQe73nvkKdp1wpSbsXp0qZGbmUcnPMkrnB3LtNrBHXvfEvx0iV8Whqjrazl)mySkjYlp8busushQuBHERRk8QUOrUhcsPNLbq1InafbeILkhwnUfMvjX(DtLc5WtT1dBGu8hbeILkhEnYGb8fdtQe73nvkKdp1wpSbsXp0qpqzojlLhTIG4MRxga1HxEyFYUn3fNV1vfEvx0i3dbP0ZYaOAXgGIacXsLdVUSDxoacXsLVfg4lgMuj2VBQuihEQTEydKIFgmCvHx1fn2VBQuihEQTEydKI)iGqSu5WRlB3LdGqSu5qpqzojlLhTIG4MRxga1HxEyFYUn3fNV1vfEvx0i3dbP0ZYaOAXgGIacXsLdrxv4vDrJCpeKspldGQfBakU8aMKLcRUSDxoacXsLpqzojlLhTIG4MRDggFmNKLEWjx8rneAtkeYaL5KSuE0kcIBU2zy8XCsw6bNCXh1qOnlcB(P1raPIIe(aL5KSuE0kcIBU2zy8XCsw6bNCXh1qOnldXAPJasffj8bkZjzP8Ovee3CTZW4J5KS0do5IpQHqB4IjhbKkks4(KDBwLe73nvkKdp1wpSbsXFushQuBzWa(IHjvI97MkfYHNARh2aP4FGYCswkpAfbXnxJyyQlDhG1lEaYNSBZQKi6ethXsvIs6qLA7aL5KSuE0kcIBUgXWux6oaRx8aKpz3MvjrE5HpGsIs6qLA7w4lgMujYRlhzNoCIw8bkZjzP8Ovee3CnIHPU0DawV4biFYUnWxmmPseDIPJyPkduMtYs5rRiiU5AedtDP7aSEXdq(KDB4Lh(W3nWcEnDGYCswkpAfbXnxZZ(9sp4SJ8X53HPJyGws4BGZNSBJ5KenDwLe5z)EPhC2rWAZv3cOoaX3TBmTf(RsI8SFV0do7OOKouP2oqzojlLhTIG4MRDggFmNKLEWjx8rneAJRqtQPIpCbKozdC(KDBCfAsnvIk5afUaRbkZjzP8Ovee3C9cyPEWzh5t2T52RRlMkHof7gtNfHKCkYfZHcEByAiHbJ7IZ3E711ftLqNIDJPZIqsof9632LT7YbqiwQCyX0myC711ftLqNIDJPZIqsof5I5qbVnxLP3UkjYlp8busushQuBhOmNKLYJwrqCZ1DyIV7awN4t2THxE47uxr0f2KethEHrtQ4tQcbaE9Yj72C711frxytsmD4fgnPs0RFGYCswkpAfbXnxVawQhE5H9jvHaaVEzdCduMtYs5rRiiU5A(UTQlN7clduduMtYs5rxHMutLnjspPRuBpotmUaQ(DYNSBd8fdtQe73nvkKdp1wpSbsX)wyCvHx1fnY9qqk9SmaQwSbOiGqSu5WcoiHbdxv4vDrJCpeKspldGQfBakcielvo8yAizRRk8QUOrUhcsPNLbq1InafbeILkhEnY0BDLU8sj6kaWRxsT9Gjca9aL5KSuE0vOj1ubIBUor6jDLA7XzIXfq1Vt(KDBedtQe73nvkKdp1wpSbsX)2vjX(DtLc5WtT1dBGu8hL0Hk12bkZjzP8ORqtQPce3C9ICjIjP2EUlS4t2TXvfEvx0i3dbP0ZYaOAXgGIacXsLdpMElml62RRlUBEQebeILkhEnLbd4lgMujUBEQa9aL5KSuE0vOj1ubIBUMxE4dOeFYUnWxmmPsSF3uPqo8uB9Wgif)BHXvfEvx0i3dbP0ZYaOAXgGIacXsLdlMMbdxv4vDrJCpeKspldGQfBakcielvo8yAiHbdxv4vDrJCpeKspldGQfBakcielvo8AKP36kD5Ls0vaGxVKA7btea6bkZjzP8ORqtQPce3CnV8Whqj(KDBedtQe73nvkKdp1wpSbsX)2vjX(DtLc5WtT1dBGu8hL0Hk12bkZjzP8ORqtQPce3Cn3vEGuBpsk70a1aL5KSuECziwlDeqQOiHVXJtNuieFudH2Wlp8jB1uiWaL5KSuECziwlDeqQOiHdXnx7XPtkeIpQHqBwaYwDjGoOjoNWduMtYs5XLHyT0raPIIeoe3CThNoPqi(OgcTPf7VF)uDhJZtKeBsw6aL5KSuECziwlDeqQOiHdXnx7XPtkeIpQHqB8u3ULkToTyBLMua(HVBouyIpqzojlLhxgI1shbKkks4qCZ1EC6KcH4JAi0g6UuE5HpOthnqnqzojlLhxgavl2a0Phq9BqNy6iwQYaL5KSuECzauTydqNEa1dXnxVmaQdV8WduMtYs5XLbq1InaD6bupe3CDFjzPduMtYs5XLbq1InaD6bupe3CDxcOBCvRbkZjzP84YaOAXgGo9aQhIBU(gx1605b8pqzojlLhxgavl2a0Phq9qCZ13eGtauP2oqzojlLhxgavl2a0Phq9qCZ1odJpMtYsp4Kl(OgcTXvOj1uXNSBd8DfAsnvIk5afUaRbkZjzP84YaOAXgGo9aQhIBUM7HGu6zzauTydqduduMtYs5XfHn)06iGurrcFJhNoPqi(OgcTHq69didFkWsn1r(KDBGXvOj1ujQz7UC6mARRk8QUOrE5HpGsIacXsLdRgHeOzWagxHMutLiAsLD)GTUQWR6IgtKEsxP2ECMyCbu97ueqiwQCy1iKandgW4k0KAQevYbkCbwmy4k0KAQer5hKMYGHRqtQPsulLGEGYCswkpUiS5NwhbKkks4qCZ1EC6KcH4JAi0gUNEJRADmes29ZfFYUnW4k0KAQe1SDxoDgT1vfEvx0iV8WhqjraHyPYHfKdAgmGXvOj1ujIMuz3pyRRk8QUOXePN0vQThNjgxav)ofbeILkhwqoOzWagxHMutLOsoqHlWIbdxHMutLik)G0ugmCfAsnvIAPe0duMtYs5XfHn)06iGurrchIBU2JtNuieFudH2WlpmMej12dW72Vpz3gyCfAsnvIA2UlNoJ26QcVQlAKxE4dOKiGqSu5WcYdndgW4k0KAQertQS7hS1vfEvx0yI0t6k12JZeJlGQFNIacXsLdlip0myaJRqtQPsujhOWfyXGHRqtQPseLFqAkdgUcnPMkrTuc6bkZjzP84IWMFADeqQOiHdXnx7XPtkeIpQHqB472QUqRtbUpv3rkacPIpz3gyCfAsnvIA2UlNoJ26QcVQlAKxE4dOKiGqSu5WQPqZGbmUcnPMkr0Kk7(bBDvHx1fnMi9KUsT94mX4cO63PiGqSu5WQPqZGbmUcnPMkrLCGcxGfdgUcnPMkru(bPPmy4k0KAQe1sjOhOgOmNKLYJRso9aQFJ1wQFFYUnRsIwBP(JacXsLdli)wxv4vDrJCpeKspldGQfBakcielvo8wLeT2s9hbeILkFGYCswkpUk50dOEiU5AE2Vx6bNDKpz3MvjrE2Vx6bNDueqiwQCyb536QcVQlAK7HGu6zzauTydqraHyPYH3QKip73l9GZokcielv(aL5KSuECvYPhq9qCZ1EkxSBmDSUoC6KSuFYUnRsIEkxSBmDSUoC6KS0iGqSu5WcYV1vfEvx0i3dbP0ZYaOAXgGIacXsLdVvjrpLl2nMowxhoDswAeqiwQ8bkZjzP84QKtpG6H4MRDfa41lzP(KDBwLeDfa41lzPraHyPYHfKFRRk8QUOrUhcsPNLbq1InafbeILkhERsIUca86LS0iGqSu5duduMtYs5XuiKnEC6KcHWhOgOmNKLYJCAZU5PYaL5KSuEKtqCZ1lGL6HxEyFsviaWRxoT462WBGZNufca86Lt2Tzr3EDDr(UTQlhc5gyokYfZHcEBU6aL5KSuEKtqCZ18DBvxo3fwgOgOmNKLYJCXKJasffj8nEC6KcH4JAi0Mu5oGNy3y6CLEMkEiNfHoD0aL5KSuEKlMCeqQOiHdXnx7XPtkeIpQHqBsLlapNua(zLOtLo3egpqzojlLh5IjhbKkks4qCZ1EC6KcH4JAi0Mcnb6W1LuBpMMi2XzT0aL5KSuEKlMCeqQOiHdXnx7XPtkeIpQHqBwgafsv6zrouNEpbqChPoAGYCswkpYftocivuKWH4MR940jfcXh1qOniMZUb0HVtKCq84PBGYCswkpYftocivuKWH4MR940jfcXh1qOnDydHov352ebtduMtYs5rUyYraPIIeoe3CThNoPqi(OgcT5IHIucWpDGsxduMtYs5rUyYraPIIeoe3CThNoPqi(OgcTrSBmjNQ7SiEVLGbkZjzP8ixm5iGurrchIBU2JtNuieFudH2WtTZdFmEFcmv4NBB1sNQ70rGYLI)bkZjzP8ixm5iGurrchIBU2JtNuieFudH2WtTZdFAX2knPa8ZTTAPt1D6iq5sX)aL5KSuEKlMCeqQOiHdXnxFJRAD68a(hOmNKLYJCXKJasffjCiU56Ueq34QwduMtYs5rUyYraPIIeoe3C9nb4eavQTdudumX8(oA(vPmlZZ967lGm)Wu45n(8nbs1xpFQZdBEMpZZR59nmJMM3vkAci0AEzp5Zl18giLDessxCGYCswkpkGurrYH3Jt542jhQnOnqA3yYh1qOn8EYLg(qxPx23tlFqBypAdmWaNVNUsVSVNwrcP3pGm8Pal1uhbneHboFpDLEzFpTIPYDapXUX05k9mv8qolcD6iOHimW57PR0l77PvKxEymjsQThG3TFOHimW57PR0l77PvK7P34QwhdHKD)CbAO3a3aL5KSuEuaPIIKdVhNYXTtouqCZ1OnqA3yYh1qOncivuKCkL8bTH9OnWiGurrseU4UXp9GYTvaPIIKiCXDJFCvHx1ff6bkZjzP8OasffjhEpoLJBNCOG4MRrBG0UXKpQHqBeqQOi5ixkFqBypAdmcivuKeBmUB8tpOCBfqQOij2yC34hxv4vDrHEGYCswkpkGurrYH3Jt542jhkiU5A0giTBm5JAi0MLHyT0raPIIeFqBypAdmWhgbKkksIWf3n(PhuUTcivuKeHlUB8JRk8QUOqdndgWaFyeqQOij2yC34NEq52kGurrsSX4UXpUQWR6Icn0myqxPx23tRyl2F)(P6ogNNij2KS0bkZjzP8OasffjhEpoLJBNCOG4MRrBG0UXKpQHqBeqQOi5W7XP4dAd7rBGbTbs7gtrbKkksoLsBrBG0UXuCziwlDeqQOibAgmGbTbs7gtrbKkksoYLAlAdK2nMIldXAPJasffjqZGbmW57rBG0UXuuaPIIKtPe0qeg489OnqA3ykY7jxA4dDLEzFpTGEdCmyadC(E0giTBmffqQOi5ixkOHimW57rBG0UXuK3tU0Wh6k9Y(EAb9g4cSOjapln0qJqsJWbj(wibUa7fdOP2YdS(oFHVUbFtdmfWKZpFZ708jsFbK57kW8mlGurrYH3Jt542jhkMNhqxPxcO188cHM38KcXeAnVB30wIhhOGTuP5BKjNhYkfnbeAnpZcivuKeHl2eMNxQ5zwaPIIKOaxSjmppmnc7qhhOGTuP5VktopKvkAci0AEMfqQOij2ySjmpVuZZSasffjrPXytyEEyAe2HooqbBPsZ3uMCEiRu0eqO18mlGurrseUytyEEPMNzbKkksIcCXMW88W0iSdDCGc2sLMVPm58qwPOjGqR5zwaPIIKyJXMW88snpZcivuKeLgJnH55HPryh64a1aLVZx4RBW30atbm58Z38onFI0xaz(UcmpZUcnPMkmppGUsVeqR55fcnV5jfIj0AE3UPTepoqbBPsZdhtopKvkAci0AEMfdtQeBcZZl18mlgMuj2KiP2nMwmppmWb7qhhOGTuP5HJjNhYkfnbeAnpZUsxEPeBcZZl18m7kD5LsSjrsTBmTyEEyGd2HooqbBPsZ3itopKvkAci0AEMfdtQeBcZZl18mlgMuj2KiP2nMwmppmWb7qhhOGTuP5VktopKvkAci0AEMfdtQeBcZZl18mlgMuj2KiP2nMwmppmWb7qhhOGTuP5BktopKvkAci0AEMfdtQeBcZZl18mlgMuj2KiP2nMwmppmWb7qhhOGTuP5BktopKvkAci0AEMDLU8sj2eMNxQ5z2v6YlLytIKA3yAX88WahSdDCGc2sLMNPzY5HSsrtaHwZZSyysLytyEEPMNzXWKkXMej1UX0I55Hboyh64a1aLVZx4RBW30atbm58Z38onFI0xaz(UcmpZlQZ8WcZZdOR0lb0AEEHqZBEsHycTM3TBAlXJduWwQ08qoMCEiRu0eqO18mlgMuj2eMNxQ5zwmmPsSjrsTBmTyEEtMNPesf2Mhg4GDOJduWwQ08(wMCEiRu0eqO18mlGurrseUytyEEPMNzbKkksIcCXMW88W0uyh64afSLknVVLjNhYkfnbeAnpZcivuKeBm2eMNxQ5zwaPIIKO0ySjmppmnf2HooqbBPsZ7RYKZdzLIMacTMNzXWKkXMW88snpZIHjvInjsQDJPfZZdtJWo0XbkylvAE4GeMCEiRu0eqO18mlgMuj2eMNxQ5zwmmPsSjrsTBmTyEEyGd2HooqbBPsZdxJm58qwPOjGqR5zwmmPsSjmpVuZZSyysLytIKA3yAX88WahSdDCGc2sLMhURYKZdzLIMacTMNzbKkksI2Tl6QcVQlkZZl18m7QcVQlA0UDmppmWb7qhhOGTuP5HRPm58qwPOjGqR5zwaPIIKOD7IUQWR6IY88snpZUQWR6IgTBhZZddCWo0XbkylvAE4yAMCEiRu0eqO18md8uQRaTuSjmpVuZZmWtPUc0sXMej1UX0I55Hboyh64afSLknpCmntopKvkAci0AEMfqQOijA3UORk8QUOmpVuZZSRk8QUOr72X88WahSdDCGc2sLMhoihtopKvkAci0AEMbEk1vGwk2eMNxQ5zg4PuxbAPytIKA3yAX88WahSdDCGc2sLMhoihtopKvkAci0AEMfqQOijA3UORk8QUOmpVuZZSRk8QUOr72X88WahSdDCGc2sLMVr4yY5HSsrtaHwZZSyysLytyEEPMNzXWKkXMej1UX0I55Hboyh64afSLknFJnYKZdzLIMacTMNzXWKkXMW88snpZIHjvInjsQDJPfZZddCWo0XbkylvA(g9Tm58qwPOjGqR5zwmmPsSjmpVuZZSyysLytIKA3yAX88W0iSdDCGc2sLMVrFvMCEiRu0eqO18mlgMuj2eMNxQ5zwmmPsSjrsTBmTyEEyAe2HooqbBPsZFviHjNhYkfnbeAnpZIHjvInH55LAEMfdtQeBsKu7gtlMNhg4GDOJduWwQ08xfoMCEiRu0eqO18mlgMuj2eMNxQ5zwmmPsSjrsTBmTyEEyGd2HooqbBPsZF1MYKZdzLIMacTMNzGNsDfOLInH55LAEMbEk1vGwk2KiP2nMwmppmWb7qhhOGTuP5VktZKZdzLIMacTMNzGNsDfOLInH55LAEMbEk1vGwk2KiP2nMwmppmWb7qhhOGTuP5VkKJjNhYkfnbeAnpZapL6kqlfBcZZl18md8uQRaTuSjrsTBmTyEEyGd2HooqbBPsZFvFltopKvkAci0AEMfdtQeBcZZl18mlgMuj2KiP2nMwmppmWb7qhhOGTuP5VQVLjNhYkfnbeAnpZapL6kqlfBcZZl18md8uQRaTuSjrsTBmTyEEyGd2HooqbBPsZFviptopKvkAci0AEMfdtQeBcZZl18mlgMuj2KiP2nMwmpVjZZucPcBZddCWo0XbkylvA(M2uMCEiRu0eqO18mlgMuj2eMNxQ5zwmmPsSjrsTBmTyEEyAe2HooqbBPsZ3uMMjNhYkfnbeAnpZ8YdFN6k2eMNxQ5zMxE47uxXMej1UX0I55nzEMsivyBEyGd2Hooqnq578f(6g8nnWuato)8nVtZNi9fqMVRaZZSveZZdOR0lb0AEEHqZBEsHycTM3TBAlXJduWwQ08xLjNhYkfnbeAnpZIHjvInH55LAEMfdtQeBsKu7gtlMNhMgHDOJduWwQ08nLjNhYkfnbeAnpZIHjvInH55LAEMfdtQeBsKu7gtlMNhg4GDOJduWwQ08mntopKvkAci0AEMfdtQeBcZZl18mlgMuj2KiP2nMwmppmWb7qhhOGTuP5HRrMCEiRu0eqO18mlgMuj2eMNxQ5zwmmPsSjrsTBmTyEEyUkSdDCGc2sLMhURYKZdzLIMacTMNzXWKkXMW88snpZIHjvInjsQDJPfZZddCWo0XbkylvAE4G8m58qwPOjGqR5zwmmPsSjmpVuZZSyysLytIKA3yAX88MmptjKkSnpmWb7qhhOGTuP5BesyY5HSsrtaHwZZSyysLytyEEPMNzXWKkXMej1UX0I55nzEMsivyBEyGd2HooqbBPsZ3iCm58qwPOjGqR5zwmmPsSjmpVuZZSyysLytIKA3yAX88MmptjKkSnpmWb7qhhOGTuP5BeYXKZdzLIMacTMNzE5HVtDfBcZZl18mZlp8DQRytIKA3yAX88MmptjKkSnpmWb7qhhOgO8ni9fqO18W148MtYsNhNCHhhOcSMNSxGalBIazbwCYfEO5a7YaOAXgGo9aQp0COb4cnhynNKLgyrNy6iwQsGLu7gtRaecsOHgdnhynNKLgyxga1HxE4alP2nMwbieKqdxn0CG1CswAGTVKS0alP2nMwbieKqdnn0CG1CswAGTlb0nUQvGLu7gtRaecsObMo0CG1CswAG9gx1605b8hyj1UX0kaHGeAaYfAoWAojlnWEtaobqLABGLu7gtRaecsObFBO5alP2nMwbieyDGuiqAbw4pVRqtQPsujhOWfyfynNKLgyDggFmNKLEWjxcS4Klh1qOaRRqtQPsqcna5dnhynNKLgy5EiiLEwgavl2auGLu7gtRaecsqcScivuKC494uoUDYHk0COb4cnhyj1UX0kaHaB1hy5KeynNKLgyrBG0UXuGfTH9OalmZdZ8WnVVFE6k9Y(EAfjKE)aYWNcSutD08qppeNhM5HBEF)80v6L990kMk3b8e7gtNR0ZuXd5Si0PJMh65H48WmpCZ77NNUsVSVNwrE5HXKiP2EaE3(Nh65H48WmpCZ77NNUsVSVNwrUNEJRADmes29ZL5HEEONFZ8Wfyxe3bYEjlnW67O5xLYSmp3RVVaY8bw0g4Ogcfy59Kln8HUsVSVNwbj0qJHMdSKA3yAfGqGT6dSCscSMtYsdSOnqA3ykWI2WEuGfM5fqQOijkWf3n(PhuU53oVasffjrbU4UXpUQWR6Iop0bw0g4OgcfyfqQOi5ukfKqdxn0CGLu7gtRaecSvFGLtsG1CswAGfTbs7gtbw0g2JcSWmVasffjrPX4UXp9GYn)25fqQOijkng3n(XvfEvx05HoWI2ah1qOaRasffjh5sfKqdnn0CGLu7gtRaecSvFGLtsG1CswAGfTbs7gtbw0g2JcSWmp8NhM5fqQOijkWf3n(PhuU53oVasffjrbU4UXpUQWR6Iop0Zd98mympmZd)5HzEbKkksIsJXDJF6bLB(TZlGurrsuAmUB8JRk8QUOZd98qppdgZtxPx23tRyl2F)(P6ogNNij2KS0alAdCudHcSldXAPJasffjbj0athAoWsQDJPvacb2QpWYjjWAojlnWI2aPDJPalAd7rbwyMhTbs7gtrbKkksoLsZVDE0giTBmfxgI1shbKkksMh65zWyEyMhTbs7gtrbKkksoYLA(TZJ2aPDJP4YqSw6iGurrY8qppdgZdZ8WnVVFE0giTBmffqQOi5uknp0ZdX5HzE4M33ppAdK2nMI8EYLg(qxPx23tR5HE(nZd38mympmZd38((5rBG0UXuuaPIIKJCPMh65H48WmpCZ77NhTbs7gtrEp5sdFOR0l77P18qp)M5HlWI2ah1qOaRasffjhEpoLGeKa7YqSw6iGurrcp0COb4cnhyj1UX0kaHaRAiuGLxE4t2QPqGaR5KS0alV8WNSvtHabj0qJHMdSKA3yAfGqGvnekWUaKT6saDqtCoHdSMtYsdSlazRUeqh0eNt4GeA4QHMdSKA3yAfGqGvnekW2I93VFQUJX5jsInjlnWAojlnW2I93VFQUJX5jsInjlniHgAAO5alP2nMwbieyvdHcSEQB3sLwNwSTstka)W3nhkmXdSMtYsdSEQB3sLwNwSTstka)W3nhkmXdsObMo0CGLu7gtRaecSQHqbw6UuE5HpOthfynNKLgyP7s5Lh(GoDuqcsGDryZpTocivuKWdnhAaUqZbwsTBmTcqiWAojlnWsi9(bKHpfyPM6OaRdKcbslWcZ8UcnPMkrnB3LtNrZVDExv4vDrJ8YdFaLebeILkFEynFJqY8qppdgZdZ8UcnPMkr0Kk7(bZVDExv4vDrJjspPRuBpotmUaQ(Dkcielv(8WA(gHK5HEEgmMhM5DfAsnvIk5afUaR5zWyExHMutLik)G005zWyExHMutLOwknp0bw1qOalH07hqg(uGLAQJcsOHgdnhyj1UX0kaHaR5KS0al3tVXvTogcj7(5sG1bsHaPfyHzExHMutLOMT7YPZO53oVRk8QUOrE5HpGsIacXsLppSMhYnp0ZZGX8WmVRqtQPsenPYUFW8BN3vfEvx0yI0t6k12JZeJlGQFNIacXsLppSMhYnp0ZZGX8WmVRqtQPsujhOWfynpdgZ7k0KAQer5hKMopdgZ7k0KAQe1sP5HoWQgcfy5E6nUQ1Xqiz3pxcsOHRgAoWsQDJPvacbwZjzPbwE5HXKiP2EaE3(dSoqkeiTalmZ7k0KAQe1SDxoDgn)25DvHx1fnYlp8buseqiwQ85H18q(5HEEgmMhM5DfAsnvIOjv29dMF78UQWR6IgtKEsxP2ECMyCbu97ueqiwQ85H18q(5HEEgmMhM5DfAsnvIk5afUaR5zWyExHMutLik)G005zWyExHMutLOwknp0bw1qOalV8WysKuBpaVB)bj0qtdnhyj1UX0kaHaR5KS0alF3w1fADkW9P6osbqivcSoqkeiTalmZ7k0KAQe1SDxoDgn)25DvHx1fnYlp8buseqiwQ85H18nDEONNbJ5HzExHMutLiAsLD)G53oVRk8QUOXePN0vQThNjgxav)ofbeILkFEynFtNh65zWyEyM3vOj1ujQKdu4cSMNbJ5DfAsnvIO8dstNNbJ5DfAsnvIAP08qhyvdHcS8DBvxO1Pa3NQ7ifaHujibjW6k0KAQeAo0aCHMdSKA3yAfGqG1bsHaPfyH)8IHjvI97MkfYHNARh2aP4psQDJP18BNhM5DvHx1fnY9qqk9SmaQwSbOiGqSu5ZdR5HdsMNbJ5DvHx1fnY9qqk9SmaQwSbOiGqSu5ZdV5zAiz(TZ7QcVQlAK7HGu6zzauTydqraHyPYNhEZ3itp)25DLU8sj6kaWRxsT9Gjcej1UX0AEOdSMtYsdSjspPRuBpotmUaQ(DkiHgAm0CGLu7gtRaecSoqkeiTaRyysLy)UPsHC4P26Hnqk(JKA3yAn)25xLe73nvkKdp1wpSbsXFushQuBdSMtYsdSjspPRuBpotmUaQ(DkiHgUAO5alP2nMwbieyDGuiqAbwxv4vDrJCpeKspldGQfBakcielv(8WBEME(TZdZ8l62RRlUBEQebeILkFE4nFtNNbJ5H)8IHjvI7MNkrsTBmTMh6aR5KS0a7ICjIjP2EUlSeKqdnn0CGLu7gtRaecSoqkeiTal8NxmmPsSF3uPqo8uB9Wgif)rsTBmTMF78WmVRk8QUOrUhcsPNLbq1InafbeILkFEynptppdgZ7QcVQlAK7HGu6zzauTydqraHyPYNhEZZ0qY8mymVRk8QUOrUhcsPNLbq1InafbeILkFE4nFJm98BN3v6YlLORaaVEj12dMiqKu7gtR5HoWAojlnWYlp8busqcnW0HMdSKA3yAfGqG1bsHaPfyfdtQe73nvkKdp1wpSbsXFKu7gtR53o)QKy)UPsHC4P26Hnqk(Js6qLABG1CswAGLxE4dOKGeAaYfAoWAojlnWYDLhi12JKYofyj1UX0kaHGeKa7QKtpG6dnhAaUqZbwsTBmTcqiW6aPqG0cSRsIwBP(JacXsLppSMhYp)25DvHx1fnY9qqk9SmaQwSbOiGqSu5ZdV5xLeT2s9hbeILkpWAojlnWATL6piHgAm0CGLu7gtRaecSoqkeiTa7QKip73l9GZokcielv(8WAEi)8BN3vfEvx0i3dbP0ZYaOAXgGIacXsLpp8MFvsKN97LEWzhfbeILkpWAojlnWYZ(9sp4SJcsOHRgAoWsQDJPvacbwhifcKwGDvs0t5IDJPJ11HtNKLgbeILkFEynpKF(TZ7QcVQlAK7HGu6zzauTydqraHyPYNhEZVkj6PCXUX0X66WPtYsJacXsLhynNKLgy9uUy3y6yDD40jzPbj0qtdnhyj1UX0kaHaRdKcbslWUkj6kaWRxYsJacXsLppSMhYp)25DvHx1fnY9qqk9SmaQwSbOiGqSu5ZdV5xLeDfa41lzPraHyPYdSMtYsdSUca86LS0GeKa7I6mpSeAo0aCHMdSMtYsdS8EcJp4YHkWsQDJPvacbj0qJHMdSMtYsdSlcD5boiwB6cSKA3yAfGqqcnC1qZbwsTBmTcqiW6aPqG0cSMts00Hucjj(8WB(Rgy5ciDsOb4cSMtYsdSodJpMtYsp4KlbwCYLJAiuG1kkiHgAAO5alP2nMwbieyxe3bYEjlnW6lCsw684Kl857kW8civuKm)nTBOZceNNvmHpVbO55gAAnFxbM)M6kanpB5HN3xxY1(gKEsxP2opKzIXfq1VtxZu3nvkK5ztT1dBGu87Z8LStGljNMV05DvHx1fnWAojlnW6mm(yojl9GtUeyXjxoQHqbwbKkkso8ECkh3o5qfKqdmDO5alP2nMwbieynNKLgyDggFmNKLEWjxcS4Klh1qOa7IWMFADeqQOiHhKqdqUqZbwsTBmTcqiW6aPqG0cSWm)QKiV8WhqjrjDOsTDEgmMFvsmr6jDLA7XzIXfq1VtNvjrjDOsTDEgmMFvsSF3uPqo8uB9Wgif)rjDOsTDEONF788YdF47gynp8M)QZZGX8RsIOtmDelvjkPdvQTZZGX8IHjvI86Yr2PdNOfpsQDJPvGLlG0jHgGlWAojlnW6mm(yojl9GtUeyXjxoQHqbwUyYraPIIeEqcn4Bdnhyj1UX0kaHaRdKcbslW6k0KAQe1SDxoDgn)25HzE4ppAdK2nMIcivuKC494uMNbJ5DvHx1fnYlp8buseqiwQ85H38ncjZZGX8WmpAdK2nMIcivuKCkLMF78UQWR6Ig5Lh(akjcielv(8WAEbKkksIcCrxv4vDrJacXsLpp0ZZGX8WmpAdK2nMIcivuKCKl18BN3vfEvx0iV8WhqjraHyPYNhwZlGurrsuAm6QcVQlAeqiwQ85HEEONNbJ5DfAsnvIOjv29dMF78Wmp8NhTbs7gtrbKkkso8ECkZZGX8UQWR6IgtKEsxP2ECMyCbu97ueqiwQ85H38ncjZZGX8WmpAdK2nMIcivuKCkLMF78UQWR6IgtKEsxP2ECMyCbu97ueqiwQ85H18civuKef4IUQWR6IgbeILkFEONNbJ5HzE0giTBmffqQOi5ixQ53oVRk8QUOXePN0vQThNjgxav)ofbeILkFEynVasffjrPXORk8QUOraHyPYNh65HEEgmMhM5DfAsnvIk5afUaR5zWyExHMutLik)G005zWyExHMutLOwknp0ZVDEyMh(ZJ2aPDJPOasffjhEpoL5zWyExv4vDrJ97MkfYHNARh2aP4pcielv(8WB(gHK5zWyEyMhTbs7gtrbKkksoLsZVDExv4vDrJ97MkfYHNARh2aP4pcielv(8WAEbKkksIcCrxv4vDrJacXsLpp0ZZGX8WmpAdK2nMIcivuKCKl18BN3vfEvx0y)UPsHC4P26Hnqk(JacXsLppSMxaPIIKO0y0vfEvx0iGqSu5Zd98qppdgZd)5fdtQe73nvkKdp1wpSbsXFKu7gtR53opmZd)5rBG0UXuuaPIIKdVhNY8mymVRk8QUOrUhcsPNLbq1InafbeILkFE4nFJqY8mympmZJ2aPDJPOasffjNsP53oVRk8QUOrUhcsPNLbq1InafbeILkFEynVasffjrbUORk8QUOraHyPYNh65zWyEyMhTbs7gtrbKkksoYLA(TZ7QcVQlAK7HGu6zzauTydqraHyPYNhwZlGurrsuAm6QcVQlAeqiwQ85HEEOdSMtYsdSodJpMtYsp4KlbwCYLJAiuGDziwlDeqQOiHhKqdq(qZbwsTBmTcqiWAojlnWIyyQlDhG1lEakWUiUdK9swAGfcEaDEE5HNNVBGfF(SB(USDxMp5ZByKIlZxOjqG1bsHaPfyVloF(TZ3LT7YbqiwQ85H18eStopHosIqZ77NNxE4dF3aR53o)QKONYf7gthRRdNojlnkPdvQTbj0GVAO5alP2nMwbieyxe3bYEjlnW6B6M3vOj1uz(vjxZu3nvkK5ztT1dBGu8pFYNh4PAQT(mVhNMhsBauTydqZl18eSlKUMx2P5DEaaPY8CscSMtYsdSodJpMtYsp4KlbwhifcKwGfM5DfAsnvIOjv29dMF78RsIjspPRuBpotmUaQ(D6SkjkPdvQTZVDExv4vDrJCpeKspldGQfBakcielv(8WA(gNF78Wm)QKy)UPsHC4P26Hnqk(JacXsLpp8MVX5zWyE4pVyysLy)UPsHC4P26Hnqk(JKA3yAnp0Zd98mympmZ7k0KAQe1SDxoDgn)25xLe5Lh(akjkPdvQTZVDExv4vDrJCpeKspldGQfBakcielv(8WA(gNF78Wm)QKy)UPsHC4P26Hnqk(JacXsLpp8MVX5zWyE4pVyysLy)UPsHC4P26Hnqk(JKA3yAnp0Zd98mympmZdZ8UcnPMkrLCGcxG18mymVRqtQPseLFqA68mymVRqtQPsulLMh653o)QKy)UPsHC4P26Hnqk(Js6qLA78BNFvsSF3uPqo8uB9Wgif)raHyPYNhwZ348qhyXjxoQHqb2Lbq1InaD6buFqcnahKeAoWsQDJPvacb2fXDGSxYsdS(AQdq895xLWNNma2)8z38TvQTZNQuZBZZ3nWAEEpPRuBNVF34uG1CswAG1zy8XCsw6bNCjW6aPqG0cSWmVRqtQPsuZ2D50z08BNh(ZVkjYlp8busushQuBNF78UQWR6Ig5Lh(akjcielv(8WA(Mop0ZZGX8WmVRqtQPsenPYUFW8BNh(ZVkjMi9KUsT94mX4cO63PZQKOKouP2o)25DvHx1fnMi9KUsT94mX4cO63PiGqSu5ZdR5B68qppdgZdZ8WmVRqtQPsujhOWfynpdgZ7k0KAQer5hKMopdgZ7k0KAQe1sP5HE(TZlgMuj2VBQuihEQTEydKI)iP2nMwZVDE4p)QKy)UPsHC4P26Hnqk(Js6qLA78BN3vfEvx0y)UPsHC4P26Hnqk(JacXsLppSMVPZdDGfNC5OgcfyxLC6buFqcnahCHMdSKA3yAfGqG1CswAGDzauhE5HdSlI7azVKLgy9nDZZu3nvkK5ztT1dBGu8pFYNxshQuB9z(uMp5ZZToAEPM3JtZdPnaQ5zlpCG1bsHaPfyxLe73nvkKdp1wpSbsXFushQuBdsOb4Am0CGLu7gtRaecSoqkeiTal8NxmmPsSF3uPqo8uB9Wgif)rsTBmTMF78Wm)QKiV8WhqjrjDOsTDEgmMFvsmr6jDLA7XzIXfq1VtNvjrjDOsTDEOdSMtYsdSldG6WlpCqcna3vdnhyj1UX0kaHaR5KS0aB)UPsHC4P26Hnqk(dSlI7azVKLgyz9RU5zQ7MkfY8SP26Hnqk(N)sk7ZZuKuz3p46gY2DzEFLgnVRqtQPY8Rs8z(s2jWLKtZ7XP5lDExv4vDrJZ7B6MNPeP3pGm88qQGLAQJM)2RRB(KpFQUcj1wFMFVWR59ujXZNcZ85bKT8ppmWb5NNtUsx85ToHaZ7XjOdSoqkeiTaRRqtQPsuZ2D50z08BNxseAE4nptp)25DvHx1fnYlp8buseqiwQ85H18Wn)25HzExv4vDrJesVFaz4tbwQPokcielv(8WAE4GCnopdgZd)5PR0l77PvKq69didFkWsn1rZdDqcnaxtdnhyj1UX0kaHaRdKcbslW6k0KAQertQS7hm)25LeHMhEZZ0ZVDExv4vDrJjspPRuBpotmUaQ(Dkcielv(8WAE4MF78WmVRk8QUOrcP3pGm8Pal1uhfbeILkFEynpCqUgNNbJ5H)80v6L990ksi9(bKHpfyPM6O5HoWAojlnW2VBQuihEQTEydKI)GeAaoMo0CGLu7gtRaecSMtYsdS97MkfYHNARh2aP4pWUiUdK9swAGTbYbkCbwZFjL959LgM6s38(oGj7Z7mUWNVF3uPqMNNARh2aP4F(uNhNkn)Lu2NhstUeXKuBNhcfwcSoqkeiTaRRqtQPsujhOWfyn)25bEk1vGwkIyyQlDNlat2JKA3yAn)25LeHMhEZZ0ZVDExv4vDrJlYLiMKA75UWseqiwQ85H18xD(TZdZ8UQWR6IgjKE)aYWNcSutDueqiwQ85H18Wb5ACEgmMh(ZtxPx23tRiH07hqg(uGLAQJMh6GeAaoixO5alP2nMwbieynNKLgy73nvkKdp1wpSbsXFGDrChi7LS0alKQStG5DfAsnv4ZdtQoS3k1251sVcFPVB(gihOGEENXL5zQSZx68UQWR6IgyDGuiqAbwyM3vOj1ujIYpinDEgmM3vOj1ujQLsZZGX8WmVRqtQPsujhOWfyn)25H)8apL6kqlfrmm1LUZfGj7rsTBmTMh65HE(TZdZ8UQWR6IgjKE)aYWNcSutDueqiwQ85H18Wb5ACEgmMh(ZtxPx23tRiH07hqg(uGLAQJMh6GeAaoFBO5alP2nMwbieyDGuiqAb27IZNF78Dz7UCaeILkFEynpCqUaR5KS0aB)UPsHC4P26Hnqk(dsOb4G8HMdSKA3yAfGqGDrChi7LS0aRVPBEM6UPsHmpBQTEydKI)5t(8s6qLARpZNcZ85LeHMxQ59408LStG5rmFffy(vj8aR5KS0aRZW4J5KS0do5sG1bsHaPfyxLe73nvkKdp1wpSbsXFushQuBNF78WmVRqtQPsuZ2D50z08mymVRqtQPsenPYUFW8qhyXjxoQHqbwxHMutLGeAaoF1qZbwsTBmTcqiWAojlnWATL6pW6aPqG0cSRsIwBP(JacXsLppSMVPbwNFhMoIbAjHhAaUGeAOrij0CG1CswAGD38ujWsQDJPvacbj0qJWfAoWsQDJPvacbwZjzPbworRt1DCfa41lzPb2fXDGSxYsdSS1L5LDAEwIw85lD(RoVyGws4ZNDZNY8jxzwM35baKky)ZN68D4SDxMVaZx68YonVyGwsIZ77szFE2SFV05HTSJMpfM5ZByEn)njcbMxQ59408SeTMVqtG5rm1ZWy)ZB99y)P2o)vNhYkaWRxYs5XaRdKcbslWAojrthsjKK4ZdV5BC(TZlgMujYRlhzNoCIw8iP2nMwZVDE4p)QKiNO1P6oUca86LS0OKouP2o)25H)8PE6Wz7UeKqdn2yO5alP2nMwbieyDGuiqAbwZjjA6qkHKeFE4nFJZVDEXWKkrE2Vx6bNDuKu7gtR53op8NFvsKt06uDhxbaE9swAushQuBNF78WF(upD4SDxMF78RsIUca86LS0iGqSu5ZdR5BAG1CswAGLt06uDhxbaE9swAqcn04vdnhyj1UX0kaHaRdKcbslWcZ88YdF47gynp8MhU5zWyEZjjA6qkHKeFE4nFJZd98BN3vfEvx0i3dbP0ZYaOAXgGIacXsLpp8MhUgdSMtYsdSOtmDelvjiHgASPHMdSKA3yAfGqG1bsHaPfynNKOPZQKONYf7gthRRdNojlD(nZdjZZGX8s6qLA78BNFvs0t5IDJPJ11HtNKLgbeILkFEynFtdSMtYsdSEkxSBmDSUoC6KS0GeAOrMo0CGLu7gtRaecSMtYsdS8SFV0do7OaRdKcbslWUkjYZ(9sp4SJIacXsLppSMVPbwNFhMoIbAjHhAaUGeAOrixO5alP2nMwbieyDGuiqAbw4pVRqtQPsujhOWfyfy5ciDsOb4cSMtYsdSodJpMtYsp4KlbwCYLJAiuG1vOj1ujiHgA03gAoWsQDJPvacbwZjzPbwxbaE9swAG153HPJyGws4HgGlW6aPqG0cSMts00Hucjj(8WA(Mo)vmpmZlgMujYRlhzNoCIw8iP2nMwZZGX8IHjvI8SFV0do7OiP2nMwZd98BNFvs0vaGxVKLgbeILkFEynFJb2fXDGSxYsdS(I(ES)5HSca86LS05rm1ZWy)Zx68WDfnoVyGws4(mFbMV05V68xszFEFXnVWEcnpKvaGxVKLgKqdnc5dnhyj1UX0kaHaR5KS0alIHPU0DawV4bOa7I4oq2lzPbwFrNqG5LDA(QNuc4Z88EsxZBZZ3nWA(l7KoVjZZ0Zx68(sdtDPBEFT1lEaAEPM3qx5A(cnbCwFFQTbwhifcKwGLxE4dF3aR5H38nD(TZljcnp8MVr4csOHg9vdnhyj1UX0kaHa7I4oq2lzPbwF3oPZRLmp3V6sTDEM6UPsHmpBQTEydKI)5LAEMIKk7(bx3q2UlZ7R0iFMN1dbP05H0gavl2a08z38ggp)Qe(8gGM367XjTcSMtYsdSodJpMtYsp4KlbwhifcKwGfM5DfAsnvIOjv29dMF78WFEXWKkX(DtLc5WtT1dBGu8hj1UX0A(TZVkjMi9KUsT94mX4cO63PZQKOKouP2o)25DvHx1fnY9qqk9SmaQwSbOiGSL)5HEEgmMhM5DfAsnvIA2UlNoJMF78WFEXWKkX(DtLc5WtT1dBGu8hj1UX0A(TZVkjYlp8busushQuBNF78UQWR6Ig5EiiLEwgavl2aueq2Y)8qppdgZdZ8WmVRqtQPsujhOWfynpdgZ7k0KAQer5hKMopdgZ7k0KAQe1sP5HE(TZ7QcVQlAK7HGu6zzauTydqrazl)ZdDGfNC5Ogcfyxgavl2a0Phq9bj0WvHKqZbwsTBmTcqiWAojlnWUmaQdV8Wb2fXDGSxYsdSqk508qAdGAE2YdpF2npK2aOAXgGM)sPmlZFtZdiB5FER1s1N5lW8z38YobO5VKy88308MmpMmUmFJZJuaAEiTbq1InanVhN4bwhifcKwG9U4853oVRk8QUOrUhcsPNLbq1InafbeILkFE4nFx2UlhaHyPYNF78Wmp8NxmmPsSF3uPqo8uB9Wgif)rsTBmTMNbJ5DvHx1fn2VBQuihEQTEydKI)iGqSu5ZdV57Y2D5aielv(8qhKqdxfUqZbwsTBmTcqiW6aPqG0cS3fNp)25H)8IHjvI97MkfYHNARh2aP4psQDJP18BN3vfEvx0i3dbP0ZYaOAXgGIacXsLppeN3vfEvx0i3dbP0ZYaOAXgGIlpGjzPZdR57Y2D5aielvEG1CswAGDzauhE5HdsOHR2yO5alP2nMwbieyxe3bYEjlnWczM42VcdJNpfczEpU1sZ3vG5n1VSNA78AjZZ7jx2L0AEcZPl7eGcSMtYsdSodJpMtYsp4KlbwCYLJAiuGnfcjiHgU6vdnhyj1UX0kaHaRdKcbslWkgMujY3TvD5qi3aZrrsTBmTMF78Wm)IU966I8DBvxoeYnWCuKlMd18WAEyMVX5VI5nNKLg572QUCUlSet90HZ2DzEONNbJ5x0TxxxKVBR6YHqUbMJIacXsLppSM)QZdDG1CswAG1zy8XCsw6bNCjWItUCudHcSCkiHgUAtdnhyj1UX0kaHaR5KS0alIHPU0DawV4bOa7I4oq2lzPbwiLCAEFPHPU0nVV26fpan)LDsNhX8vuG5xLWN3a08E9(mFbMp7Mx2jan)LeJN)MMNNTA2LotL5LeHM3tLepVStZReSlZZu3nvkK5ztT1dBGu8hN330nVNK4esHuBN3xAyQlDZ77aMS7Z87fEnVnpF3aR5LAEa1bi((8Yon)TxxxG1bsHaPfyHz(vjr0jMoILQeL0Hk125zWy(vjXePN0vQThNjgxav)oDwLeL0Hk125zWy(vjrE5HpGsIs6qLA78qp)25HzE4ppWtPUc0sredtDP7CbyYEKu7gtR5zWy(BVUUiIHPU0DUamzpYfZHAEyn)vNNbJ55Lh(W3nWAE4npCZdDqcnCvMo0CGLu7gtRaecSMtYsdSigM6s3by9IhGcSlI7azVKLgyHuYP59LgM6s38(ARx8a08snpILQyPoVStZJyyQlDZFbyY(83EDDZ7PsINNVBGfFELO18sn)nnFlPeWeAnFxbMx2P5vc2L5V9aCz(lPUQlZdtJqY8CYv6IpFYNhPa08YUPZZ966sxsQmVuZ3skbmHM)QZZ3nWIdDG1bsHaPfybEk1vGwkIyyQlDNlat2JKA3yAn)25DvHx1fnYlp8buseqiwQ85H38ncjZVD(BVUUiIHPU0DUamzpcielv(8WA(MgKqdxfYfAoWsQDJPvacbwZjzPbwedtDP7aSEXdqb2fXDGSxYsdS(slvXsDEFPHPU0nVVdyY(8MmVHXZljcXNVRaZl708nqoqHlWA(cmptH8dstN3vOj1ujW6aPqG0cSapL6kqlfrmm1LUZfGj7rsTBmTMF78WmVRqtQPsujhOWfynpdgZ7k0KAQer5hKMop0ZVD(BVUUiIHPU0DUamzpcielv(8WA(MgKqdx13gAoWsQDJPvacbwZjzPbwedtDP7aSEXdqb2fXDGSxYsdSqk508(sdtDPBEFT1lEaA(sNNPUBQuiZZMARh2aP4FENXfUpZJyOsTDEUhGMxQ55gAAEBE(UbwZl18CXCOM3xAyQlDZ77aMSpF2nVhp125tjW6aPqG0cSIHjvI97MkfYHNARh2aP4psQDJP18BNhM5xLe73nvkKdp1wpSbsXFushQuBNNbJ5DvHx1fn2VBQuihEQTEydKI)iGqSu5ZdV5BKPNNbJ5VloF(TZljcDK6SsAEynVRk8QUOX(DtLc5WtT1dBGu8hbeILkFEONF78Wmp8Nh4PuxbAPiIHPU0DUamzpsQDJP18mym)TxxxeXWux6oxaMSh5I5qnpSM)QZZGX88YdF47gynp8MhU5HoiHgUkKp0CGLu7gtRaecSoqkeiTaRyysLiVUCKD6WjAXJKA3yAfynNKLgyrmm1LUdW6fpafKqdx1xn0CGLu7gtRaecSMtYsdSlGL6bNDuGDrChi7LS0alKgyPopSLD08jF(sX(N3MhsZuzNV1sD(lPSpVVrj0Py3yAEinHKCAELmW8igSppxmhkECEFt38Dz7UmFYN3UlpzEPMN018RAETK5rsoFEEpPRuBNx2P55I5qXdSoqkeiTa7TxxxmvcDk2nMolcj5uKlMd18WB(McjZZGX83EDDXuj0Py3y6SiKKtrV(53o)DX5ZVD(USDxoacXsLppSMVPbj0qtHKqZbwsTBmTcqiWAojlnW6mm(yojl9GtUeyXjxoQHqbwxHMutLGeAOPWfAoWsQDJPvacbwZjzPbwRTu)bwhifcKwGfqDaIVB3ykW687W0rmqlj8qdWfKqdnTXqZbwsTBmTcqiW6aPqG0cSMts00zvs0t5IDJPJ11HtNKLo)M5HK5zWyEjDOsTD(TZdOoaX3TBmfynNKLgy9uUy3y6yDD40jzPbj0qtVAO5alP2nMwbieynNKLgy5z)EPhC2rbwhifcKwGfqDaIVB3ykW687W0rmqlj8qdWfKqdnTPHMdSKA3yAfGqG1CswAG1vaGxVKLgyDGuiqAbwa1bi(UDJP53oV5KenDiLqsIppSMVPZFfZdZ8IHjvI86Yr2PdNOfpsQDJP18mymVyysLip73l9GZoksQDJP18qhyD(Dy6igOLeEOb4csOHMY0HMdSKA3yAfGqG1CswAGTdt8DhW6KaRdKcbslWYlp8DQRi6cBsIPdVWOjvIKA3yAfytviaWRxozxG92RRlIUWMKy6WlmAsLOxFqcn0uixO5aBQcbaE9sGfUaR5KS0a7cyPE4LhoWsQDJPvacbj0qt9THMdSMtYsdS8DBvxo3fwcSKA3yAfGqqcsGThqUc52KqZHgGl0CGLu7gtRaecSoqkeiTaRKi08WBEiz(TZd)57jjA4enn)25H)83EDDXwqIujGov3HBoq2Lok61hynNKLgy7i8zviPAswAqcn0yO5aR5KS0al3dbP0thH39uHabwsTBmTcqiiHgUAO5alP2nMwbieyvdHcSsHqNQ7GukxaLh)4kLlapNKLYdSMtYsdSsHqNQ7GukxaLh)4kLlapNKLYdsOHMgAoWsQDJPvacbw1qOalVWKTZpCYbi5iKBxZR0JcSMtYsdS8ct2o)WjhGKJqUDnVspkiHgy6qZbwsTBmTcqiW6aPqG0cSIHjvITGePsaDQUd3CGSlDuKu7gtRaR5KS0aBlirQeqNQ7Wnhi7shfKqdqUqZbwZjzPb2omX3DaRtcSKA3yAfGqqcn4Bdnhyj1UX0kaHaB1hy5KeynNKLgyrBG0UXuGfTH9OaR5KenDwLeDfa41lzPZdV5HK53oV5KenDwLeT2s9pp8MhsMF78Mts00zvs0t5IDJPJ11HtNKLop8MhsMF78Wmp8NxmmPsKN97LEWzhfj1UX0AEgmM3CsIMoRsI8SFV0do7O5H38qY8qp)25Hz(vjX(DtLc5WtT1dBGu8hL0Hk125zWyE4pVyysLy)UPsHC4P26Hnqk(JKA3yAnp0bw0g4OgcfyxLWpaYw(dsObiFO5alP2nMwbieyvdHcSgKc8Ddy8txPYP6o91fceynNKLgynif47gW4NUsLt1D6RleiiHg8vdnhyj1UX0kaHaR5KS0alNO1P6oUca86LS0aRdKcbslWY7jm(igOLeEKt06uDhxbaE9sw6XkAE4Tz(RgyXPsh3kWchKeKqdWbjHMdSMtYsdS7MNkbwsTBmTcqiiHgGdUqZbwZjzPbwpLl2nMowxhoDswAGLu7gtRaecsqcSwrHMdnaxO5aR5KS0aB)UPsHC4P26Hnqk(dSKA3yAfGqqcn0yO5aR5KS0a7U5PsGLu7gtRaecsOHRgAoWsQDJPvacbwhifcKwG1vOj1ujIMuz3py(TZVkjMi9KUsT94mX4cO63PZQKOKouP2o)25DvHx1fnY9qqk9SmaQwSbOiGSL)53opmZVkj2VBQuihEQTEydKI)iGqSu5ZdV5BCEgmMh(ZlgMuj2VBQuihEQTEydKI)iP2nMwZd98mymVRqtQPsuZ2D50z08BNFvsKxE4dOKOKouP2o)25DvHx1fnY9qqk9SmaQwSbOiGSL)53opmZVkj2VBQuihEQTEydKI)iGqSu5ZdV5BCEgmMh(ZlgMuj2VBQuihEQTEydKI)iP2nMwZd98mympmZ7k0KAQevYbkCbwZZGX8UcnPMkru(bPPZZGX8UcnPMkrTuAEONF78RsI97MkfYHNARh2aP4pkPdvQTZVD(vjX(DtLc5WtT1dBGu8hbeILkFEynFJbwZjzPbwNHXhZjzPhCYLalo5YrnekWUmaQwSbOtpG6dsOHMgAoWsQDJPvacbwhifcKwGvmmPsKxxoYoD4eT4rsTBmTMF78otpCIwbwZjzPbworRt1DCfa41lzPbj0athAoWsQDJPvacbwhifcKwGf(ZlgMujYRlhzNoCIw8iP2nMwZVDE4p)QKiNO1P6oUca86LS0OKouP2o)25H)8PE6Wz7Um)25xLeDfa41lzPra1bi(UDJPaR5KS0alNO1P6oUca86LS0GeAaYfAoWsQDJPvacbwZjzPbwRTu)bwhifcKwG1CsIMoRsIwBP(NhwZ3053op8NFvs0Al1FushQuBdSo)omDed0scp0aCbj0GVn0CGLu7gtRaecSMtYsdSwBP(dSoqkeiTaR5KenDwLeT2s9pp82mFtNF78aQdq8D7gtZVD(vjrRTu)rjDOsTnW687W0rmqlj8qdWfKqdq(qZbwsTBmTcqiW6aPqG0cSMts00zvs0t5IDJPJ11HtNKLo)M5HK5zWyEjDOsTD(TZdOoaX3TBmfynNKLgy9uUy3y6yDD40jzPbj0GVAO5alP2nMwbieynNKLgy9uUy3y6yDD40jzPbwhifcKwGf(ZlPdvQTZVD(E09IHjvIadP3u5yDD40jzP8iP2nMwZVDEZjjA6Skj6PCXUX0X66WPtYsNhwZF1aRZVdthXaTKWdnaxqcnahKeAoWsQDJPvacbwhifcKwGLxE4dF3aR5H38WfynNKLgyrNy6iwQsqcnahCHMdSKA3yAfGqG1bsHaPfyH)8UcnPMkrLCGcxGvGLlG0jHgGlWAojlnW6mm(yojl9GtUeyXjxoQHqbwxHMutLGeAaUgdnhyj1UX0kaHaRdKcbslWcZ8UcnPMkr0Kk7(bZVDEyM3vfEvx0yI0t6k12JZeJlGQFNIaYw(NNbJ5xLetKEsxP2ECMyCbu970zvsushQuBNh653oVRk8QUOrUhcsPNLbq1InafbKT8p)25Hz(vjX(DtLc5WtT1dBGu8hbeILkFE4nFJZZGX8WFEXWKkX(DtLc5WtT1dBGu8hj1UX0AEONh653opmZdZ8UcnPMkrLCGcxG18mymVRqtQPseLFqA68mymVRqtQPsulLMh653oVRk8QUOrUhcsPNLbq1InafbeILkFEynFJZVDEyMFvsSF3uPqo8uB9Wgif)raHyPYNhEZ348mymp8NxmmPsSF3uPqo8uB9Wgif)rsTBmTMh65HEEgmMhM5DfAsnvIA2UlNoJMF78WmVRk8QUOrE5HpGsIaYw(NNbJ5xLe5Lh(akjkPdvQTZd98BN3vfEvx0i3dbP0ZYaOAXgGIacXsLppSMVX53opmZVkj2VBQuihEQTEydKI)iGqSu5ZdV5BCEgmMh(ZlgMuj2VBQuihEQTEydKI)iP2nMwZd98qhynNKLgyDggFmNKLEWjxcS4Klh1qOa7YaOAXgGo9aQpiHgG7QHMdSKA3yAfGqG1bsHaPfyVloF(TZ7QcVQlAK7HGu6zzauTydqraHyPYNhEZ3LT7YbqiwQ853opmZd)5fdtQe73nvkKdp1wpSbsXFKu7gtR5zWyExv4vDrJ97MkfYHNARh2aP4pcielv(8WB(USDxoacXsLpp0bwZjzPb2LbqD4LhoiHgGRPHMdSKA3yAfGqG1bsHaPfyVloF(TZ7QcVQlAK7HGu6zzauTydqraHyPYNhIZ7QcVQlAK7HGu6zzauTydqXLhWKS05H18Dz7UCaeILkpWAojlnWUmaQdV8Wbj0aCmDO5alP2nMwbieynNKLgyDggFmNKLEWjxcS4Klh1qOaBkesqcnahKl0CGLu7gtRaecSMtYsdSodJpMtYsp4KlbwCYLJAiuGDryZpTocivuKWdsOb48THMdSKA3yAfGqG1CswAG1zy8XCsw6bNCjWItUCudHcSldXAPJasffj8GeAaoiFO5alP2nMwbieyDGuiqAb2vjX(DtLc5WtT1dBGu8hL0Hk125zWyE4pVyysLy)UPsHC4P26Hnqk(JKA3yAfynNKLgyDggFmNKLEWjxcS4Klh1qOalxm5iGurrcpiHgGZxn0CGLu7gtRaecSoqkeiTa7QKi6ethXsvIs6qLABG1CswAGfXWux6oaRx8auqcn0iKeAoWsQDJPvacbwhifcKwGDvsKxE4dOKOKouP2o)25H)8IHjvI86Yr2PdNOfpsQDJPvG1CswAGfXWux6oaRx8auqcn0iCHMdSKA3yAfGqG1bsHaPfyH)8IHjvIOtmDelvjsQDJPvG1CswAGfXWux6oaRx8auqcn0yJHMdSKA3yAfGqG1bsHaPfy5Lh(W3nWAE4nFtdSMtYsdSigM6s3by9IhGcsOHgVAO5alP2nMwbieynNKLgy5z)EPhC2rbwhifcKwG1CsIMoRsI8SFV0do7O5H1M5V68BNhqDaIVB3yA(TZd)5xLe5z)EPhC2rrjDOsTnW687W0rmqlj8qdWfKqdn20qZbwsTBmTcqiW6aPqG0cSUcnPMkrLCGcxGvGLlG0jHgGlWAojlnW6mm(yojl9GtUeyXjxoQHqbwxHMutLGeAOrMo0CGLu7gtRaecSoqkeiTa7TxxxmvcDk2nMolcj5uKlMd18WBZ8mnKmpdgZFxC(8BN)2RRlMkHof7gtNfHKCk61p)257Y2D5aielv(8WAEMEEgmM)2RRlMkHof7gtNfHKCkYfZHAE4Tz(RY0ZVD(vjrE5HpGsIs6qLABG1CswAGDbSup4SJcsOHgHCHMdSKA3yAfGqG1CswAGTdt8DhW6KaRdKcbslWYlp8DQRi6cBsIPdVWOjvIKA3yAfytviaWRxozxG92RRlIUWMKy6WlmAsLOxFqcn0OVn0CGnvHaaVEjWcxG1CswAGDbSup8Ydhyj1UX0kaHGeAOriFO5aR5KS0alF3w1LZDHLalP2nMwbieKGey5IjhbKkks4HMdnaxO5alP2nMwbieyvdHcSPYDapXUX05k9mv8qolcD6OaR5KS0aBQChWtSBmDUsptfpKZIqNokiHgAm0CGLu7gtRaecSQHqb2u5cWZjfGFwj6uPZnHXbwZjzPb2u5cWZjfGFwj6uPZnHXbj0Wvdnhyj1UX0kaHaRAiuGTqtGoCDj12JPjIDCwlfynNKLgyl0eOdxxsT9yAIyhN1sbj0qtdnhyj1UX0kaHaRAiuGDzauivPNf5qD69eaXDK6OaR5KS0a7YaOqQsplYH607jaI7i1rbj0athAoWsQDJPvacbw1qOalI5SBaD47ejhepE6cSMtYsdSiMZUb0HVtKCq84PliHgGCHMdSKA3yAfGqGvnekW2Hne6uDNBtemfynNKLgy7WgcDQUZTjcMcsObFBO5alP2nMwbieyvdHcSxmuKsa(Pdu6kWAojlnWEXqrkb4NoqPRGeAaYhAoWsQDJPvacbw1qOaRy3ysov3zr8ElbbwZjzPbwXUXKCQUZI49wccsObF1qZbwsTBmTcqiWQgcfy5P25HpgVpbMk8ZTTAPt1D6iq5sXFG1CswAGLNANh(y8(eyQWp32QLov3PJaLlf)bj0aCqsO5alP2nMwbieyvdHcS8u78WNwSTstka)CBRw6uDNocuUu8hynNKLgy5P25HpTyBLMua(52wT0P6oDeOCP4piHgGdUqZbwZjzPb2BCvRtNhWFGLu7gtRaecsOb4Am0CG1CswAGTlb0nUQvGLu7gtRaecsOb4UAO5aR5KS0a7nb4eavQTbwsTBmTcqiibjWYPqZHgGl0CG1CswAGD38ujWsQDJPvacbj0qJHMdSKA3yAfGqGnvHaaVE5KDb2fD711f572QUCiKBG5Oixmhk4T5QbwZjzPb2fWs9WlpCGnvHaaVE50IRBdhyHliHgUAO5aR5KS0alF3w1LZDHLalP2nMwbieKGeytHqcnhAaUqZbwZjzPbwpoDsHq4bwsTBmTcqiibjibjiHaa]] )


end