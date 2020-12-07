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


    spec:RegisterPack( "Affliction", 20201207, [[dyK5vbqiLkEKaWMeKpPuj0OuQ6uQiVskLzrH6wuiSlj(LaAycqhJIyzGINjOY0Oq6AkvQTjaQVPujnoLkrNtqvzDuiIMNuQUhfSpkshuaKfkO8qbvrtKcrDrbvbNuqvQwPkQzkOk0nfuv1obv(PGQugkfI0sfuv5PQ0ubv9vkeb7fYFL0Gr6Welwj9yetwQUmQnReFwOgTs50IETanBOUni7MQFRy4sXXvQeSCGNtPPt66cz7uuFhuA8uicDEPK1lOkz(QW(v1itqWJUDrzeCWeqycOjWeWDTysaHz37ExrxTvdJUncjOeZORlqm6gGwwWjrZXr3gPfEKocE01oracJUBQ2ynsgyGXPUfTwiduG2ekclAoobilAG2eIei6UgLyn8UJwr3UOmcoycimb0eyc4UwmjGWS7DBu012WeeCWeG3n6UL9o7Ov0TZwc6gapnaTSGtIMJ)uJeeaEib)ZbWtnYmHHwzWt3vJFkmbeMa(N)ZbWtdp3epMTgj)ZbWtnINgG6DU)0BdJXpn84qcw(ZbWtnINgG6DU)uJmBEIapn8xIts5phap1iEAaQ35(txbSeKSjUZ4NIN4K80Lb8uJmqs)P3jcx(ZbWtnINcpSSe8PH)cMxsYtd)KgncWpfpXj5P68uyhqWNMlpT1eTlc4NcLwB6XpvEQky21NM(t1nrFkyGT8NdGNAepn8GlRy(PHFcuJ46tdqll4KO542NAKA2i9PQGzxl)5a4PgXtHhwwcAFQopvmpz)PR4b20JFQrwabJXcGFA6pfkcRPrOciM1NcBGZtnYH3G3(0OMYFoaEQr80WZX7SB5NAhi(Pgzbemgla(PgPaU5PebJTpvNNc4EeHFkzGAIurZXFQMqC5phap1iE6L1NAhi(PebJRcrZXR40QpLDfKS9P68uRcsI(uDEQyEY(tjBmjy6XpfNw1(uDt0Nc747I6tx5NcyHSX9c62aMLeZOBa80a0YcojAo(tnsqa4He8phap1iZegALbpDxn(PWeqyc4F(phapn8Ct8y2AK8phap1iEAaQ35(tVnmg)0WJdjy5phap1iEAaQ35(tnYS5jc80WFjojL)Ca8uJ4PbOEN7pDfWsqYM4oJFkEItYtxgWtnYaj9NENiC5phap1iEk8WYsWNg(lyEjjpn8tA0ia)u8eNKNQZtHDabFAU80wt0UiGFkuATPh)u5PQGzxFA6pv3e9PGb2YFoaEQr80WdUSI5Ng(jqnIRpnaTSGtIMJBFQrQzJ0NQcMDT8NdGNAepfEyzjO9P68uX8K9NUIhytp(Pgzbemgla(PP)uOiSMgHkGywFkSbop1ihEdE7tJAk)5a4PgXtdphVZULFQDG4NAKfqWySa4NAKc4MNsem2(uDEkG7re(PKbQjsfnh)PAcXL)Ca8uJ4PxwFQDG4NsemUkenhVItR(u2vqY2NQZtTkij6t15PI5j7pLSXKGPh)uCAv7t1nrFkSJVlQpDLFkGfYg3l)5)Sq0CCBPbWKbAvudlmU2hO0fnh34CXGMqSPbm0onSweCAMdTZA0YsjgKqtc46SuTcbKljHlrn)zHO542sdGjd0QOTziqBee041gw)ZcrZXTLgatgOvrBZqGXGeAsaxNLQviGCjjSX5IbvWSRLyqcnjGRZs1keqUKeUWUSI5(FwiAoUT0ayYaTkABgc0SaszfZg7ceBOpQTcyP3YyZcoIniennZ1(OfYaarnAoUPbmKq00mx7JwK4XBzAadjennZ1(OLi3QYkMRYYcojAoUPbm0(DubZUwSzZ24vCUWf2Lvm3poeIMM5AF0InB2gVIZf20aEk0((OLMnX1bQAtpoclGuBv0Kem94JJDubZUwA2exhOQn94iSasTvHDzfZ9t)zHO542sdGjd0QOTziWilxtLHm2fi2GeEz3eGyRlJR1zP2mWYG)Sq0CCBPbWKbAv02meOL5EDwQKbaIA0CCJZfd2ggJRQaIz1wSm3RZsLmaquJMJxLHn1q4cTdVleLnnCVysao8fotm6FwiAoUT0ayYaTkABgcCtIC9plenh3wAamzGwfTndbA3K(aBDDWQX5IHDubZUw2KixlSlRyUhY2WyCvfqmR2IL5EDwQKbaIA0C8QmC7Hl0o8Uqu20W9Ijb4Wx4mXO)5)Ca80WdgjYKiL7pLnZGwpvti(P6g)uHOd4PP9PIzjXYkMl)zHO54wd2ggJR4He8plenh32MHa7S5jcuHK4K8NfIMJBBZqGebJRcrZXR40Qg7ceBqg2yRcsIAWeJZfdcrtZCLDgkzRPH7plenh32MHaB2exhOQn94iSasTLX5IbnHytdxa)ZcrZXTTziqIGXvHO54vCAvJDbIn0fqWySa4AdGBmoxmSNmMzxCTyMDDRfiuF0sc1WEp94kruXQGPzJR9rlAscMECiYm4(aRxSrqqJx7ciymwaCbWqs622Hj0((OLMnX1bQAtpoclGuBvamKKU1uyoo2rfm7APztCDGQ20JJWci1wf2Lvm3pD64ypzmZU4AXZ4nTUiCO(Of7eHRGrlAscMECiYm4(aRxSrqqJx7ciymwaCbWqs622Hj0((OLMnX1bQAtpoclGuBvamKKU1uyoo2rfm7APztCDGQ20JJWci1wf2Lvm3pD64y)EYyMDX1IZeWGhq)4GmMzxCTeSfif)4GmMzxCT4JZNc1hT0SjUoqvB6XrybKARIMKGPhhQpAPztCDGQ20JJWci1wfadjPBBhMt)zHO5422meOepElJZfd9rls84Tkagss32Ur)ZcrZXTTziqjE8wgtArWCvfqmRwdMyCUyyVq00mxzNHs2AQjNcTVpArIhVvbWqs622n6P)Sq0CCBBgcCtIC9plenh32MHajcgxfIMJxXPvn2fi2qxabJXcGRnaUX4CXWEHOPzUYodLS1uycrgZSlUwmZUU1ceApzgCFG1ljud790JRerfRcMMnUayP364OpAjHAyVNECLiQyvW0SX1(Ofnjbtp(uO99rlnBIRdu1MECewaP2QOjjy6Xhh7OcMDT0SjUoqvB6XrybKARc7YkM7NoDCSxiAAMRSZqjBnfMq7jJz2fxlotadEa9JdYyMDX1sWwGu8JdYyMDX1IpoFk0((OLMnX1bQAtpoclGuBv0Kem94JJDubZUwA2exhOQn94iSasTvHDzfZ9tNoo2lennZv2zOKTMctiYyMDX1INXBADr4q7jZG7dSEXor4ky0cGLERJJ(Of7eHRGrlAscME8Pq77JwA2exhOQn94iSasTvrtsW0Jpo2rfm7APztCDGQ20JJWci1wf2Lvm3pD6plenh32MHaTm3RZsLmaquJMJBCUyqiAAMRSZqjBnfMqQGzxl2b2QUXvlZDBHDzfZ9q70hTyzUxNLkzaGOgnhVOjjy6XH2j96coJ30)Sq0CCBBgc0YCVolvYaarnAoUX5IbHOPzUYodLS1uycPcMDTyZMTXR4CHlSlRyUhAN(OflZ96Sujdae1O54fnjbtpo0oPxxWz8MgQpAHmaquJMJxamKKUTDJ(NfIMJBBZqGMtmxvjD14CXWE7eHR2nb0n1KJdHOPzUYodLS1uyofImdUpW6fBee041UacgJfaxamKKU1utG5plenh32MHaJCRkRyUkll4KO54gNlgeIMM5AF0sKBvzfZvzzbNenh3qapo0Kem94q9rlrUvLvmxLLfCs0C8cGHK0TTB0)Sq0CCBBgc0MnBJxX5cBCUyOpAXMnBJxX5cxamKKUTDJ(NfIMJBBZqG2SzB8koxyJjTiyUQciMvRbtmoxmSxiAAMRSZqjBn1KtH23hTyZMTXR4CHlagss32Urp9NfIMJBBZqGebJRcrZXR40Qg7ceBGmMzxC14CXWoKXm7IRfNjGbpG(FwiAoUTndbsgaiQrZXnoxmiennZv2zOKTTBuJyVky21IDGTQBC1YC3wyxwXC)4qfm7AXMnBJxX5cxyxwXC)uO(OfYaarnAoEbWqs622H5plenh32MHajdae1O54gtArWCvfqmRwdMyCUyyVq00mxzNHs22UrnI9QGzxl2b2QUXvlZDBHDzfZ9JdvWSRfB2SnEfNlCHDzfZ9tNcTVpAHmaquJMJxamKKUTDyo9NfIMJBBZqGnBIRdu1MECewaP2Y4CXazmZU4AXzcyWdOFCqgZSlUw8mEtRlcFCqgZSlUwc2cKIFCqgZSlUw8X5)Sq0CCBBgcesW8ssQaPrJaSX5Ib7eHR2nb0n1O)zHO5422meirW4Qq0C8koTQXUaXg6ciymwaCTbWngNlg2tgZSlUwmZUU1ceApzgCFG1ljud790JRerfRcMMnUayP364OpAjHAyVNECLiQyvW0SX1(Ofnjbtp(uiYm4(aRxSrqqJx7ciymwaCbWqs622Hj0((OLMnX1bQAtpoclGuBvamKKU1uyoo2rfm7APztCDGQ20JJWci1wf2Lvm3pD64y)EYyMDX1IZeWGhq)4GmMzxCTeSfif)4GmMzxCT4JZNcrMb3hy9InccA8AxabJXcGlagss32omH23hT0SjUoqvB6XrybKARcGHK0TMcZXXoQGzxlnBIRdu1MECewaP2QWUSI5(Pthh7jJz2fxlEgVP1fHdTNmdUpW6f7eHRGrlaw6Too6JwSteUcgTOjjy6XNcrMb3hy9InccA8AxabJXcGlagss32omH23hT0SjUoqvB6XrybKARcGHK0TMcZXXoQGzxlnBIRdu1MECewaP2QWUSI5(Pt)zHO5422meyxabR2jcBCUyGmdUpW6fBee041UacgJfaxamKKU1unH4Qo1EY)zHO5422meirW4Qq0C8koTQXUaXgsLH(ZcrZXTTziqIGXvHO54vCAvJDbInyzJTkijQbtmoxm051OLLIDt6dSvgAfieUyvHeS99WyecrZXl2nPpWwxhSwsVUGZ4n90XrNxJwwk2nPpWwzOvGq4cGHK0TThU)Sq0CCBBgcesW8ssQaPrJaSX5IH(OLeQH9E6XvIOIvbtZgx7Jw0Kem94)Sq0CCBBgcesW8ssQaPrJaSX5IH(Of7eHRGrlAscME8FwiAoUTndbcjyEjjvG0Ora24CXGky21sZM46avTPhhHfqQTkSlRyUhAFF0sZM46avTPhhHfqQTkAscME8XHDIWv7Ma6MgUJdnH4Qo1EYTtMb3hy9sZM46avTPhhHfqQTkagss3E6plenh32MHaHemVKKkqA0iaBCUyqfm7AXoWw1nUAzUBlSlRyU)NfIMJBBZqGDGKEfNlSX5IH1OLLs6S5uLvmx7muA5IvfsqtnAapowJwwkPZMtvwXCTZqPLlrnH0eIR6u7j3Ur)ZcrZXTTziqIGXvHO54vCAvJDbInqgZSlU(NfIMJBBZqGs84Tmoxma4faB3Kvm)NfIMJBBZqGs84TmM0IG5QkGywTgmX4CXWEHOPzUYodLS1utofApGxaSDtwX8P)Sq0CCBBgcKmaquJMJBCUyaWla2UjRyoKq00mxzNHs22UrnI9QGzxl2b2QUXvlZDBHDzfZ9JdvWSRfB2SnEfNlCHDzfZ9t)zHO5422meyKBvzfZvzzbNenh34CXaGxaSDtwX8FwiAoUTndbAZMTXR4CHnoxma4faB3Kvm)NfIMJBBZqG2SzB8koxyJjTiyUQciMvRbtmoxmSxiAAMRSZqjBn1KtH2d4faB3KvmF6plenh32MHajdae1O54gtArWCvfqmRwdMyCUyyVq00mxzNHs22UrnI9QGzxl2b2QUXvlZDBHDzfZ9JdvWSRfB2SnEfNlCHDzfZ9tNcThWla2UjRy(0FwiAoUTndb2bs6v7eHnoDLbGOg1Gj)zHO5422meODt6dS11bR)5)Sq0CCBrg2qZM46avTPhhHfqQT(ZcrZXTfz42me4Me56FwiAoUTid3MHajcgxfIMJxXPvn2fi2qxabJXcGRnaUX4CXWEYyMDX1Iz21TwGq9rljud790JRerfRcMMnU2hTOjjy6XHiZG7dSEXgbbnETlGGXybWfadjPBBhMq77JwA2exhOQn94iSasTvbWqs6wtH54yhvWSRLMnX1bQAtpoclGuBvyxwXC)0PJJ9KXm7IRfpJ306IWH6JwSteUcgTOjjy6XHiZG7dSEXgbbnETlGGXybWfadjPBBhMq77JwA2exhOQn94iSasTvbWqs6wtH54yhvWSRLMnX1bQAtpoclGuBvyxwXC)0PJJ97jJz2fxlotadEa9JdYyMDX1sWwGu8JdYyMDX1IpoFkuF0sZM46avTPhhHfqQTkAscMECO(OLMnX1bQAtpoclGuBvamKKUTDyo9NfIMJBlYWTziqlZ96Sujdae1O54gNlgubZUwSdSvDJRwM72c7YkM7HiIxTm3)ZcrZXTfz42meOL5EDwQKbaIA0CCJZfd7OcMDTyhyR6gxTm3Tf2Lvm3dTtF0IL5EDwQKbaIA0C8IMKGPhhAN0Rl4mEtd1hTqgaiQrZXlaEbW2nzfZ)zHO542ImCBgcuIhVLXKwemxvbeZQ1GjgNlgeIMM5AF0IepER2n6FwiAoUTid3MHaL4XBzmPfbZvvaXSAnyIX5IbHOPzU2hTiXJ3YudgneGxaSDtwXCO(OfjE8wfnjbtp(plenh3wKHBZqGrUvLvmxLLfCs0CCJZfdcrtZCTpAjYTQSI5QSSGtIMJBiGhhAscMECiaVay7MSI5)Sq0CCBrgUndbg5wvwXCvwwWjrZXnM0IG5QkGywTgmX4CXWoAscMECOgZnQGzxlabQrCTkll4KO542c7YkM7HeIMM5AF0sKBvzfZvzzbNenhV9W9NfIMJBlYWTziqZjMRQKUACUyWor4QDtaDtn5plenh3wKHBZqGebJRcrZXR40Qg7ceBGmMzxC1yRcsIAWeJZfd7qgZSlUwCMag8a6)zHO542ImCBgcKiyCviAoEfNw1yxGydDbemglaU2a4gJZfd7jJz2fxlMzx3AbcTNmdUpW6LeQH9E6XvIOIvbtZgxaS0BDC0hTKqnS3tpUsevSkyA24AF0IMKGPhFkezgCFG1l2iiOXRDbemglaUayijDB7WeAFF0sZM46avTPhhHfqQTkagss3Akmhh7OcMDT0SjUoqvB6XrybKARc7YkM7NoDCSFpzmZU4AXzcyWdOFCqgZSlUwc2cKIFCqgZSlUw8X5tHiZG7dSEXgbbnETlGGXybWfadjPBBhMq77JwA2exhOQn94iSasTvbWqs6wtH54yhvWSRLMnX1bQAtpoclGuBvyxwXC)0PJJ9KXm7IRfpJ306IWH2tMb3hy9IDIWvWOfal9whh9rl2jcxbJw0Kem94tHiZG7dSEXgbbnETlGGXybWfadjPBBhMq77JwA2exhOQn94iSasTvbWqs6wtH54yhvWSRLMnX1bQAtpoclGuBvyxwXC)0P)Sq0CCBrgUndb2fqWQDIWgNlgiZG7dSEXgbbnETlGGXybWfadjPBnvtiUQtTN8FwiAoUTid3MHajcgxfIMJxXPvn2fi2qQm0FwiAoUTid3MHaHemVKKkqA0iaBCUyOpAXCI5QkPRfnjbtp(plenh3wKHBZqGqcMxssfinAeGnoxm0hTyNiCfmArtsW0JdTJky21IDGTQBC1YC3wyxwXC)plenh3wKHBZqGqcMxssfinAeGnoxmSJky21I5eZvvsxlSlRyU)NfIMJBlYWTziqibZljPcKgncWgNlgSteUA3eq3uJ(NfIMJBlYWTziqB2SnEfNlSXKwemxvbeZQ1GjgNlgeIMM5AF0InB2gVIZfUDdHl0o9rl2SzB8kox4IMKGPh)NfIMJBlYWTziqIGXvHO54vCAvJDbInqgZSlU(NfIMJBlYWTziWoqsVIZf24CXWA0YsjD2CQYkMRDgkTCXQcjOPg2DapowJwwkPZMtvwXCTZqPLlrnH0eIR6u7j3(UpowJwwkPZMtvwXCTZqPLlwvibn1q42DO(Of7eHRGrlAscME8FwiAoUTid3MHa7aj9QDIWgNUYaquJAWK)Sq0CCBrgUndbA3K(aBDDW6F(plenh3wiJz2fxnKqnS3tpUsevSkyA2yJZfdKzW9bwVyJGGgV2fqWySa4cGHK0TTBsapoiZG7dSEXgbbnETlGGXybWfadjPBnD3b8plenh3wiJz2fxBZqGDMKqIMECDDWQX5IbYm4(aRxSrqqJx7ciymwaCbWqs6wt3DO9DEnAzPSjrUwamKKU1uJECSJky21YMe5AHDzfZ9t)zHO542czmZU4ABgc0or4kyuJZfdKzW9bwVyJGGgV2fqWySa4cGHK0TTV7JdYm4(aRxSrqqJx7ciymwaCbWqs6wt3DapoiZG7dSEXgbbnETlGGXybWfadjPBnfMDhImEpk1czaGOgn94kMzqHDzfZ9)Sq0CCBHmMzxCTndbAjtei94QM6g)N)ZcrZXTLUacgJfaxBaCJbZjMRQKUACUyGmdUpW6fBee041UacgJfaxamKKUTDy(ZcrZXTLUacgJfaxBaCtBgcSlGGv7eH)ZcrZXTLUacgJfaxBaCtBgcSz0C8)Sq0CCBPlGGXybW1ga30MHaxsaVINP)NfIMJBlDbemglaU2a4M2me4kEMEDjc06plenh3w6ciymwaCTbWnTziWvgyzqW0J)ZcrZXTLUacgJfaxBaCtBgcKiyCviAoEfNw1yxGydKXm7IRgBvqsudMyCUyyhYyMDX1IZeWGhqpezgCFG1l2iiOXRDbemglaUayijDB7W8NfIMJBlDbemglaU2a4M2meOnccA8AxabJXcG)Z)zHO542sQmKHilxtLHS)5)Sq0CCBXYg2Kix)ZcrZXTfl3MHa7aj9QDIWgNUYaquJwJXZQGnyIXPRmae1O1CXqNxJwwk2nPpWwzOvGq4IvfsqtneU)Sq0CCBXYTziq7M0hyRRdwrxZmWMJJGdMactanXeycFOlScWtp2IUH3HAgGY9NURpviAo(tXPvTL)m6ItRArWJUKXm7IRi4rWzccE0LDzfZDuyOlbKkdsbDjZG7dSEXgbbnETlGGXybWfadjPBFA7p1Ka(0JJNsMb3hy9InccA8AxabJXcGlagss3(utF6Udi6kenhhDtOg27PhxjIkwfmnBmsrWbdcE0LDzfZDuyOlbKkdsbDjZG7dSEXgbbnETlGGXybWfadjPBFQPpD3pn0t3)0oVgTSu2Kixlagss3(utFQrF6XXt35PQGzxlBsKRf2Lvm3F6j0viAoo62zscjA6X11bRifbx4qWJUSlRyUJcdDjGuzqkOlzgCFG1l2iiOXRDbemglaUayijD7tB)P7(PhhpLmdUpW6fBee041UacgJfaxamKKU9PM(0DhWNEC8uYm4(aRxSrqqJx7ciymwaCbWqs62NA6tHz3pn0tjJ3JsTqgaiQrtpUIzguyxwXChDfIMJJU2jcxbJIueCgfbp6kenhhDTKjcKECvtDJrx2Lvm3rHHuKIUDErIWkcEeCMGGhDfIMJJU2ggJR4HeeDzxwXChfgsrWbdcE0viAoo62zZteOcjXjbDzxwXChfgsrWfoe8Ol7YkM7OWqxcivgKc6kennZv2zOKTp10Ngo01QGKOi4mbDfIMJJUebJRcrZXR40QOloTA1figDLHrkcoJIGhDzxwXChfg6saPYGuqxnH4NA6tdxarxHO54OBZM46avTPhhHfqQTqkcUDJGhDzxwXChfg6saPYGuq39pLmMzxCTyMDDRf4PHEAF0sc1WEp94kruXQGPzJR9rlAscME8td9uYm4(aRxSrqqJx7ciymwaCbWqs62N2(tH5PHE6(N2hT0SjUoqvB6XrybKARcGHK0Tp10NcZtpoE6opvfm7APztCDGQ20JJWci1wf2Lvm3F6PNE6PhhpD)tjJz2fxlEgVP1fHFAON2hTyNiCfmArtsW0JFAONsMb3hy9InccA8AxabJXcGlagss3(02Fkmpn0t3)0(OLMnX1bQAtpoclGuBvamKKU9PM(uyE6XXt35PQGzxlnBIRdu1MECewaP2QWUSI5(tp90tp944P7F6(NsgZSlUwCMag8a6p944PKXm7IRLGTaP4p944PKXm7IRfFC(PNEAON2hT0SjUoqvB6XrybKARIMKGPh)0qpTpAPztCDGQ20JJWci1wfadjPBFA7pfMNEcDfIMJJUebJRcrZXR40QOloTA1figD7ciymwaCTbWnifbxagbp6YUSI5okm0LasLbPGU9rls84Tkagss3(02FQrrxHO54ORepElKIGBxrWJUSlRyUJcdDfIMJJUs84TqxcivgKc6U)PcrtZCLDgkz7tn9PM80tpn0t3)0(OfjE8wfadjPBFA7p1Op9e6sArWCvfqmRweCMGueC7se8ORq0CC0DtICfDzxwXChfgsrWf(qWJUSlRyUJcdDjGuzqkO7(NkennZv2zOKTp10NcZtd9uYyMDX1Iz21TwGNg6P7FkzgCFG1ljud790JRerfRcMMnUayP36PhhpTpAjHAyVNECLiQyvW0SX1(Ofnjbtp(PNEAONU)P9rlnBIRdu1MECewaP2QOjjy6Xp944P78uvWSRLMnX1bQAtpoclGuBvyxwXC)PNE6PNEC809pviAAMRSZqjBFQPpfMNg6P7FkzmZU4AXzcyWdO)0JJNsgZSlUwc2cKI)0JJNsgZSlUw8X5NE6PHE6(N2hT0SjUoqvB6XrybKARIMKGPh)0JJNUZtvbZUwA2exhOQn94iSasTvHDzfZ9NE6PNE6XXt3)uHOPzUYodLS9PM(uyEAONsgZSlUw8mEtRlc)0qpD)tjZG7dSEXor4ky0cGLERNEC80(Of7eHRGrlAscME8tp90qpD)t7JwA2exhOQn94iSasTvrtsW0JF6XXt35PQGzxlnBIRdu1MECewaP2QWUSI5(tp90tORq0CC0LiyCviAoEfNwfDXPvRUaXOBxabJXcGRnaUbPi4mjGi4rx2Lvm3rHHUeqQmif0viAAMRSZqjBFQPpfMNg6PQGzxl2b2QUXvlZDBHDzfZ9Ng6P780(OflZ96Sujdae1O54fnjbtp(PHE6opn96coJ3u0viAoo6AzUxNLkzaGOgnhhPi4mXee8Ol7YkM7OWqxcivgKc6kennZv2zOKTp10NcZtd9uvWSRfB2SnEfNlCHDzfZ9Ng6P780(OflZ96Sujdae1O54fnjbtp(PHE6opn96coJ30Ng6P9rlKbaIA0C8cGHK0TpT9NAu0viAoo6AzUxNLkzaGOgnhhPi4mbge8Ol7YkM7OWqxcivgKc6U)P2jcxTBcO)utFQjp944PcrtZCLDgkz7tn9PW80tpn0tjZG7dSEXgbbnETlGGXybWfadjPBFQPp1eyqxHO54OR5eZvvsxrkcotchcE0LDzfZDuyOlbKkdsbDfIMM5AF0sKBvzfZvzzbNenh)PgEAaF6XXt1Kem94Ng6P9rlrUvLvmxLLfCs0C8cGHK0TpT9NAu0viAoo6g5wvwXCvwwWjrZXrkcotmkcE0LDzfZDuyOlbKkdsbD7JwSzZ24vCUWfadjPBFA7p1OORq0CC01MnBJxX5cJueCMSBe8Ol7YkM7OWqxHO54ORnB2gVIZfgDjGuzqkO7(NkennZv2zOKTp10NAYtp90qpD)t7JwSzZ24vCUWfadjPBFA7p1Op9e6sArWCvfqmRweCMGueCMeGrWJUSlRyUJcdDjGuzqkO7opLmMzxCT4mbm4b0rxHO54OlrW4Qq0C8koTk6ItRwDbIrxYyMDXvKIGZKDfbp6YUSI5okm0LasLbPGUcrtZCLDgkz7tB)Pg9PgXt3)uvWSRf7aBv34QL5UTWUSI5(tpoEQky21InB2gVIZfUWUSI5(tp90qpTpAHmaquJMJxamKKU9PT)uyqxHO54OlzaGOgnhhPi4mzxIGhDzxwXChfg6kenhhDjdae1O54OlbKkdsbD3)uHOPzUYodLS9PT)uJ(uJ4P7FQky21IDGTQBC1YC3wyxwXC)Phhpvfm7AXMnBJxX5cxyxwXC)PNE6PNg6P7FAF0czaGOgnhVayijD7tB)PW80tOlPfbZvvaXSArWzcsrWzs4dbp6YUSI5okm0LasLbPGUKXm7IRfNjGbpG(tpoEkzmZU4AXZ4nTUi8tpoEkzmZU4Ajylqk(tpoEkzmZU4AXhNrxHO54OBZM46avTPhhHfqQTqkcoycicE0LDzfZDuyOlbKkdsbDTteUA3eq)PM(uJIUcrZXrxibZljPcKgncWifbhmMGGhDzxwXChfg6saPYGuq39pLmMzxCTyMDDRf4PHE6(NsMb3hy9sc1WEp94kruXQGPzJlaw6TE6XXt7JwsOg27PhxjIkwfmnBCTpArtsW0JF6PNg6PKzW9bwVyJGGgV2fqWySa4cGHK0TpT9NcZtd909pTpAPztCDGQ20JJWci1wfadjPBFQPpfMNEC80DEQky21sZM46avTPhhHfqQTkSlRyU)0tp90tpoE6(NU)PKXm7IRfNjGbpG(tpoEkzmZU4Ajylqk(tpoEkzmZU4AXhNF6PNg6PKzW9bwVyJGGgV2fqWySa4cGHK0TpT9NcZtd909pTpAPztCDGQ20JJWci1wfadjPBFQPpfMNEC80DEQky21sZM46avTPhhHfqQTkSlRyU)0tp90tpoE6(NsgZSlUw8mEtRlc)0qpD)tjZG7dSEXor4ky0cGLERNEC80(Of7eHRGrlAscME8tp90qpLmdUpW6fBee041UacgJfaxamKKU9PT)uyEAONU)P9rlnBIRdu1MECewaP2QayijD7tn9PW80JJNUZtvbZUwA2exhOQn94iSasTvHDzfZ9NE6PNqxHO54OlrW4Qq0C8koTk6ItRwDbIr3UacgJfaxBaCdsrWbdmi4rx2Lvm3rHHUeqQmif0LmdUpW6fBee041UacgJfaxamKKU9PM(unH4Qo1EYORq0CC0TlGGv7eHrkcoychcE0LDzfZDuyORq0CC0LiyCviAoEfNwfDXPvRUaXOBQmesrWbJrrWJUSlRyUJcdDjGuzqkOBNxJwwk2nPpWwzOvGq4IvfsWN2(t3)uyEQr8uHO54f7M0hyRRdwlPxxWz8M(0tp944PDEnAzPy3K(aBLHwbcHlagss3(02FA4qxRcsIIGZe0viAoo6semUkenhVItRIU40QvxGy01Yifbhm7gbp6YUSI5okm0LasLbPGU9rljud790JRerfRcMMnU2hTOjjy6XORq0CC0fsW8ssQaPrJamsrWbtagbp6YUSI5okm0LasLbPGU9rl2jcxbJw0Kem9y0viAoo6cjyEjjvG0OragPi4GzxrWJUSlRyUJcdDjGuzqkORky21sZM46avTPhhHfqQTkSlRyU)0qpD)t7JwA2exhOQn94iSasTvrtsW0JF6XXtTteUA3eq)PM(0W90JJNQjex1P2t(PT)uYm4(aRxA2exhOQn94iSasTvbWqs62NEcDfIMJJUqcMxssfinAeGrkcoy2Li4rx2Lvm3rHHUeqQmif0vfm7AXoWw1nUAzUBlSlRyUJUcrZXrxibZljPcKgncWifbhmHpe8Ol7YkM7OWqxcivgKc6UgTSusNnNQSI5ANHslxSQqc(utFQrd4tpoE6A0YsjD2CQYkMRDgkTCjQ5PHEQMqCvNAp5N2(tnk6kenhhD7aj9koxyKIGlCbebp6YUSI5okm0viAoo6semUkenhVItRIU40QvxGy0LmMzxCfPi4cNji4rx2Lvm3rHHUeqQmif0fWla2UjRygDfIMJJUs84TqkcUWbdcE0LDzfZDuyORq0CC0vIhVf6saPYGuq39pviAAMRSZqjBFQPp1KNE6PHE6(Nc4faB3Kvm)0tOlPfbZvvaXSArWzcsrWfUWHGhDzxwXChfg6saPYGuqxaVay7MSI5Ng6PcrtZCLDgkz7tB)Pg9PgXt3)uvWSRf7aBv34QL5UTWUSI5(tpoEQky21InB2gVIZfUWUSI5(tpHUcrZXrxYaarnAoosrWfoJIGhDzxwXChfg6saPYGuqxaVay7MSIz0viAoo6g5wvwXCvwwWjrZXrkcUWTBe8Ol7YkM7OWqxcivgKc6c4faB3KvmJUcrZXrxB2SnEfNlmsrWfUamcE0LDzfZDuyORq0CC01MnBJxX5cJUeqQmif0D)tfIMM5k7muY2NA6tn5PNEAONU)PaEbW2nzfZp9e6sArWCvfqmRweCMGueCHBxrWJUSlRyUJcdDfIMJJUKbaIA0CC0LasLbPGU7FQq00mxzNHs2(02FQrFQr809pvfm7AXoWw1nUAzUBlSlRyU)0JJNQcMDTyZMTXR4CHlSlRyU)0tp90td909pfWla2UjRy(PNqxslcMRQaIz1IGZeKIGlC7se8OB6kdarnk6Ac6kenhhD7aj9QDIWOl7YkM7OWqkcUWf(qWJUcrZXrx7M0hyRRdwrx2Lvm3rHHuKIUnaMmqRIIGhbNji4rx2Lvm3rHHUeqQmif0vti(PM(0a(0qpDNN2WArWPz(PHE6opDnAzPedsOjbCDwQwHaYLKWLOg0viAoo6UW4AFGsx0CCKIGdge8ORq0CC01gbbnEDHXBrUYa0LDzfZDuyifbx4qWJUSlRyUJcdDjGuzqkORky21smiHMeW1zPAfcixscxyxwXChDfIMJJUXGeAsaxNLQviGCjjmsrWzue8Ol7YkM7OWq3PbDTSIUcrZXrxZciLvmJUMfCeJUcrtZCTpAHmaquJMJ)utFAaFAONkennZ1(OfjE8wp10NgWNg6PcrtZCTpAjYTQSI5QSSGtIMJ)utFAaFAONU)P78uvWSRfB2SnEfNlCHDzfZ9NEC8uHOPzU2hTyZMTXR4CHFQPpnGp90td909pTpAPztCDGQ20JJWci1wfnjbtp(PhhpDNNQcMDT0SjUoqvB6XrybKARc7YkM7p9e6AwavxGy0TpQTcyP3cPi42ncE0LDzfZDuyORlqm6kHx2nbi26Y4ADwQndSmaDfIMJJUs4LDtaITUmUwNLAZaldqkcUamcE0LDzfZDuyOlbKkdsbDTnmgxvbeZQTyzUxNLkzaGOgnhVkd)utn80W90qpDNNY7crztd3ls4LDtaITUmUwNLAZaldqxHO54ORL5EDwQKbaIA0CCKIGBxrWJUcrZXr3njYv0LDzfZDuyifb3Uebp6YUSI5okm0LasLbPGU78uvWSRLnjY1c7YkM7pn0tTnmgxvbeZQTyzUxNLkzaGOgnhVkd)02FA4EAONUZt5DHOSPH7fj8YUjaXwxgxRZsTzGLbORq0CC01Uj9b266GvKIu0vggbpcotqWJUcrZXr3MnX1bQAtpoclGuBHUSlRyUJcdPi4Gbbp6kenhhD3Kixrx2Lvm3rHHueCHdbp6YUSI5okm0LasLbPGU7FkzmZU4AXm76wlWtd90(OLeQH9E6XvIOIvbtZgx7Jw0Kem94Ng6PKzW9bwVyJGGgV2fqWySa4cGHK0TpT9NcZtd909pTpAPztCDGQ20JJWci1wfadjPBFQPpfMNEC80DEQky21sZM46avTPhhHfqQTkSlRyU)0tp90tpoE6(NsgZSlUw8mEtRlc)0qpTpAXor4ky0IMKGPh)0qpLmdUpW6fBee041UacgJfaxamKKU9PT)uyEAONU)P9rlnBIRdu1MECewaP2QayijD7tn9PW80JJNUZtvbZUwA2exhOQn94iSasTvHDzfZ9NE6PNE6XXt3)09pLmMzxCT4mbm4b0F6XXtjJz2fxlbBbsXF6XXtjJz2fxl(48tp90qpTpAPztCDGQ20JJWci1wfnjbtp(PHEAF0sZM46avTPhhHfqQTkagss3(02Fkmp9e6kenhhDjcgxfIMJxXPvrxCA1Qlqm62fqWySa4AdGBqkcoJIGhDzxwXChfg6saPYGuqxvWSRf7aBv34QL5UTWUSI5(td9uI4vlZD0viAoo6AzUxNLkzaGOgnhhPi42ncE0LDzfZDuyOlbKkdsbD35PQGzxl2b2QUXvlZDBHDzfZ9Ng6P780(OflZ96Sujdae1O54fnjbtp(PHE6opn96coJ30Ng6P9rlKbaIA0C8cGxaSDtwXm6kenhhDTm3RZsLmaquJMJJueCbye8Ol7YkM7OWqxHO54ORepEl0LasLbPGUcrtZCTpArIhV1tB)PgfDjTiyUQciMvlcotqkcUDfbp6YUSI5okm0viAoo6kXJ3cDjGuzqkORq00mx7JwK4XB9utn8uJ(0qpfWla2UjRy(PHEAF0IepERIMKGPhJUKwemxvbeZQfbNjifb3Uebp6YUSI5okm0LasLbPGUcrtZCTpAjYTQSI5QSSGtIMJ)udpnGp944PAscME8td9uaVay7MSIz0viAoo6g5wvwXCvwwWjrZXrkcUWhcE0LDzfZDuyORq0CC0nYTQSI5QSSGtIMJJUeqQmif0DNNQjjy6Xpn0tBm3OcMDTaeOgX1QSSGtIMJBlSlRyU)0qpviAAMR9rlrUvLvmxLLfCs0C8N2(tdh6sArWCvfqmRweCMGueCMeqe8Ol7YkM7OWqxcivgKc6ANiC1UjG(tn9PMGUcrZXrxZjMRQKUIueCMyccE0LDzfZDuyOlbKkdsbD35PKXm7IRfNjGbpGo6AvqsueCMGUcrZXrxIGXvHO54vCAv0fNwT6ceJUKXm7IRifbNjWGGhDzxwXChfg6saPYGuq39pLmMzxCTyMDDRf4PHE6(NsMb3hy9sc1WEp94kruXQGPzJlaw6TE6XXt7JwsOg27PhxjIkwfmnBCTpArtsW0JF6PNg6PKzW9bwVyJGGgV2fqWySa4cGHK0TpT9NcZtd909pTpAPztCDGQ20JJWci1wfadjPBFQPpfMNEC80DEQky21sZM46avTPhhHfqQTkSlRyU)0tp90tpoE6(NU)PKXm7IRfNjGbpG(tpoEkzmZU4Ajylqk(tpoEkzmZU4AXhNF6PNg6PKzW9bwVyJGGgV2fqWySa4cGHK0TpT9NcZtd909pTpAPztCDGQ20JJWci1wfadjPBFQPpfMNEC80DEQky21sZM46avTPhhHfqQTkSlRyU)0tp90tpoE6(NsgZSlUw8mEtRlc)0qpD)tjZG7dSEXor4ky0cGLERNEC80(Of7eHRGrlAscME8tp90qpLmdUpW6fBee041UacgJfaxamKKU9PT)uyEAONU)P9rlnBIRdu1MECewaP2QayijD7tn9PW80JJNUZtvbZUwA2exhOQn94iSasTvHDzfZ9NE6PNqxHO54OlrW4Qq0C8koTk6ItRwDbIr3UacgJfaxBaCdsrWzs4qWJUSlRyUJcdDjGuzqkOlzgCFG1l2iiOXRDbemglaUayijD7tn9PAcXvDQ9KrxHO54OBxabR2jcJueCMyue8Ol7YkM7OWqxHO54OlrW4Qq0C8koTk6ItRwDbIr3uziKIGZKDJGhDzxwXChfg6saPYGuq3(OfZjMRQKUw0Kem9y0viAoo6cjyEjjvG0OragPi4mjaJGhDzxwXChfg6saPYGuq3(Of7eHRGrlAscME8td90DEQky21IDGTQBC1YC3wyxwXChDfIMJJUqcMxssfinAeGrkcot2ve8Ol7YkM7OWqxcivgKc6UZtvbZUwmNyUQs6AHDzfZD0viAoo6cjyEjjvG0OragPi4mzxIGhDzxwXChfg6saPYGuqx7eHR2nb0FQPp1OORq0CC0fsW8ssQaPrJamsrWzs4dbp6YUSI5okm0viAoo6AZMTXR4CHrxcivgKc6kennZ1(OfB2SnEfNl8tB3Wtd3td90DEAF0InB2gVIZfUOjjy6XOlPfbZvvaXSArWzcsrWbtarWJUSlRyUJcdDfIMJJUebJRcrZXR40QOloTA1figDjJz2fxrkcoymbbp6YUSI5okm0LasLbPGURrllL0zZPkRyU2zO0YfRkKGp1udpD3b8PhhpDnAzPKoBovzfZ1odLwUe180qpvtiUQtTN8tB)P7(PhhpDnAzPKoBovzfZ1odLwUyvHe8PMA4PHB3pn0t7JwSteUcgTOjjy6XORq0CC0TdK0R4CHrkcoyGbbp6MUYaquJIUMGUcrZXr3oqsVANim6YUSI5okmKIGdMWHGhDfIMJJU2nPpWwxhSIUSlRyUJcdPifDTmcEeCMGGhDfIMJJUBsKROl7YkM7OWqkcoyqWJUSlRyUJcdDtxzaiQrR5c6251OLLIDt6dSvgAfieUyvHe0udHdDfIMJJUDGKE1ory0nDLbGOgTgJNvbJUMGueCHdbp6kenhhDTBsFGTUoyfDzxwXChfgsrk6MkdHGhbNji4rxHO54OBKLRPYqw0LDzfZDuyifPOBxabJXcGRnaUbbpcotqWJUSlRyUJcdDjGuzqkOlzgCFG1l2iiOXRDbemglaUayijD7tB)PWGUcrZXrxZjMRQKUIueCWGGhDfIMJJUDbeSANim6YUSI5okmKIGlCi4rxHO54OBZO54Ol7YkM7OWqkcoJIGhDfIMJJUljGxXZ0rx2Lvm3rHHueC7gbp6kenhhDxXZ0RlrGwOl7YkM7OWqkcUamcE0viAoo6UYaldcMEm6YUSI5okmKIGBxrWJUSlRyUJcdDjGuzqkO7opLmMzxCT4mbm4b0FAONsMb3hy9InccA8AxabJXcGlagss3(02FkmORvbjrrWzc6kenhhDjcgxfIMJxXPvrxCA1Qlqm6sgZSlUIueC7se8ORq0CC01gbbnETlGGXybWOl7YkM7OWqksrk6kr62aq3BcfEIuKIqa]] )


end