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
                if not settings.manage_ds_ticks then return end
                if level > 51 then applyDebuff( "target", "shadow_embrace", nil, debuff.shadow_embrace.stack + 1 ) end
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

        potion = "unbridled_fury",

        package = "Affliction",
    } )


    spec:RegisterPack( "Affliction", 20201209, [[dyKhwbqiLkEefjTjb5tkvcnkvKtPu1RKszwuOULsLAxs8lbLHrH0XeGLbkEMGktJIuxJcHTPuj9nbvX4OquNtqvzDuiIMNuQUhfSpkIdsrIwOa6HcQsnrks4IcQsCsbvv1kvrntbvjDtLkr2jOYpfuvLHsHiTuLkbpvLMkOQVsHiyVq9xjnyehMyXkPhJ0KLQlJAZkXNfQrRuoTOxlqZgYTbz3u9BfdxkoUsLOwoWZP00jDDHSDkQVdknEkeHoVuY6fuvz(QW(v14aWWJVDrzmCWyuymAaWy0WxXOgzJct42v8vB1W4BJqdkXm(6ceJVMYLfus1CC8TrAHgPJHhFTteGY47MQnwJKHfwCQBrRf6afMnHIqIMJtbYIgMnHOHHVRrjsd)74v8TlkJHdgJcJrdagJg(kgn8yegzy2v812WumCWSRgb(UL9o74v8TZwk(AQpXuUSGsQMJ)eJeeaAOb)ZM6tmfmLHwzWtmYg)eymkmg9p)Nn1NeEVjEmBns(Nn1NS7Nyk7DU)KBdJqpj86qdw(ZM6t29tmL9o3FIPGnprGNSljXjT8Nn1NS7Nyk7DU)KvalbPBI7m6jOjoPpzzapXuaK0FYDIqL)SP(KD)e4HLLGpzxsq8ssFYUG0Ora(jOjoPprNNa7ac(KC5jTMODra)eO0Atp(jYtubXU(K0FIUj6tadSL)SP(KD)KWlUSI4NSliqnIRpXuUSGsQMJBFIrQzJ0NOcIDT8Nn1NS7NapSSe0(eDEIyEY(twrdSPh)etHacgJea)K0FcuesZDRciM1NaByZtmfH)G3(KOMYF2uFYUFs494D2T8tSde)etHacgJea)eJua38eQGq2NOZtaCpIYpHoqnrQO54prtiU8Nn1NS7NCz9j2bIFcvqOQq1C8kkT6tyxbjBFIopXQGKQprNNiMNS)e6gtdME8tqPvTpr3e9jWo(UO(Kv(jawOBCVGVnGzjrm(AQpXuUSGsQMJ)eJeeaAOb)ZM6tmfmLHwzWtmYg)eymkmg9p)Nn1NeEVjEmBns(Nn1NS7Nyk7DU)KBdJqpj86qdw(ZM6t29tmL9o3FIPGnprGNSljXjT8Nn1NS7Nyk7DU)KvalbPBI7m6jOjoPpzzapXuaK0FYDIqL)SP(KD)e4HLLGpzxsq8ssFYUG0Ora(jOjoPprNNa7ac(KC5jTMODra)eO0Atp(jYtubXU(K0FIUj6tadSL)SP(KD)KWlUSI4NSliqnIRpXuUSGsQMJBFIrQzJ0NOcIDT8Nn1NS7NapSSe0(eDEIyEY(twrdSPh)etHacgJea)K0FcuesZDRciM1NaByZtmfH)G3(KOMYF2uFYUFs494D2T8tSde)etHacgJea)eJua38eQGq2NOZtaCpIYpHoqnrQO54prtiU8Nn1NS7NCz9j2bIFcvqOQq1C8kkT6tyxbjBFIopXQGKQprNNiMNS)e6gtdME8tqPvTpr3e9jWo(UO(Kv(jawOBCV8N)ZcvZXTLgathOvrnSWOAFGsx0CCJZfdAcXMy0q70WArqPzo0oRrllLyqcnjGRZs1kuqUKuUe18NfQMJBlnaMoqRI2MHWSrqqJxBy9plunh3wAamDGwfTndHfdsOjbCDwQwHcYLKYgNlgubXUwIbj0KaUolvRqb5ss5c7YkI7)zHQ542sdGPd0QOTzimZciLveBSlqSH(O2kGLElJnlOi2Gq10mx7JwOdae1O54My0qcvtZCTpArIhVLjgnKq10mx7JwICRkRiUkllOKQ54My0qN2rfe7AXMnBJxr5cxyxwrC)4qOAAMR9rl2SzB8kkxytm6(qN6JwA2exhOQn94iKasTvrtAW0Jpo2rfe7APztCDGQ20JJqci1wf2Lve33)NfQMJBlnaMoqRI2MHWISCnvgYyxGyds4NDtaITUmUwNLAZald(ZcvZXTLgathOvrBZqywM71zPshaiQrZXnoxmyByeQQciMvBXYCVolv6aarnAoEvg2edHl0o8UCu20W9sa7A4lCby6)Sq1CCBPbW0bAv02me2Me56FwOAoUT0ay6aTkABgcZUj9b266GuJZfd7OcIDTSjrUwyxwrCpKTHrOQkGywTflZ96SuPdae1O54vz42dxOD4D5OSPH7La21Wx4cW0)5)SP(KWlgjY0iL7pHnZGwprti(j6g)eHQd4jP9jIzjrYkIl)zHQ54wd2ggHQOHg8plunh32MHW6S5jcuHK4K(NfQMJBBZqyubHQcvZXRO0Qg7ceBqg2yRcsQAiaJZfdcvtZCLDgkzRjH7plunh32MHWA2exhOQn94iKasTLX5IbnHytcNr)ZcvZXTTzimQGqvHQ54vuAvJDbIn0fqWyKa4AdGBmoxmCIoMzxCTyMDDRfiuF0sc1WEp94kvuXQGPzJR9rlAsdMECi6mO(aRxSrqqJx7ciymsaCbWqs622Hj0P(OLMnX1bQAtpocjGuBvamKKU1eyoo2rfe7APztCDGQ20JJqci1wf2Lve33V)44eDmZU4AXZ4nTUiCO(Of7eHQGrlAsdMECi6mO(aRxSrqqJx7ciymsaCbWqs622Hj0P(OLMnX1bQAtpocjGuBvamKKU1eyoo2rfe7APztCDGQ20JJqci1wf2Lve33V)440j6yMDX1IZuWGgq)4GoMzxCTeSfif)4GoMzxCT4JZ7d1hT0SjUoqvB6XribKARIM0GPhhQpAPztCDGQ20JJqci1wfadjPBBhM9)zHQ5422meMepElJZfd9rls84Tkagss32UP)ZcvZXTTzimjE8wgtBrrCvfqmRwdbyCUy4Kq10mxzNHs2Asa7dDQpArIhVvbWqs622n9()Sq1CCBBgcBtIC9plunh32MHWOccvfQMJxrPvn2fi2qxabJrcGRnaUX4CXWjHQPzUYodLS1eycrhZSlUwmZUU1ce6eDguFG1ljud790JRurfRcMMnUayP364OpAjHAyVNECLkQyvW0SX1(OfnPbtpEFOt9rlnBIRdu1MECesaP2QOjny6Xhh7OcIDT0SjUoqvB6XribKARc7YkI773FCCsOAAMRSZqjBnbMqNOJz2fxlotbdAa9Jd6yMDX1sWwGu8Jd6yMDX1IpoVp0P(OLMnX1bQAtpocjGuBv0Kgm94JJDubXUwA2exhOQn94iKasTvHDzfX997poojunnZv2zOKTMati6yMDX1INXBADr4qNOZG6dSEXorOky0cGLERJJ(Of7eHQGrlAsdME8(qN6JwA2exhOQn94iKasTvrtAW0Jpo2rfe7APztCDGQ20JJqci1wf2Lve33V)plunh32MHWSm3RZsLoaquJMJBCUyqOAAMRSZqjBnbMqQGyxl2b2QUXvlZDBHDzfX9q70hTyzUxNLkDaGOgnhVOjny6XH2j96ckJ30)Sq1CCBBgcZYCVolv6aarnAoUX5IbHQPzUYodLS1eycPcIDTyZMTXROCHlSlRiUhAN(OflZ96SuPdae1O54fnPbtpo0oPxxqz8MgQpAHoaquJMJxamKKUTDt)NfQMJBBZqyMtexvjD14CXWj7eHQ2nb0njGJdHQPzUYodLS1ey2hIodQpW6fBee041UacgJeaxamKKU1KaG5plunh32MHWICRkRiUkllOKQ54gNlgeQMM5AF0sKBvzfXvzzbLunh3Grpo0Kgm94q9rlrUvLvexLLfus1C8cGHK0TTB6)Sq1CCBBgcZMnBJxr5cBCUyOpAXMnBJxr5cxamKKUTDt)NfQMJBBZqy2SzB8kkxyJPTOiUQciMvRHamoxmCsOAAMRSZqjBnjG9Ho1hTyZMTXROCHlagss32UP3)NfQMJBBZqyubHQcvZXRO0Qg7ceBGoMzxC14CXWo0Xm7IRfNPGbnG(FwOAoUTndHrhaiQrZXnoxmiunnZv2zOKTTB6DFsfe7AXoWw1nUAzUBlSlRiUFCOcIDTyZMTXROCHlSlRiUVpuF0cDaGOgnhVayijDB7W8NfQMJBBZqy0baIA0CCJPTOiUQciMvRHamoxmCsOAAMRSZqjBB307(Kki21IDGTQBC1YC3wyxwrC)4qfe7AXMnBJxr5cxyxwrCF)(qN6JwOdae1O54fadjPBBhM9)zHQ5422mewZM46avTPhhHeqQTmoxmqhZSlUwCMcg0a6hh0Xm7IRfpJ306IWhh0Xm7IRLGTaP4hh0Xm7IRfFC(plunh32MHWGeeVK0kqA0iaBCUyWorOQDtaDtm9FwOAoUTndHrfeQkunhVIsRASlqSHUacgJeaxBaCJX5IHt0Xm7IRfZSRBTaHorNb1hy9sc1WEp94kvuXQGPzJlaw6Too6JwsOg27PhxPIkwfmnBCTpArtAW0J3hIodQpW6fBee041UacgJeaxamKKUTDycDQpAPztCDGQ20JJqci1wfadjPBnbMJJDubXUwA2exhOQn94iKasTvHDzfX997pooDIoMzxCT4mfmOb0poOJz2fxlbBbsXpoOJz2fxl(48(q0zq9bwVyJGGgV2fqWyKa4cGHK0TTdtOt9rlnBIRdu1MECesaP2QayijDRjWCCSJki21sZM46avTPhhHeqQTkSlRiUVF)XXj6yMDX1INXBADr4qNOZG6dSEXorOky0cGLERJJ(Of7eHQGrlAsdME8(q0zq9bwVyJGGgV2fqWyKa4cGHK0TTdtOt9rlnBIRdu1MECesaP2QayijDRjWCCSJki21sZM46avTPhhHeqQTkSlRiUVF)FwOAoUTndH1fqWQDIqgNlgOZG6dSEXgbbnETlGGXibWfadjPBnrtiUQtTN8FwOAoUTndHrfeQkunhVIsRASlqSHuzO)Sq1CCBBgcJkiuvOAoEfLw1yxGydw2yRcsQAiaJZfdDEnAzPy3K(aBLHwbcLlwvObB)em7wOAoEXUj9b266G0s61fugVP7po68A0YsXUj9b2kdTcekxamKKUT9W9NfQMJBBZqyqcIxsAfinAeGnoxm0hTKqnS3tpUsfvSkyA24AF0IM0GPh)NfQMJBBZqyqcIxsAfinAeGnoxm0hTyNiufmArtAW0J)ZcvZXTTzimibXljTcKgncWgNlgubXUwA2exhOQn94iKasTvHDzfX9qN6JwA2exhOQn94iKasTvrtAW0JpoSteQA3eq3KWDCOjex1P2tUD6mO(aRxA2exhOQn94iKasTvbWqs629)zHQ5422megKG4LKwbsJgbyJZfdQGyxl2b2QUXvlZDBHDzfX9)Sq1CCBBgcRdK0ROCHnoxmSgTSusNnNQSI4ANHslxSQqdAIPn6XXA0YsjD2CQYkIRDgkTCjQjKMqCvNAp52n9FwOAoUTndHrfeQkunhVIsRASlqSb6yMDX1)Sq1CCBBgctIhVLX5IbaVay7MSI4)Sq1CCBBgctIhVLX0wuexvbeZQ1qagNlgojunnZv2zOKTMeW(qNa8cGTBYkI3)NfQMJBBZqy0baIA0CCJZfdaEbW2nzfXHeQMM5k7muY22n9UpPcIDTyhyR6gxTm3Tf2Lve3poubXUwSzZ24vuUWf2Lve33)NfQMJBBZqyrUvLvexLLfus1CCJZfdaEbW2nzfX)zHQ5422meMnB2gVIYf24CXaGxaSDtwr8FwOAoUTndHzZMTXROCHnM2II4QkGywTgcW4CXWjHQPzUYodLS1Ka2h6eGxaSDtwr8()Sq1CCBBgcJoaquJMJBmTffXvvaXSAneGX5IHtcvtZCLDgkzB7ME3NubXUwSdSvDJRwM72c7YkI7hhQGyxl2SzB8kkx4c7YkI773h6eGxaSDtwr8()Sq1CCBBgcRdK0R2jczC6kdarnQHa(ZcvZXTTzim7M0hyRRds)Z)zHQ542ImSHMnX1bQAtpocjGuB9NfQMJBlYWTziSnjY1)Sq1CCBrgUndHrfeQkunhVIsRASlqSHUacgJeaxBaCJX5IHt0Xm7IRfZSRBTaH6JwsOg27PhxPIkwfmnBCTpArtAW0JdrNb1hy9InccA8AxabJrcGlagss32omHo1hT0SjUoqvB6XribKARcGHK0TMaZXXoQGyxlnBIRdu1MECesaP2QWUSI4((9hhNOJz2fxlEgVP1fHd1hTyNiufmArtAW0JdrNb1hy9InccA8AxabJrcGlagss32omHo1hT0SjUoqvB6XribKARcGHK0TMaZXXoQGyxlnBIRdu1MECesaP2QWUSI4((9hhNorhZSlUwCMcg0a6hh0Xm7IRLGTaP4hh0Xm7IRfFCEFO(OLMnX1bQAtpocjGuBv0Kgm94q9rlnBIRdu1MECesaP2QayijDB7WS)plunh3wKHBZqywM71zPshaiQrZXnoxmOcIDTyhyR6gxTm3Tf2Lve3drfVAzU)NfQMJBlYWTzimlZ96SuPdae1O54gNlg2rfe7AXoWw1nUAzUBlSlRiUhAN(OflZ96SuPdae1O54fnPbtpo0oPxxqz8MgQpAHoaquJMJxa8cGTBYkI)ZcvZXTfz42meMepElJPTOiUQciMvRHamoxmiunnZ1(OfjE8wTB6qaEbW2nzfX)zHQ542ImCBgctIhVLX0wuexvbeZQ1qagNlgeQMM5AF0IepEltmy6qaEbW2nzfXH6JwK4XBv0Kgm94)Sq1CCBrgUndHf5wvwrCvwwqjvZXnoxmiunnZ1(OLi3QYkIRYYckPAoUbJECOjny6XHa8cGTBYkI)ZcvZXTfz42mewKBvzfXvzzbLunh3yAlkIRQaIz1AiaJZfd7Ojny6XHAm3OcIDTaeOgX1QSSGsQMJBlSlRiUhsOAAMR9rlrUvLvexLLfus1C82d3FwOAoUTid3MHWmNiUQs6QX5Ib7eHQ2nb0njG)Sq1CCBrgUndHrfeQkunhVIsRASlqSb6yMDXvJTkiPQHamoxmSdDmZU4AXzkyqdO)NfQMJBlYWTzimQGqvHQ54vuAvJDbIn0fqWyKa4AdGBmoxmCIoMzxCTyMDDRfi0j6mO(aRxsOg27PhxPIkwfmnBCbWsV1XrF0sc1WEp94kvuXQGPzJR9rlAsdME8(q0zq9bwVyJGGgV2fqWyKa4cGHK0TTdtOt9rlnBIRdu1MECesaP2QayijDRjWCCSJki21sZM46avTPhhHeqQTkSlRiUVF)XXPt0Xm7IRfNPGbnG(XbDmZU4Ajylqk(XbDmZU4AXhN3hIodQpW6fBee041UacgJeaxamKKUTDycDQpAPztCDGQ20JJqci1wfadjPBnbMJJDubXUwA2exhOQn94iKasTvHDzfX997poorhZSlUw8mEtRlch6eDguFG1l2jcvbJwaS0BDC0hTyNiufmArtAW0J3hIodQpW6fBee041UacgJeaxamKKUTDycDQpAPztCDGQ20JJqci1wfadjPBnbMJJDubXUwA2exhOQn94iKasTvHDzfX997)ZcvZXTfz42mewxabR2jczCUyGodQpW6fBee041UacgJeaxamKKU1enH4Qo1EY)zHQ542ImCBgcJkiuvOAoEfLw1yxGydPYq)zHQ542ImCBgcdsq8ssRaPrJaSX5IH(OfZjIRQKUw0Kgm94)Sq1CCBrgUndHbjiEjPvG0Ora24CXqF0IDIqvWOfnPbtpo0oQGyxl2b2QUXvlZDBHDzfX9)Sq1CCBrgUndHbjiEjPvG0Ora24CXWoQGyxlMtexvjDTWUSI4(FwOAoUTid3MHWGeeVK0kqA0iaBCUyWorOQDtaDtm9FwOAoUTid3MHWSzZ24vuUWgtBrrCvfqmRwdbyCUyqOAAMR9rl2SzB8kkx42neUqaEbW2nzfXH2PpAXMnBJxr5cx0Kgm94)Sq1CCBrgUndHrfeQkunhVIsRASlqSb6yMDX1)Sq1CCBrgUndH1bs6vuUWgNlgwJwwkPZMtvwrCTZqPLlwvObnXGry0JJ1OLLs6S5uLvex7muA5sutinH4Qo1EYTBehhRrllL0zZPkRiU2zO0YfRk0GMyiCgrO(Of7eHQGrlAsdME8FwOAoUTid3MHW6aj9QDIqgNUYaquJAiG)Sq1CCBrgUndHz3K(aBDDq6F(plunh3wOJz2fxnKqnS3tpUsfvSkyA2yJZfd0zq9bwVyJGGgV2fqWyKa4cGHK0TThGrpoOZG6dSEXgbbnETlGGXibWfadjPBnXim6FwOAoUTqhZSlU2MHW6mnHen9466GuJZfd0zq9bwVyJGGgV2fqWyKa4cGHK0TMyeHo151OLLYMe5AbWqs6wtm9XXoQGyxlBsKRf2Lve33)NfQMJBl0Xm7IRTzim7eHQGrnoxmqNb1hy9InccA8AxabJrcGlagss32UrCCqNb1hy9InccA8AxabJrcGlagss3AIry0Jd6mO(aRxSrqqJx7ciymsaCbWqs6wtGXicrhVhLAHoaquJMECfXmOWUSI4(FwOAoUTqhZSlU2MHWS0jcKECvtDJ)Z)zHQ542sxabJrcGRnaUXG5eXvvsxnoxmqNb1hy9InccA8AxabJrcGlagss32om)zHQ542sxabJrcGRnaUPndH1fqWQDIq)zHQ542sxabJrcGRnaUPndH1mAo(FwOAoUT0fqWyKa4AdGBAZqyljGxrZ0)ZcvZXTLUacgJeaxBaCtBgcBfntVUebA9NfQMJBlDbemgjaU2a4M2me2kdSmiy6X)zHQ542sxabJrcGRnaUPndHrfeQkunhVIsRASlqSb6yMDXvJTkiPQHamoxmSdDmZU4AXzkyqdOhIodQpW6fBee041UacgJeaxamKKUTDy(ZcvZXTLUacgJeaxBaCtBgcZgbbnETlGGXibW)5)Sq1CCBjvgYqKLRPYq2)8FwOAoUTyzdBsKR)zHQ542ILBZqyDGKE1oriJtxzaiQrRXOzvqgcW40vgaIA0AUyOZRrllf7M0hyRm0kqOCXQcnOjgc3FwOAoUTy52meMDt6dS11bP4RzgyZXXWbJrHXObaJrdp4lScWtp2IVH)HAgGY9NeEEIq1C8NGsRAl)z8vI0TbGV3ek8gFrPvTy4Xx6yMDXvm8y4cadp(YUSI4ooq8LcsLbPGV0zq9bwVyJGGgV2fqWyKa4cGHK0TpP9NeGrFYXXtOZG6dSEXgbbnETlGGXibWfadjPBFIjpXimk(kunhhFtOg27PhxPIkwfmnBmwXWbdgE8LDzfXDCG4lfKkdsbFPZG6dSEXgbbnETlGGXibWfadjPBFIjpXiEsONC6jDEnAzPSjrUwamKKU9jM8et)KJJNSZtubXUw2KixlSlRiU)K94Rq1CC8TZ0es00JRRdsXkgUWHHhFzxwrChhi(sbPYGuWx6mO(aRxSrqqJx7ciymsaCbWqs62N0(tmINCC8e6mO(aRxSrqqJx7ciymsaCbWqs62NyYtmcJ(KJJNqNb1hy9InccA8AxabJrcGlagss3(etEcmgXtc9e649Oul0baIA00JRiMbf2Lve3XxHQ544RDIqvWOyfdNPXWJVcvZXXxlDIaPhx1u3y8LDzfXDCGyfR4BNxKiKIHhdxay4XxHQ544RTHrOkAObXx2Lve3XbIvmCWGHhFfQMJJVD28ebQqsCsXx2Lve3XbIvmCHddp(YUSI4ooq8LcsLbPGVcvtZCLDgkz7tm5jHdFTkiPkgUaWxHQ544lvqOQq1C8kkTk(IsRwDbIXxzySIHZ0y4Xx2Lve3XbIVuqQmif8vti(jM8KWzu8vOAoo(2SjUoqvB6XribKAlSIHZiWWJVSlRiUJdeFfQMJJVubHQcvZXRO0Q4lfKkdsbFp9e6yMDX1Iz21TwGNe6j9rljud790JRurfRcMMnU2hTOjny6Xpj0tOZG6dSEXgbbnETlGGXibWfadjPBFs7pbMNe6jNEsF0sZM46avTPhhHeqQTkagss3(etEcmp544j78evqSRLMnX1bQAtpocjGuBvyxwrC)j7FY(NCC8KtpHoMzxCT4z8Mwxe(jHEsF0IDIqvWOfnPbtp(jHEcDguFG1l2iiOXRDbemgjaUayijD7tA)jW8Kqp50t6JwA2exhOQn94iKasTvbWqs62NyYtG5jhhpzNNOcIDT0SjUoqvB6XribKARc7YkI7pz)t2)KJJNC6jNEcDmZU4AXzkyqdO)KJJNqhZSlUwc2cKI)KJJNqhZSlUw8X5NS)jHEsF0sZM46avTPhhHeqQTkAsdME8tc9K(OLMnX1bQAtpocjGuBvamKKU9jT)eyEYE8fLwT6ceJVDbemgjaU2a4gSIHBxXWJVSlRiUJdeFPGuzqk4BF0IepERcGHK0TpP9NyA8vOAoo(kXJ3cRy4cpy4Xx2Lve3XbIVuqQmif890teQMM5k7muY2NyYtc4j7FsONC6j9rls84Tkagss3(K2FIPFYE8vOAoo(kXJ3cFPTOiUQciMvlgUaWkgoJmgE8vOAoo(UjrUIVSlRiUJdeRy4cFy4Xx2Lve3XbIVcvZXXxQGqvHQ54vuAv8LcsLbPGVNEIq10mxzNHs2(etEcmpj0tOJz2fxlMzx3AbEsONC6j0zq9bwVKqnS3tpUsfvSkyA24cGLERNCC8K(OLeQH9E6XvQOIvbtZgx7Jw0Kgm94NS)jHEYPN0hT0SjUoqvB6XribKARIM0GPh)KJJNSZtubXUwA2exhOQn94iKasTvHDzfX9NS)j7FYXXto9eHQPzUYodLS9jM8eyEsONC6j0Xm7IRfNPGbnG(tooEcDmZU4Ajylqk(tooEcDmZU4AXhNFY(Ne6jNEsF0sZM46avTPhhHeqQTkAsdME8tooEYoprfe7APztCDGQ20JJqci1wf2Lve3FY(NS)jhhp50teQMM5k7muY2NyYtG5jHEcDmZU4AXZ4nTUi8tc9KtpHodQpW6f7eHQGrlaw6TEYXXt6JwSteQcgTOjny6Xpz)tc9KtpPpAPztCDGQ20JJqci1wfnPbtp(jhhpzNNOcIDT0SjUoqvB6XribKARc7YkI7pz)t2JVO0QvxGy8TlGGXibW1ga3GvmCbyum84l7YkI74aXxkivgKc(kunnZv2zOKTpXKNaZtc9evqSRf7aBv34QL5UTWUSI4(tc9KDEsF0IL5EDwQ0baIA0C8IM0GPh)KqpzNNKEDbLXBk(kunhhFTm3RZsLoaquJMJJvmCbeagE8LDzfXDCG4lfKkdsbFfQMM5k7muY2NyYtG5jHEIki21InB2gVIYfUWUSI4(tc9KDEsF0IL5EDwQ0baIA0C8IM0GPh)KqpzNNKEDbLXB6tc9K(Of6aarnAoEbWqs62N0(tmn(kunhhFTm3RZsLoaquJMJJvmCbadgE8LDzfXDCG4lfKkdsbFp9e7eHQ2nb0FIjpjGNCC8eHQPzUYodLS9jM8eyEY(Ne6j0zq9bwVyJGGgV2fqWyKa4cGHK0TpXKNeam4Rq1CC81CI4QkPRyfdxaHddp(YUSI4ooq8LcsLbPGVcvtZCTpAjYTQSI4QSSGsQMJ)edpXOp544jAsdME8tc9K(OLi3QYkIRYYckPAoEbWqs62N0(tmn(kunhhFJCRkRiUkllOKQ54yfdxaMgdp(YUSI4ooq8LcsLbPGV9rl2SzB8kkx4cGHK0TpP9NyA8vOAoo(AZMTXROCHXkgUamcm84l7YkI74aXxkivgKc(E6jcvtZCLDgkz7tm5jb8K9pj0to9K(OfB2SnEfLlCbWqs62N0(tm9t2JVcvZXXxB2SnEfLlm(sBrrCvfqmRwmCbGvmCbSRy4Xx2Lve3XbIVcvZXXxQGqvHQ54vuAv8LcsLbPGV78e6yMDX1IZuWGgqhFrPvRUaX4lDmZU4kwXWfq4bdp(YUSI4ooq8LcsLbPGVcvtZCLDgkz7tA)jM(j7(jNEIki21IDGTQBC1YC3wyxwrC)jhhprfe7AXMnBJxr5cxyxwrC)j7FsON0hTqhaiQrZXlagss3(K2Fcm4Rq1CC8LoaquJMJJvmCbyKXWJVSlRiUJdeFPGuzqk47PNiunnZv2zOKTpP9Ny6NS7NC6jQGyxl2b2QUXvlZDBHDzfX9NCC8evqSRfB2SnEfLlCHDzfX9NS)j7FsONC6j9rl0baIA0C8cGHK0TpP9NaZt2JVcvZXXx6aarnAoo(sBrrCvfqmRwmCbGvmCbe(WWJVSlRiUJdeFPGuzqk4lDmZU4AXzkyqdO)KJJNqhZSlUw8mEtRlc)KJJNqhZSlUwc2cKI)KJJNqhZSlUw8Xz8vOAoo(2SjUoqvB6XribKAlSIHdgJIHhFzxwrChhi(sbPYGuWx7eHQ2nb0FIjpX04Rq1CC8fsq8ssRaPrJamwXWbtay4Xx2Lve3XbIVcvZXXxQGqvHQ54vuAv8LcsLbPGVNEcDmZU4AXm76wlWtc9KtpHodQpW6LeQH9E6XvQOIvbtZgxaS0B9KJJN0hTKqnS3tpUsfvSkyA24AF0IM0GPh)K9pj0tOZG6dSEXgbbnETlGGXibWfadjPBFs7pbMNe6jNEsF0sZM46avTPhhHeqQTkagss3(etEcmp544j78evqSRLMnX1bQAtpocjGuBvyxwrC)j7FY(NCC8Ktp50tOJz2fxlotbdAa9NCC8e6yMDX1sWwGu8NCC8e6yMDX1Ipo)K9pj0tOZG6dSEXgbbnETlGGXibWfadjPBFs7pbMNe6jNEsF0sZM46avTPhhHeqQTkagss3(etEcmp544j78evqSRLMnX1bQAtpocjGuBvyxwrC)j7FY(NCC8KtpHoMzxCT4z8Mwxe(jHEYPNqNb1hy9IDIqvWOfal9wp544j9rl2jcvbJw0Kgm94NS)jHEcDguFG1l2iiOXRDbemgjaUayijD7tA)jW8Kqp50t6JwA2exhOQn94iKasTvbWqs62NyYtG5jhhpzNNOcIDT0SjUoqvB6XribKARc7YkI7pz)t2JVO0QvxGy8TlGGXibW1ga3GvmCWadgE8LDzfXDCG4lfKkdsbFPZG6dSEXgbbnETlGGXibWfadjPBFIjprtiUQtTNm(kunhhF7ciy1oriSIHdMWHHhFzxwrChhi(kunhhFPccvfQMJxrPvXxuA1Qlqm(MkdHvmCWyAm84l7YkI74aXxkivgKc(251OLLIDt6dSvgAfiuUyvHg8jT)KtpbMNS7NiunhVy3K(aBDDqAj96ckJ30NS)jhhpPZRrllf7M0hyRm0kqOCbWqs62N0(tch(AvqsvmCbGVcvZXXxQGqvHQ54vuAv8fLwT6ceJVwgRy4GXiWWJVSlRiUJdeFPGuzqk4BF0sc1WEp94kvuXQGPzJR9rlAsdMEm(kunhhFHeeVK0kqA0iaJvmCWSRy4Xx2Lve3XbIVuqQmif8TpAXorOky0IM0GPhJVcvZXXxibXljTcKgncWyfdhmHhm84l7YkI74aXxkivgKc(QcIDT0SjUoqvB6XribKARc7YkI7pj0to9K(OLMnX1bQAtpocjGuBv0Kgm94NCC8e7eHQ2nb0FIjpjCp544jAcXvDQ9KFs7pHodQpW6LMnX1bQAtpocjGuBvamKKU9j7XxHQ544lKG4LKwbsJgbySIHdgJmgE8LDzfXDCG4lfKkdsbFvbXUwSdSvDJRwM72c7YkI74Rq1CC8fsq8ssRaPrJamwXWbt4ddp(YUSI4ooq8LcsLbPGVRrllL0zZPkRiU2zO0YfRk0GpXKNyAJ(KJJNSgTSusNnNQSI4ANHslxIAEsONOjex1P2t(jT)etJVcvZXX3oqsVIYfgRy4cNrXWJVSlRiUJdeFfQMJJVubHQcvZXRO0Q4lkTA1figFPJz2fxXkgUWfagE8LDzfXDCG4lfKkdsbFb8cGTBYkIXxHQ544RepElSIHlCWGHhFzxwrChhi(sbPYGuW3tprOAAMRSZqjBFIjpjGNS)jHEYPNa4faB3Kve)K94Rq1CC8vIhVf(sBrrCvfqmRwmCbGvmCHlCy4Xx2Lve3XbIVuqQmif8fWla2UjRi(jHEIq10mxzNHs2(K2FIPFYUFYPNOcIDTyhyR6gxTm3Tf2Lve3FYXXtubXUwSzZ24vuUWf2Lve3FYE8vOAoo(shaiQrZXXkgUWzAm84l7YkI74aXxkivgKc(c4faB3KveJVcvZXX3i3QYkIRYYckPAoowXWfoJadp(YUSI4ooq8LcsLbPGVaEbW2nzfX4Rq1CC81MnBJxr5cJvmCHBxXWJVSlRiUJdeFPGuzqk47PNiunnZv2zOKTpXKNeWt2)Kqp50ta8cGTBYkIFYE8vOAoo(AZMTXROCHXxAlkIRQaIz1IHlaSIHlCHhm84l7YkI74aXxkivgKc(E6jcvtZCLDgkz7tA)jM(j7(jNEIki21IDGTQBC1YC3wyxwrC)jhhprfe7AXMnBJxr5cxyxwrC)j7FY(Ne6jNEcGxaSDtwr8t2JVcvZXXx6aarnAoo(sBrrCvfqmRwmCbGvmCHZiJHhFtxzaiQrX3aWxHQ544BhiPxTtecFzxwrChhiwXWfUWhgE8vOAoo(A3K(aBDDqk(YUSI4ooqSIv8TbW0bAvum8y4cadp(YUSI4ooq8LcsLbPGVAcXpXKNy0Ne6j78KgwlcknZpj0t25jRrllLyqcnjGRZs1kuqUKuUe1GVcvZXX3fgv7du6IMJJvmCWGHhFfQMJJV2iiOXRlmAlYvgGVSlRiUJdeRy4chgE8LDzfXDCG4lfKkdsbFvbXUwIbj0KaUolvRqb5ss5c7YkI74Rq1CC8ngKqtc46SuTcfKljLXkgotJHhFzxwrChhi(on4RLv8vOAoo(AwaPSIy81SGIy8vOAAMR9rl0baIA0C8NyYtm6tc9eHQPzU2hTiXJ36jM8eJ(KqprOAAMR9rlrUvLvexLLfus1C8NyYtm6tc9KtpzNNOcIDTyZMTXROCHlSlRiU)KJJNiunnZ1(OfB2SnEfLl8tm5jg9j7FsONC6j9rlnBIRdu1MECesaP2QOjny6Xp544j78evqSRLMnX1bQAtpocjGuBvyxwrC)j7XxZcO6ceJV9rTval9wyfdNrGHhFzxwrChhi(6ceJVs4NDtaITUmUwNLAZaldWxHQ544Re(z3eGyRlJR1zP2mWYaSIHBxXWJVSlRiUJdeFPGuzqk4RTHrOQkGywTflZ96SuPdae1O54vz4NyIHNeUNe6j78eExokBA4Erc)SBcqS1LX16SuBgyza(kunhhFTm3RZsLoaquJMJJvmCHhm84Rq1CC8DtICfFzxwrChhiwXWzKXWJVSlRiUJdeFPGuzqk47oprfe7AztICTWUSI4(tc9eBdJqvvaXSAlwM71zPshaiQrZXRYWpP9NeUNe6j78eExokBA4Erc)SBcqS1LX16SuBgyza(kunhhFTBsFGTUoifRyfFLHXWJHlam84Rq1CC8TztCDGQ20JJqci1w4l7YkI74aXkgoyWWJVcvZXX3njYv8LDzfXDCGyfdx4WWJVSlRiUJdeFfQMJJVubHQcvZXRO0Q4lfKkdsbFp9e6yMDX1Iz21TwGNe6j9rljud790JRurfRcMMnU2hTOjny6Xpj0tOZG6dSEXgbbnETlGGXibWfadjPBFs7pbMNe6jNEsF0sZM46avTPhhHeqQTkagss3(etEcmp544j78evqSRLMnX1bQAtpocjGuBvyxwrC)j7FY(NCC8KtpHoMzxCT4z8Mwxe(jHEsF0IDIqvWOfnPbtp(jHEcDguFG1l2iiOXRDbemgjaUayijD7tA)jW8Kqp50t6JwA2exhOQn94iKasTvbWqs62NyYtG5jhhpzNNOcIDT0SjUoqvB6XribKARc7YkI7pz)t2)KJJNC6jNEcDmZU4AXzkyqdO)KJJNqhZSlUwc2cKI)KJJNqhZSlUw8X5NS)jHEsF0sZM46avTPhhHeqQTkAsdME8tc9K(OLMnX1bQAtpocjGuBvamKKU9jT)eyEYE8fLwT6ceJVDbemgjaU2a4gSIHZ0y4Xx2Lve3XbIVuqQmif8vfe7AXoWw1nUAzUBlSlRiU)KqpHkE1YChFfQMJJVwM71zPshaiQrZXXkgoJadp(YUSI4ooq8LcsLbPGV78evqSRf7aBv34QL5UTWUSI4(tc9KDEsF0IL5EDwQ0baIA0C8IM0GPh)KqpzNNKEDbLXB6tc9K(Of6aarnAoEbWla2UjRigFfQMJJVwM71zPshaiQrZXXkgUDfdp(YUSI4ooq8LcsLbPGVcvtZCTpArIhV1tA)jM(jHEcGxaSDtwrm(kunhhFL4XBHV0wuexvbeZQfdxayfdx4bdp(YUSI4ooq8LcsLbPGVcvtZCTpArIhV1tmXWtm9tc9eaVay7MSI4Ne6j9rls84TkAsdMEm(kunhhFL4XBHV0wuexvbeZQfdxayfdNrgdp(YUSI4ooq8LcsLbPGVcvtZCTpAjYTQSI4QSSGsQMJ)edpXOp544jAsdME8tc9eaVay7MSIy8vOAoo(g5wvwrCvwwqjvZXXkgUWhgE8LDzfXDCG4lfKkdsbF35jAsdME8tc9KgZnQGyxlabQrCTkllOKQ542c7YkI7pj0teQMM5AF0sKBvzfXvzzbLunh)jT)KWHVcvZXX3i3QYkIRYYckPAoo(sBrrCvfqmRwmCbGvmCbyum84l7YkI74aXxkivgKc(ANiu1UjG(tm5jbGVcvZXXxZjIRQKUIvmCbeagE8LDzfXDCG4lfKkdsbF35j0Xm7IRfNPGbnGo(AvqsvmCbGVcvZXXxQGqvHQ54vuAv8fLwT6ceJV0Xm7IRyfdxaWGHhFzxwrChhi(kunhhFPccvfQMJxrPvXxkivgKc(E6j0Xm7IRfZSRBTapj0to9e6mO(aRxsOg27PhxPIkwfmnBCbWsV1tooEsF0sc1WEp94kvuXQGPzJR9rlAsdME8t2)KqpHodQpW6fBee041UacgJeaxamKKU9jT)eyEsONC6j9rlnBIRdu1MECesaP2QayijD7tm5jW8KJJNSZtubXUwA2exhOQn94iKasTvHDzfX9NS)j7FYXXto9KtpHoMzxCT4mfmOb0FYXXtOJz2fxlbBbsXFYXXtOJz2fxl(48t2)KqpHodQpW6fBee041UacgJeaxamKKU9jT)eyEsONC6j9rlnBIRdu1MECesaP2QayijD7tm5jW8KJJNSZtubXUwA2exhOQn94iKasTvHDzfX9NS)j7FYXXto9e6yMDX1INXBADr4Ne6jNEcDguFG1l2jcvbJwaS0B9KJJN0hTyNiufmArtAW0JFY(Ne6j0zq9bwVyJGGgV2fqWyKa4cGHK0TpP9NaZtc9KtpPpAPztCDGQ20JJqci1wfadjPBFIjpbMNCC8KDEIki21sZM46avTPhhHeqQTkSlRiU)K9pzp(IsRwDbIX3UacgJeaxBaCdwXWfq4WWJVSlRiUJdeFPGuzqk4lDguFG1l2iiOXRDbemgjaUayijD7tm5jAcXvDQ9KXxHQ544BxabR2jcHvmCbyAm84l7YkI74aXxHQ544lvqOQq1C8kkTk(IsRwDbIX3uziSIHlaJadp(YUSI4ooq8LcsLbPGV9rlMtexvjDTOjny6X4Rq1CC8fsq8ssRaPrJamwXWfWUIHhFzxwrChhi(sbPYGuW3(Of7eHQGrlAsdME8tc9KDEIki21IDGTQBC1YC3wyxwrChFfQMJJVqcIxsAfinAeGXkgUacpy4Xx2Lve3XbIVuqQmif8DNNOcIDTyorCvL01c7YkI74Rq1CC8fsq8ssRaPrJamwXWfGrgdp(YUSI4ooq8LcsLbPGV2jcvTBcO)etEIPXxHQ544lKG4LKwbsJgbySIHlGWhgE8LDzfXDCG4lfKkdsbFfQMM5AF0InB2gVIYf(jTB4jH7jHEcGxaSDtwr8tc9KDEsF0InB2gVIYfUOjny6X4Rq1CC81MnBJxr5cJV0wuexvbeZQfdxayfdhmgfdp(YUSI4ooq8vOAoo(sfeQkunhVIsRIVO0QvxGy8LoMzxCfRy4Gjam84l7YkI74aXxkivgKc(UgTSusNnNQSI4ANHslxSQqd(etm8eJWOp544jRrllL0zZPkRiU2zO0YLOMNe6jAcXvDQ9KFs7pXiEYXXtwJwwkPZMtvwrCTZqPLlwvObFIjgEs4mINe6j9rl2jcvbJw0Kgm9y8vOAoo(2bs6vuUWyfdhmWGHhFtxzaiQrX3aWxHQ544BhiPxTtecFzxwrChhiwXWbt4WWJVcvZXXx7M0hyRRdsXx2Lve3XbIvSIVDbemgjaU2a4gm8y4cadp(YUSI4ooq8LcsLbPGV0zq9bwVyJGGgV2fqWyKa4cGHK0TpP9Nad(kunhhFnNiUQs6kwXWbdgE8vOAoo(2fqWQDIq4l7YkI74aXkgUWHHhFfQMJJVnJMJJVSlRiUJdeRy4mngE8vOAoo(UKaEfnthFzxwrChhiwXWzey4XxHQ5447kAMEDjc0cFzxwrChhiwXWTRy4XxHQ5447kdSmiy6X4l7YkI74aXkgUWdgE8LDzfXDCG4lfKkdsbF35j0Xm7IRfNPGbnG(tc9e6mO(aRxSrqqJx7ciymsaCbWqs62N0(tGbFTkiPkgUaWxHQ544lvqOQq1C8kkTk(IsRwDbIXx6yMDXvSIHZiJHhFfQMJJV2iiOXRDbemgjagFzxwrChhiwXk(MkdHHhdxay4XxHQ544BKLRPYqw8LDzfXDCGyfR4RLXWJHlam84Rq1CC8DtICfFzxwrChhiwXWbdgE8LDzfXDCG4B6kdarnAnxW3oVgTSuSBsFGTYqRaHYfRk0GMyiC4Rq1CC8TdK0R2jcHVPRmae1O1y0Ski8naSIHlCy4XxHQ544RDt6dS11bP4l7YkI74aXkwXkwXkgd]] )


end