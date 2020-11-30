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


    spec:RegisterPack( "Affliction", 20201129, [[dy0lFbqivGhjqQnPe(KkOuJsf5uQOELa1Seq3cuv2Le)saggOkhdv0YaLEMsettG4AQGSnbs8nLiPXPcQohOQQ1bQQuZtjQ7HkTpuvoOsKyHOQ6HkrQmrLiLlkqs5KkrQQvQcntbsQUjOQc7eu8tLivzOcKKLQck5PQ0ubv(kOQsSxG)k0GP4WKwSs6XOmzP6YiBwk(SKmALYPf9AjLzd1Tbz3u9BfdxkDCqvfTCipNstN46cA7OkFhvy8GQkPZlPA9QGI5RuTFvnGtaCGBxfcadSWdw4XjNWc)lWYjNCY5HaxPElbUTkRMwrGRRqe4UuAAWjtYXb3wToE0oaoW1oHigbUBI0AHFhqavPSfUwydua2ekeRsoodPnsa2eIfa4UgMyzPVdwb3UkeagyHhSWJtoHf(xGLto5KZLaU2wIbGb2GYHa3TS3jhScUDYYa3G(nlLMgCYKC83a)IIWdR2FmOFdmdpcALqVbw4FGVbw4bl8(J)XG(nlDBQxrw43)XG(nW3Bwk9o1FZTLW43euFy1k)XG(nW3Bwk9o1FZsJ4nHO3a)qRsw5pg0Vb(EZsP3P(BwrKwJTPUt43GNQK9MMb9MLgst)n3jex(Jb9BGV3ahhKw7nWpum1KS3CyPTsiIEdEQs2BK5nCmOAVjBEt9j8WgrVbkT20REJ(grXKlVj93iBQ8g0Wr5pg0Vb(EtqnxxX0BoSuOw1L3SuAAWjtYXTVjOIxq1BeftUu(Jb9BGV3ahhKwZ(gzEJYBY(BwXdhPx9MLMIQvHve9M0Fduiws4tuufjVHJaM3S0w6bN9nHTL)yq)g47nlDJ3j3sVXoq0BwAkQwfwr0BcQqu7BykgBFJmVbr9qg9g2a1gkQKJ)gjHOYFmOFd89MljVXoq0BykghvMKJhXPvEd5ckj7BK5nwbLm5nY8gL3K93W2iwT0REdoTI9nYMkVHJXpSL3SsVbrkBJ6fWTfnnjMa3G(nlLMgCYKC83a)IIWdR2FmOFdmdpcALqVbw4FGVbw4bl8(J)XG(nlDBQxrw43)XG(nW3Bwk9o1FZTLW43euFy1k)XG(nW3Bwk9o1FZsJ4nHO3a)qRsw5pg0Vb(EZsP3P(BwrKwJTPUt43GNQK9MMb9MLgst)n3jex(Jb9BGV3ahhKw7nWpum1KS3CyPTsiIEdEQs2BK5nCmOAVjBEt9j8WgrVbkT20REJ(grXKlVj93iBQ8g0Wr5pg0Vb(EtqnxxX0BoSuOw1L3SuAAWjtYXTVjOIxq1BeftUu(Jb9BGV3ahhKwZ(gzEJYBY(BwXdhPx9MLMIQvHve9M0Fduiws4tuufjVHJaM3S0w6bN9nHTL)yq)g47nlDJ3j3sVXoq0BwAkQwfwr0BcQqu7BykgBFJmVbr9qg9g2a1gkQKJ)gjHOYFmOFd89MljVXoq0BykghvMKJhXPvEd5ckj7BK5nwbLm5nY8gL3K93W2iwT0REdoTI9nYMkVHJXpSL3SsVbrkBJ6L)4FuzsoUT0Ii2aTQc3gch7du6QKJhy2WvsiIp4T4Gwskko5rloynSPPuHsOjruCAIwLHYMKrLW2)OYKCCBPfrSbAvLG5gGnecA8ylj)rLj542slIyd0QkbZnGkucnjIItt0Qmu2KmkWSHROyYLsfkHMerXPjAvgkBsgvixxXu)pQmjh3wAreBGwvjyUbWtrPUIPaDfI42hXgrK2RhipfhsCvMK8OyFKcBqOWwjhNp4TqzsYJI9rkA1415dEluMK8OyFKsOBfDftrTPbNmjhNp4T40bIIjxk2SDB8ioBOc56kM677ktsEuSpsXMTBJhXzdXh8oV4uFKs7M6YafTPxfIvuk1lsYQLE1((bIIjxkTBQldu0MEviwrPuVqUUIP(5)OYKCCBPfrSbAvLG5gqOLIPqqb6keXvpm2nfP2yZ4sCAITdhe6pQmjh3wAreBGwvjyUbyjQhNMiBqOWwjhpWSHRTLW4OOOksSflr940ezdcf2k54rDi(4UKfhqWpdZ2wQx4mOa)xcNb5pQmjh3wAreBGwvjyUbSPHU8hvMKJBlTiInqRQem3aSBAF4iUoyjWSH7bIIjxkBAOlfY1vm1xyBjmokkQIeBXsuponr2GqHTsoEuhA5LS4ac(zy22s9cNbf4)s4mi)X)yq)MGAWVsSqH6VH4rO6Vrsi6nYg9gLjd6nP9nkpnX6kMk)rLj54wU2wcJJ4Hv7pQmjh3gm3a6eVjefH0QK9hvMKJBdMBamfJJktYXJ40kb6keXvhkqRGsMWLZaZgUktsEuKCckjlFl5pQmjh3gm3aA3uxgOOn9QqSIsPEGzdxjHi(wc8(JktYXTbZnaMIXrLj54rCALaDfI42vuTkSIOylIAdmB4EIn8ixDPWJCzRoArFKsc1sEp9Qitf1kOPDJI9rksYQLE1c2m4(WHxSHqqJh7kQwfwrubrqA62LHDXP(iL2n1LbkAtVkeROuQxqeKMULpy33pqum5sPDtDzGI20RcXkkL6fY1vm1pFEF)eB4rU6sXZQnj2O0I(if7eIJOrksYQLE1c2m4(WHxSHqqJh7kQwfwrubrqA62LHDXP(iL2n1LbkAtVkeROuQxqeKMULpy33pqum5sPDtDzGI20RcXkkL6fY1vm1pFEF)0j2WJC1LItm0GhuFFNn8ixDPuRokvFFNn8ixDP4JtNx0hP0UPUmqrB6vHyfLs9IKSAPxTOpsPDtDzGI20RcXkkL6febPPBxg2Z)rLj542G5gGwnE9aZgU9rkA141licst3UCq(JktYXTbZnaTA86bYQZWuuuufjwUCgy2W9KYKKhfjNGsYYhNNxCQpsrRgVEbrqA62LdY5)OYKCCBWCdytdD5pQmjh3gm3aykghvMKJhXPvc0viIBxr1QWkIITiQnWSH7jLjjpksobLKLpyxWgEKRUu4rUSvhT4eBgCF4Wljul590RImvuRGM2nQGiTxFFVpsjHAjVNEvKPIAf00UrX(ifjz1sV68It9rkTBQldu0MEviwrPuVijRw6v77hikMCP0UPUmqrB6vHyfLs9c56kM6NpVVFszsYJIKtqjz5d2fNydpYvxkoXqdEq99D2WJC1LsT6Ou99D2WJC1LIpoDEXP(iL2n1LbkAtVkeROuQxKKvl9Q99deftUuA3uxgOOn9QqSIsPEHCDft9ZN33pPmj5rrYjOKS8b7c2WJC1LINvBsSrPfNyZG7dhEXoH4iAKcI0E999(if7eIJOrksYQLE15fN6JuA3uxgOOn9QqSIsPErswT0R23pqum5sPDtDzGI20RcXkkL6fY1vm1pF(pQmjh3gm3aSe1JttKniuyRKJhy2WvzsYJIKtqjz5d2fIIjxk2HJOSrrlrDBHCDft9fh0hPyjQhNMiBqOWwjhVijRw6vloi9ydoR2K)OYKCCBWCdWsuponr2GqHTsoEGzdxLjjpksobLKLpyxikMCPyZ2TXJ4SHkKRRyQV4G(iflr940ezdcf2k54fjz1sVAXbPhBWz1MSOpsHniuyRKJxqeKMUD5G8hvMKJBdMBa8smffnDjWSH7j7eIJ2nf15JZ9DLjjpksobLKLpypVGndUpC4fBie04XUIQvHvevqeKMULpoH9pQmjh3gm3acDRORykQnn4Kj54bMnCvMK8OyFKsOBfDftrTPbNmjhNl823LKvl9Qf9rkHUv0vmf1MgCYKC8cIG00TlhK)OYKCCBWCdWMTBJhXzdfy2WTpsXMTBJhXzdvqeKMUD5G8hvMKJBdMBa2SDB8ioBOaz1zykkkQIelxodmB4EszsYJIKtqjz5JZZlo1hPyZ2TXJ4SHkicst3UCqo)hvMKJBdMBamfJJktYXJ40kb6keXLn8ixDjWSH7bSHh5QlfNyObpO(FuzsoUnyUbWgekSvYXdmB4Qmj5rrYjOKSlhe47KOyYLID4ikBu0su3wixxXuFFxum5sXMTBJhXzdvixxXu)8I(if2GqHTsoEbrqA62LH9pQmjh3gm3aydcf2k54bYQZWuuuufjwUCgy2W9KYKKhfjNGsYUCqGVtIIjxk2HJOSrrlrDBHCDft99DrXKlfB2UnEeNnuHCDft9ZNxCQpsHniuyRKJxqeKMUDzyp)hvMKJBdMBaTBQldu0MEviwrPupWSHlB4rU6sXjgAWdQVVZgEKRUu8SAtInkTVZgEKRUuQvhLQVVZgEKRUu8XP)OYKCCBWCdasXutYIiTvcruGzdx7eIJ2nf15li)rLj542G5gatX4OYKC8ioTsGUcrC7kQwfwruSfrTbMnCpXgEKRUu4rUSvhT4eBgCF4Wljul590RImvuRGM2nQGiTxFFVpsjHAjVNEvKPIAf00UrX(ifjz1sV68c2m4(WHxSHqqJh7kQwfwrubrqA62LHDXP(iL2n1LbkAtVkeROuQxqeKMULpy33pqum5sPDtDzGI20RcXkkL6fY1vm1pFEF)0j2WJC1LItm0GhuFFNn8ixDPuRokvFFNn8ixDP4JtNxWMb3ho8InecA8yxr1QWkIkicst3UmSlo1hP0UPUmqrB6vHyfLs9cIG00T8b7((bIIjxkTBQldu0MEviwrPuVqUUIP(5Z77NydpYvxkEwTjXgLwCIndUpC4f7eIJOrkis71337JuStioIgPijRw6vNxWMb3ho8InecA8yxr1QWkIkicst3UmSlo1hP0UPUmqrB6vHyfLs9cIG00T8b7((bIIjxkTBQldu0MEviwrPuVqUUIP(5Z)rLj542G5gqxr1I2jehy2WLndUpC4fBie04XUIQvHvevqeKMULpjHOOmXEs)rLj542G5gatX4OYKC8ioTsGUcrCtHG(JktYXTbZnaMIXrLj54rCALaDfI4APaTckzcxodmB42P1WMMIDt7dhrcAfPmQyfLvB5tWcFktYXl2nTpCexhSusp2GZQn58(ENwdBAk2nTpCejOvKYOcIG00TlVK)OYKCCBWCdasXutYIiTvcruGzd3(iLeQL8E6vrMkQvqt7gf7JuKKvl9Q)OYKCCBWCdasXutYIiTvcruGzd3(if7eIJOrksYQLE1FuzsoUnyUbaPyQjzrK2kHikWSHROyYLs7M6YafTPxfIvuk1lKRRyQV4uFKs7M6YafTPxfIvuk1lsYQLE1(UDcXr7MI68TK9DjHOOmXEslZMb3ho8s7M6YafTPxfIvuk1licst3E(pQmjh3gm3aGum1KSisBLqefy2Wvum5sXoCeLnkAjQBlKRRyQ)hvMKJBdMBaDKMEeNnuGzd31WMMs6eVu0vmf7euAPIvuwn(cc823xdBAkPt8srxXuStqPLkHTlKeIIYe7jTCq(JktYXTbZnaMIXrLj54rCALaDfI4YgEKRU8hvMKJBdMBaA141dmB4IOgez30vm9hvMKJBdMBaA141dKvNHPOOOksSC5mWSH7jLjjpksobLKLpopV4eIAqKDtxX05)OYKCCBWCdGniuyRKJhy2WfrniYUPRyAHYKKhfjNGsYUCqGVtIIjxk2HJOSrrlrDBHCDft99DrXKlfB2UnEeNnuHCDft9Z)rLj542G5gqOBfDftrTPbNmjhpWSHlIAqKDtxX0FuzsoUnyUbyZ2TXJ4SHcmB4IOgez30vm9hvMKJBdMBa2SDB8ioBOaz1zykkkQIelxodmB4EszsYJIKtqjz5JZZloHOgez30vmD(pQmjh3gm3aydcf2k54bYQZWuuuufjwUCgy2W9KYKKhfjNGsYUCqGVtIIjxk2HJOSrrlrDBHCDft99DrXKlfB2UnEeNnuHCDft9ZNxCcrniYUPRy68FuzsoUnyUb0rA6r7eIdmDHqOWwHlN)rLj542G5gGDt7dhX1bl)X)OYKCCBrhIB7M6YafTPxfIvuk1)JktYXTfDOG5gWMg6YFuzsoUTOdfm3aykghvMKJhXPvc0viIBxr1QWkIITiQnWSH7j2WJC1LcpYLT6Of9rkjul590RImvuRGM2nk2hPijRw6vlyZG7dhEXgcbnESROAvyfrfebPPBxg2fN6JuA3uxgOOn9QqSIsPEbrqA6w(GDF)arXKlL2n1LbkAtVkeROuQxixxXu)8599tSHh5QlfpR2KyJsl6JuStioIgPijRw6vlyZG7dhEXgcbnESROAvyfrfebPPBxg2fN6JuA3uxgOOn9QqSIsPEbrqA6w(GDF)arXKlL2n1LbkAtVkeROuQxixxXu)8599tNydpYvxkoXqdEq99D2WJC1LsT6Ou99D2WJC1LIpoDErFKs7M6YafTPxfIvuk1lsYQLE1I(iL2n1LbkAtVkeROuQxqeKMUDzyp)hvMKJBl6qbZnalr940ezdcf2k54bMnCfftUuSdhrzJIwI62c56kM6lyQhTe1)JktYXTfDOG5gGLOECAISbHcBLC8aZgUhikMCPyhoIYgfTe1TfY1vm1xCqFKILOECAISbHcBLC8IKSAPxT4G0Jn4SAtw0hPWgekSvYXliQbr2nDft)rLj542IouWCdqRgVEGS6mmfffvrILlNbMnCvMK8OyFKIwnE9LdYFuzsoUTOdfm3a0QXRhiRodtrrrvKy5YzGzdxLjjpk2hPOvJxNpUbzbIAqKDtxX0I(ifTA86fjz1sV6pQmjh3w0HcMBaHUv0vmf1MgCYKC8aZgUktsEuSpsj0TIUIPO20GtMKJZfE77sYQLE1ce1Gi7MUIP)OYKCCBrhkyUbe6wrxXuuBAWjtYXdKvNHPOOOksSC5mWSH7bsYQLE1IwETIIjxkifQvDjQnn4Kj542c56kM6luMK8OyFKsOBfDftrTPbNmjhF5L8hvMKJBl6qbZnaEjMIIMUey2W1oH4ODtrD(48pQmjh3w0HcMBamfJJktYXJ40kb6keXLn8ixDjqRGsMWLZaZgUhWgEKRUuCIHg8G6)rLj542IouWCdGPyCuzsoEeNwjqxHiUDfvRcRik2IO2aZgUNydpYvxk8ix2QJwCIndUpC4LeQL8E6vrMkQvqt7gvqK2RVV3hPKqTK3tVkYurTcAA3OyFKIKSAPxDEbBgCF4Wl2qiOXJDfvRcRiQGiinD7YWU4uFKs7M6YafTPxfIvuk1licst3YhS77hikMCP0UPUmqrB6vHyfLs9c56kM6NpVVF6eB4rU6sXjgAWdQVVZgEKRUuQvhLQVVZgEKRUu8XPZlyZG7dhEXgcbnESROAvyfrfebPPBxg2fN6JuA3uxgOOn9QqSIsPEbrqA6w(GDF)arXKlL2n1LbkAtVkeROuQxixxXu)8599tSHh5QlfpR2KyJsloXMb3ho8IDcXr0ifeP96779rk2jehrJuKKvl9QZlyZG7dhEXgcbnESROAvyfrfebPPBxg2fN6JuA3uxgOOn9QqSIsPEbrqA6w(GDF)arXKlL2n1LbkAtVkeROuQxixxXu)85)OYKCCBrhkyUb0vuTODcXbMnCzZG7dhEXgcbnESROAvyfrfebPPB5tsikktSN0FuzsoUTOdfm3aykghvMKJhXPvc0viIBke0FuzsoUTOdfm3aGum1KSisBLqefy2WTpsHxIPOOPlfjz1sV6pQmjh3w0HcMBaqkMAswePTsiIcmB42hPyNqCensrswT0RwCGOyYLID4ikBu0su3wixxXu)pQmjh3w0HcMBaqkMAswePTsiIcmB4EGOyYLcVetrrtxkKRRyQ)hvMKJBl6qbZnaiftnjlI0wjerbMnCTtioA3uuNVG8hvMKJBl6qbZnaB2UnEeNnuGS6mmfffvrILlNbMnCpPmj5rX(ifB2UnEeNn0YCxY5fNoOpsXMTBJhXzdvKKvl9QZ)rLj542IouWCdOJ00J4SHcmB4Ug20usN4LIUIPyNGslvSIYQXh3dbV991WMMs6eVu0vmf7euAPsy7cjHOOmXEslFO)OYKCCBrhkyUb0rA6r7eI)JktYXTfDOG5gatX4OYKC8ioTsGUcrCzdpYvx(JktYXTfDOG5gqhPPhXzdfy2WDnSPPKoXlfDftXobLwQyfLvJpUhcE77RHnnL0jEPORyk2jO0sLW2fscrrzI9Kw(q77RHnnL0jEPORyk2jO0sfROSA8XDjhArFKIDcXr0ifjz1sV6pQmjh3w0HcMBaDKME0oH4atxiekSv4Y5FuzsoUTOdfm3aSBAF4iUoy5p(hvMKJBlSHh5QlCtOwY7PxfzQOwbnTBuGzdx2m4(WHxSHqqJh7kQwfwrubrqA62L5eE77SzW9HdVydHGgp2vuTkSIOcIG00T8Di49hvMKJBlSHh5QlbZnGoXsivsVkUoyjWSHlBgCF4Wl2qiOXJDfvRcRiQGiinDlFhAXPoTg20u20qxkicst3Yxq23pqum5sztdDPqUUIP(5)OYKCCBHn8ixDjyUbyNqCensGzdx2m4(WHxSHqqJh7kQwfwrubrqA62Lp0(oBgCF4Wl2qiOXJDfvRcRiQGiinDlFhcE77SzW9HdVydHGgp2vuTkSIOcIG00T8b7HwWgVhMsHniuyRKEveteQqUUIP(FuzsoUTWgEKRUem3aSSjeLEvuszJ(JktYXTf2WJC1LG5gahdc35rPhrKDC1z0FuzsoUTWgEKRUem3aGiObvponrCil7XoIui7FuzsoUTWgEKRUem3awXZ0Jttu2Oi5eu9)OYKCCBHn8ixDjyUbufQOEQECAI6HHqJS9hvMKJBlSHh5QlbZnau22IPy6rBRYO)OYKCCBHn8ixDjyUb0mSql1J6HHqPqXvsH(JktYXTf2WJC1LG5gqBikBQNEvCfRw5pQmjh3wydpYvxcMBaisBtVk2GviYgy2WvuufjLnsXYwSLj8D4WBFxuufjLnsXYwSLjldl823ffvrsrsikktSLjryHhFbbE77nz1MereKMUDzyH3FuzsoUTWgEKRUem3ayJZixqQq9ydwHO)OYKCCBHn8ixDjyUbiBum0xNqVhBgeJcmB4Ug20uqeRgMS2yZGyubrqA62)OYKCCBHn8ixDjyUbyztik9QOKYg9hvMKJBlSHh5QlbZnGeQL8E6vrMkQvqt7g9hvMKJBlSHh5QlbZna7eIJOrcmB4EAnSPPKoXlfDftXobLwQyfLvJVLC477ktsEuKCckjlFCE(pQmjh3wydpYvxcMBaDILqQKEvCDWsGzd3tIIQiPSrkw2ITmz5dbV99MSAtIicst3Y3HG35)4FuzsoUT0vuTkSIOylIA5YlXuu00LaZgUSzW9HdVydHGgp2vuTkSIOcIG00Tld7FuzsoUT0vuTkSIOylIAdMBaDfvlANq8FuzsoUT0vuTkSIOylIAdMBaTJKJ)hvMKJBlDfvRcRik2IO2G5gqtIOv8m9)OYKCCBPROAvyfrXwe1gm3awXZ0JnHO6)rLj542sxr1QWkIITiQnyUbSsilHQLE1FuzsoUT0vuTkSIOylIAdMBamfJJktYXJ40kb6keXLn8ixDjqRGsMWLZaZgUhWgEKRUuCIHg8G6lyZG7dhEXgcbnESROAvyfrfebPPBxg2)OYKCCBPROAvyfrXwe1gm3aSHqqJh7kQwfwruGzdxLjjpk2hPWlXuu00f(G3(UYKKhf7JuA3uxgOOn9QqSIsPoFWBFxum5sXoCeLnkAjQBlKRRyQVVF6arXKlfEjMIIMUuixxXuFXbIIjxkTBQldu0MEviwrPuVqUUIP(5)4FuzsoUTKcbXn0sXuii7F8pQmjh3wSe3nn0L)OYKCCBXsbZnGostpANqCGPlecf2kXk8SQyUCgy6cHqHTsmB42P1WMMIDt7dhrcAfPmQyfLvJpUl5pQmjh3wSuWCdWUP9HJ46GfWLhHS54ayGfEWcpo5e2dhC5qrE6vwWDPpu7GeQ)ML6BuMKJ)gCAfB5pcUAOSniW9MqlDGloTIfah4YgEKRUaGdadNa4axY1vm1b8dUmukekvWLndUpC4fBie04XUIQvHvevqeKMU9nl)goH3B23FdBgCF4Wl2qiOXJDfvRcRiQGiinD7B47nhcEGRYKCCWnHAjVNEvKPIAf00UrabadSa4axY1vm1b8dUmukekvWLndUpC4fBie04XUIQvHvevqeKMU9n89Md9MfV50B60AyttztdDPGiinD7B47nb5n77V5G3ikMCPSPHUuixxXu)nNbxLj54GBNyjKkPxfxhSaeamlbah4sUUIPoGFWLHsHqPcUSzW9HdVydHGgp2vuTkSIOcIG00TVz53CO3SV)g2m4(WHxSHqqJh7kQwfwrubrqA623W3Boe8EZ((ByZG7dhEXgcbnESROAvyfrfebPPBFdFVb2d9MfVHnEpmLcBqOWwj9QiMiuHCDftDWvzsoo4ANqCencqaWeeaCGRYKCCW1YMqu6vrjLncCjxxXuhWpqaWCiaCGRYKCCWLJbH78O0JiYoU6mcCjxxXuhWpqaWeuaWbUktYXbxicAq1JttehYYESJifYcUKRRyQd4hiaywQa4axLj54G7kEMECAIYgfjNGQdUKRRyQd4hiayoCaCGRYKCCWTkur9u940e1ddHgzdCjxxXuhWpqaWa)bWbUktYXbxu22IPy6rBRYiWLCDftDa)abadNWdah4QmjhhCBgwOL6r9WqOuO4kPqGl56kM6a(bcago5eah4QmjhhCBdrzt90RIRy1kGl56kM6a(bcagoHfah4sUUIPoGFWLHsHqPcUIIQiPSrkw2ITm5n89MdhEVzF)nIIQiPSrkw2ITm5nl)gyH3B23FJOOkskscrrzITmjcl8EdFVjiW7n77VPjR2KiIG00TVz53al8axLj54GlI020RInyfISabadNlbah4QmjhhCzJZixqQq9ydwHiWLCDftDa)abadNbbah4sUUIPoGFWLHsHqPcURHnnfeXQHjRn2migvqeKMUfCvMKJdUYgfd91j07XMbXiGaGHZdbGdCvMKJdUw2eIsVkkPSrGl56kM6a(bcagodka4axLj54GBc1sEp9Qitf1kOPDJaxY1vm1b8deamCUubWbUKRRyQd4hCzOuiuQG7P3Sg20usN4LIUIPyNGslvSIYQ9g(EZso83SV)gLjjpksobLK9n89goFZzWvzsoo4ANqCencqaWW5HdGdCjxxXuhWp4YqPqOub3tVruufjLnsXYwSLjVz53Ci49M9930KvBserqA623W3Boe8EZzWvzsoo42jwcPs6vX1blabiGBNA0qSaGdadNa4axLj54GRTLW4iEy1axY1vm1b8deamWcGdCvMKJdUDI3eIIqAvYaxY1vm1b8deamlbah4sUUIPoGFWLHsHqPcUktsEuKCckj7B47nlbCTckzcagobxLj54GltX4OYKC8ioTc4ItReDfIaxDiGaGjia4axY1vm1b8dUmukekvWvsi6n89MLapWvzsoo42UPUmqrB6vHyfLsDGaG5qa4axY1vm1b8dUmukekvW90BydpYvxk8ix2QJEZI30hPKqTK3tVkYurTcAA3OyFKIKSAPx9MfVHndUpC4fBie04XUIQvHvevqeKMU9nl)gyFZI3C6n9rkTBQldu0MEviwrPuVGiinD7B47nW(M993CWBeftUuA3uxgOOn9QqSIsPEHCDft93C(nNFZ((Bo9g2WJC1LINvBsSrP3S4n9rk2jehrJuKKvl9Q3S4nSzW9HdVydHGgp2vuTkSIOcIG00TVz53a7Bw8MtVPpsPDtDzGI20RcXkkL6febPPBFdFVb23SV)MdEJOyYLs7M6YafTPxfIvuk1lKRRyQ)MZV58B23FZP3C6nSHh5QlfNyObpO(B23FdB4rU6sPwDuQ(B23FdB4rU6sXhNEZ53S4n9rkTBQldu0MEviwrPuVijRw6vVzXB6JuA3uxgOOn9QqSIsPEbrqA623S8BG9nNbxLj54GltX4OYKC8ioTc4ItReDfIa3UIQvHvefBrulqaWeuaWbUKRRyQd4hCzOuiuQGBFKIwnE9cIG00TVz53eeWvzsoo4QvJxhiaywQa4axY1vm1b8dUktYXbxTA86GldLcHsfCp9gLjjpksobLK9n89goFZ53S4nNEtFKIwnE9cIG00TVz53eK3CgCz1zykkkQIelagobcaMdhah4QmjhhC30qxaxY1vm1b8deamWFaCGl56kM6a(bxgkfcLk4E6nktsEuKCckj7B47nW(MfVHn8ixDPWJCzRo6nlEZP3WMb3ho8sc1sEp9Qitf1kOPDJkis71FZ((B6JusOwY7PxfzQOwbnTBuSpsrswT0REZ53S4nNEtFKs7M6YafTPxfIvuk1lsYQLE1B23FZbVrum5sPDtDzGI20RcXkkL6fY1vm1FZ53C(n77V50BuMK8Oi5eus23W3BG9nlEZP3WgEKRUuCIHg8G6VzF)nSHh5QlLA1rP6VzF)nSHh5QlfFC6nNFZI3C6n9rkTBQldu0MEviwrPuVijRw6vVzF)nh8grXKlL2n1LbkAtVkeROuQxixxXu)nNFZ53SV)MtVrzsYJIKtqjzFdFVb23S4nSHh5QlfpR2KyJsVzXBo9g2m4(WHxStioIgPGiTx)n77VPpsXoH4iAKIKSAPx9MZVzXBo9M(iL2n1LbkAtVkeROuQxKKvl9Q3SV)MdEJOyYLs7M6YafTPxfIvuk1lKRRyQ)MZV5m4QmjhhCzkghvMKJhXPvaxCALORqe42vuTkSIOylIAbcagoHhaoWLCDftDa)GldLcHsfCvMK8Oi5eus23W3BG9nlEJOyYLID4ikBu0su3wixxXu)nlEZbVPpsXsuponr2GqHTsoErswT0REZI3CWBsp2GZQnbCvMKJdUwI6XPjYgekSvYXbcago5eah4sUUIPoGFWLHsHqPcUktsEuKCckj7B47nW(MfVrum5sXMTBJhXzdvixxXu)nlEZbVPpsXsuponr2GqHTsoErswT0REZI3CWBsp2GZQn5nlEtFKcBqOWwjhVGiinD7Bw(nbbCvMKJdUwI6XPjYgekSvYXbcagoHfah4sUUIPoGFWLHsHqPcUNEJDcXr7MI6VHV3W5B23FJYKKhfjNGsY(g(EdSV58Bw8g2m4(WHxSHqqJh7kQwfwrubrqA623W3B4ewWvzsoo4YlXuu00fGaGHZLaGdCjxxXuhWp4YqPqOubxLjjpk2hPe6wrxXuuBAWjtYXFd33aV3SV)gjz1sV6nlEtFKsOBfDftrTPbNmjhVGiinD7Bw(nbbCvMKJdUHUv0vmf1MgCYKCCGaGHZGaGdCjxxXuhWp4YqPqOub3(ifB2UnEeNnubrqA623S8Bcc4QmjhhCTz724rC2qabadNhcah4sUUIPoGFWvzsoo4AZ2TXJ4SHaxgkfcLk4E6nktsEuKCckj7B47nC(MZVzXBo9M(ifB2UnEeNnubrqA623S8BcYBodUS6mmfffvrIfadNabadNbfaCGl56kM6a(bxgkfcLk4EWBydpYvxkoXqdEqDWvzsoo4YumoQmjhpItRaU40krxHiWLn8ixDbiay4CPcGdCjxxXuhWp4YqPqOubxLjjpksobLK9nl)MG8g47nNEJOyYLID4ikBu0su3wixxXu)n77Vrum5sXMTBJhXzdvixxXu)nNFZI30hPWgekSvYXlicst3(MLFdSGRYKCCWLniuyRKJdeamCE4a4axY1vm1b8dUktYXbx2GqHTsoo4YqPqOub3tVrzsYJIKtqjzFZYVjiVb(EZP3ikMCPyhoIYgfTe1TfY1vm1FZ((BeftUuSz724rC2qfY1vm1FZ53C(nlEZP30hPWgekSvYXlicst3(MLFdSV5m4YQZWuuuufjwamCceamCc)bWbUKRRyQd4hCzOuiuQGlB4rU6sXjgAWdQ)M993WgEKRUu8SAtInk9M993WgEKRUuQvhLQ)M993WgEKRUu8XjWvzsoo42UPUmqrB6vHyfLsDGaGbw4bGdCjxxXuhWp4YqPqOubx7eIJ2nf1FdFVjiGRYKCCWfsXutYIiTvcreqaWalNa4axY1vm1b8dUmukekvW90BydpYvxk8ix2QJEZI3C6nSzW9HdVKqTK3tVkYurTcAA3OcI0E93SV)M(iLeQL8E6vrMkQvqt7gf7JuKKvl9Q3C(nlEdBgCF4Wl2qiOXJDfvRcRiQGiinD7Bw(nW(MfV50B6JuA3uxgOOn9QqSIsPEbrqA623W3BG9n77V5G3ikMCP0UPUmqrB6vHyfLs9c56kM6V58Bo)M993C6nNEdB4rU6sXjgAWdQ)M993WgEKRUuQvhLQ)M993WgEKRUu8XP3C(nlEdBgCF4Wl2qiOXJDfvRcRiQGiinD7Bw(nW(MfV50B6JuA3uxgOOn9QqSIsPEbrqA623W3BG9n77V5G3ikMCP0UPUmqrB6vHyfLs9c56kM6V58Bo)M993C6nSHh5QlfpR2KyJsVzXBo9g2m4(WHxStioIgPGiTx)n77VPpsXoH4iAKIKSAPx9MZVzXByZG7dhEXgcbnESROAvyfrfebPPBFZYVb23S4nNEtFKs7M6YafTPxfIvuk1licst3(g(EdSVzF)nh8grXKlL2n1LbkAtVkeROuQxixxXu)nNFZzWvzsoo4YumoQmjhpItRaU40krxHiWTROAvyfrXwe1ceamWclaoWLCDftDa)GldLcHsfCzZG7dhEXgcbnESROAvyfrfebPPBFdFVrsikktSNe4QmjhhC7kQw0oHyGaGb2LaGdCjxxXuhWp4QmjhhCzkghvMKJhXPvaxCALORqe4McbbeamWgeaCGl56kM6a(bxgkfcLk42P1WMMIDt7dhrcAfPmQyfLv7nl)MtVb23aFVrzsoEXUP9HJ46GLs6XgCwTjV58B23FtNwdBAk2nTpCejOvKYOcIG00TVz53SeW1kOKjay4eCvMKJdUmfJJktYXJ40kGloTs0vicCTeqaWa7HaWbUKRRyQd4hCzOuiuQGBFKsc1sEp9Qitf1kOPDJI9rksYQLEf4QmjhhCHum1KSisBLqebeamWguaWbUKRRyQd4hCzOuiuQGBFKIDcXr0ifjz1sVcCvMKJdUqkMAswePTsiIacagyxQa4axY1vm1b8dUmukekvWvum5sPDtDzGI20RcXkkL6fY1vm1FZI3C6n9rkTBQldu0MEviwrPuVijRw6vVzF)n2jehTBkQ)g(EZsEZ((BKeIIYe7j9MLFdBgCF4WlTBQldu0MEviwrPuVGiinD7BodUktYXbxiftnjlI0wjerabadShoaoWLCDftDa)GldLcHsfCfftUuSdhrzJIwI62c56kM6GRYKCCWfsXutYIiTvcreqaWal8hah4sUUIPoGFWLHsHqPcURHnnL0jEPORyk2jO0sfROSAVHV3ee49M993Sg20usN4LIUIPyNGslvcBFZI3ijefLj2t6nl)MGaUktYXb3ostpIZgciaywc8aWbUKRRyQd4hCvMKJdUmfJJktYXJ40kGloTs0vicCzdpYvxacaMLWjaoWLCDftDa)GldLcHsfCrudISB6kMaxLj54GRwnEDGaGzjWcGdCjxxXuhWp4QmjhhC1QXRdUmukekvW90BuMK8Oi5eus23W3B48nNFZI3C6niQbr2nDftV5m4YQZWuuuufjwamCceamlzja4axY1vm1b8dUmukekvWfrniYUPRy6nlEJYKKhfjNGsY(MLFtqEd89MtVrum5sXoCeLnkAjQBlKRRyQ)M993ikMCPyZ2TXJ4SHkKRRyQ)MZGRYKCCWLniuyRKJdeamljia4axY1vm1b8dUmukekvWfrniYUPRycCvMKJdUHUv0vmf1MgCYKCCGaGzjhcah4sUUIPoGFWLHsHqPcUiQbr2nDftGRYKCCW1MTBJhXzdbeamljOaGdCjxxXuhWp4QmjhhCTz724rC2qGldLcHsfCp9gLjjpksobLK9n89goFZ53S4nNEdIAqKDtxX0BodUS6mmfffvrIfadNabaZswQa4axY1vm1b8dUktYXbx2GqHTsoo4YqPqOub3tVrzsYJIKtqjzFZYVjiVb(EZP3ikMCPyhoIYgfTe1TfY1vm1FZ((BeftUuSz724rC2qfY1vm1FZ53C(nlEZP3GOgez30vm9MZGlRodtrrrvKybWWjqaWSKdhah4MUqiuyRaUCcUktYXb3ostpANqm4sUUIPoGFGaGzjWFaCGRYKCCW1UP9HJ46GfWLCDftDa)abiGBlIyd0Qka4aWWjaoWLCDftDa)GldLcHsfCLeIEdFVbEVzXBo4nTKuuCYJEZI3CWBwdBAkvOeAsefNMOvzOSjzujSfCvMKJdUneo2hO0vjhhiayGfah4QmjhhCTHqqJhBi8wOlecCjxxXuhWpqaWSeaCGl56kM6a(bxgkfcLk4kkMCPuHsOjruCAIwLHYMKrfY1vm1bxLj54GBfkHMerXPjAvgkBsgbeambbah4sUUIPoGFWDAbxljGRYKCCWLNIsDftGlpfhsGRYKKhf7Juydcf2k54VHV3aV3S4nktsEuSpsrRgV(B47nW7nlEJYKKhf7JucDRORykQnn4Kj54VHV3aV3S4nNEZbVrum5sXMTBJhXzdvixxXu)n77VrzsYJI9rk2SDB8ioBO3W3BG3Bo)MfV50B6JuA3uxgOOn9QqSIsPErswT0REZ((Bo4nIIjxkTBQldu0MEviwrPuVqUUIP(BodU8uu0vicC7JyJis71bcaMdbGdCjxxXuhWp46kebU6HXUPi1gBgxIttSD4GqGRYKCCWvpm2nfP2yZ4sCAITdheciaycka4axY1vm1b8dUmukekvW12syCuuufj2ILOECAISbHcBLC8Oo0B4J7BwYBw8MdEdb)mmBBPErpm2nfP2yZ4sCAITdhecCvMKJdUwI6XPjYgekSvYXbcaMLkaoWvzsoo4UPHUaUKRRyQd4hiayoCaCGl56kM6a(bxgkfcLk4EWBeftUu20qxkKRRyQ)MfVX2syCuuufj2ILOECAISbHcBLC8Oo0Bw(nl5nlEZbVHGFgMTTuVOhg7MIuBSzCjonX2HdcbUktYXbx7M2hoIRdwacqaxDiaCay4eah4QmjhhCB3uxgOOn9QqSIsPo4sUUIPoGFGaGbwaCGRYKCCWDtdDbCjxxXuhWpqaWSeaCGl56kM6a(bxgkfcLk4E6nSHh5QlfEKlB1rVzXB6JusOwY7PxfzQOwbnTBuSpsrswT0REZI3WMb3ho8InecA8yxr1QWkIkicst3(MLFdSVzXBo9M(iL2n1LbkAtVkeROuQxqeKMU9n89gyFZ((Bo4nIIjxkTBQldu0MEviwrPuVqUUIP(Bo)MZVzF)nNEdB4rU6sXZQnj2O0Bw8M(if7eIJOrksYQLE1Bw8g2m4(WHxSHqqJh7kQwfwrubrqA623S8BG9nlEZP30hP0UPUmqrB6vHyfLs9cIG00TVHV3a7B23FZbVrum5sPDtDzGI20RcXkkL6fY1vm1FZ53C(n77V50Bo9g2WJC1LItm0Ghu)n77VHn8ixDPuRokv)n77VHn8ixDP4JtV58Bw8M(iL2n1LbkAtVkeROuQxKKvl9Q3S4n9rkTBQldu0MEviwrPuVGiinD7Bw(nW(MZGRYKCCWLPyCuzsoEeNwbCXPvIUcrGBxr1QWkIITiQfiayccaoWLCDftDa)GldLcHsfCfftUuSdhrzJIwI62c56kM6VzXByQhTe1bxLj54GRLOECAISbHcBLCCGaG5qa4axY1vm1b8dUmukekvW9G3ikMCPyhoIYgfTe1TfY1vm1FZI3CWB6JuSe1JttKniuyRKJxKKvl9Q3S4nh8M0Jn4SAtEZI30hPWgekSvYXliQbr2nDftGRYKCCW1suponr2GqHTsooqaWeuaWbUKRRyQd4hCvMKJdUA141bxgkfcLk4Qmj5rX(ifTA86Vz53eeWLvNHPOOOksSay4eiaywQa4axY1vm1b8dUktYXbxTA86GldLcHsfCvMK8OyFKIwnE93Wh33eK3S4niQbr2nDftVzXB6Ju0QXRxKKvl9kWLvNHPOOOksSay4eiayoCaCGl56kM6a(bxgkfcLk4Qmj5rX(iLq3k6kMIAtdozso(B4(g49M993ijRw6vVzXBqudISB6kMaxLj54GBOBfDftrTPbNmjhhiayG)a4axY1vm1b8dUktYXb3q3k6kMIAtdozsoo4YqPqOub3dEJKSAPx9MfVPLxROyYLcsHAvxIAtdozsoUTqUUIP(Bw8gLjjpk2hPe6wrxXuuBAWjtYXFZYVzjGlRodtrrrvKybWWjqaWWj8aWbUKRRyQd4hCzOuiuQGRDcXr7MI6VHV3Wj4QmjhhC5LykkA6cqaWWjNa4axY1vm1b8dUmukekvW9G3WgEKRUuCIHg8G6GRvqjtaWWj4QmjhhCzkghvMKJhXPvaxCALORqe4YgEKRUaeamCclaoWLCDftDa)GldLcHsfCp9g2WJC1LcpYLT6O3S4nNEdBgCF4Wljul590RImvuRGM2nQGiTx)n77VPpsjHAjVNEvKPIAf00UrX(ifjz1sV6nNFZI3WMb3ho8InecA8yxr1QWkIkicst3(MLFdSVzXBo9M(iL2n1LbkAtVkeROuQxqeKMU9n89gyFZ((Bo4nIIjxkTBQldu0MEviwrPuVqUUIP(Bo)MZVzF)nNEZP3WgEKRUuCIHg8G6VzF)nSHh5QlLA1rP6VzF)nSHh5QlfFC6nNFZI3WMb3ho8InecA8yxr1QWkIkicst3(MLFdSVzXBo9M(iL2n1LbkAtVkeROuQxqeKMU9n89gyFZ((Bo4nIIjxkTBQldu0MEviwrPuVqUUIP(Bo)MZVzF)nNEdB4rU6sXZQnj2O0Bw8MtVHndUpC4f7eIJOrkis71FZ((B6JuStioIgPijRw6vV58Bw8g2m4(WHxSHqqJh7kQwfwrubrqA623S8BG9nlEZP30hP0UPUmqrB6vHyfLs9cIG00TVHV3a7B23FZbVrum5sPDtDzGI20RcXkkL6fY1vm1FZ53CgCvMKJdUmfJJktYXJ40kGloTs0vicC7kQwfwruSfrTabadNlbah4sUUIPoGFWLHsHqPcUSzW9HdVydHGgp2vuTkSIOcIG00TVHV3ijefLj2tcCvMKJdUDfvlANqmqaWWzqaWbUKRRyQd4hCvMKJdUmfJJktYXJ40kGloTs0vicCtHGacagopeaoWLCDftDa)GldLcHsfC7Ju4LykkA6srswT0RaxLj54GlKIPMKfrAReIiGaGHZGcaoWLCDftDa)GldLcHsfC7JuStioIgPijRw6vVzXBo4nIIjxk2HJOSrrlrDBHCDftDWvzsoo4cPyQjzrK2kHiciay4CPcGdCjxxXuhWp4YqPqOub3dEJOyYLcVetrrtxkKRRyQdUktYXbxiftnjlI0wjerabadNhoaoWLCDftDa)GldLcHsfCTtioA3uu)n89MGaUktYXbxiftnjlI0wjerabadNWFaCGl56kM6a(bxLj54GRnB3gpIZgcCzOuiuQG7P3Omj5rX(ifB2UnEeNn0BwM7BwYBo)MfV50Bo4n9rk2SDB8ioBOIKSAPx9MZGlRodtrrrvKybWWjqaWal8aWbUKRRyQd4hCzOuiuQG7AyttjDIxk6kMIDckTuXkkR2B4J7Boe8EZ((BwdBAkPt8srxXuStqPLkHTVzXBKeIIYe7j9MLFZHaxLj54GBhPPhXzdbeamWYjaoWvzsoo42rA6r7eIbxY1vm1b8deamWclaoWLCDftDa)GRYKCCWLPyCuzsoEeNwbCXPvIUcrGlB4rU6cqaWa7saWbUKRRyQd4hCzOuiuQG7AyttjDIxk6kMIDckTuXkkR2B4J7Boe8EZ((BwdBAkPt8srxXuStqPLkHTVzXBKeIIYe7j9MLFZHEZ((BwdBAkPt8srxXuStqPLkwrz1EdFCFZso0Bw8M(if7eIJOrksYQLEf4QmjhhC7in9ioBiGaGb2GaGdCtxiekSvaxobxLj54GBhPPhTtigCjxxXuhWpqaWa7HaWbUktYXbx7M2hoIRdwaxY1vm1b8deGaUDfvRcRik2IOwaCay4eah4sUUIPoGFWLHsHqPcUSzW9HdVydHGgp2vuTkSIOcIG00TVz53al4QmjhhC5LykkA6cqaWalaoWvzsoo42vuTODcXGl56kM6a(bcaMLaGdCvMKJdUTJKJdUKRRyQd4hiayccaoWvzsoo42KiAfpthCjxxXuhWpqaWCiaCGRYKCCWDfptp2eIQdUKRRyQd4hiaycka4axLj54G7kHSeQw6vGl56kM6a(bcaMLkaoWLCDftDa)GldLcHsfCp4nSHh5QlfNyObpO(Bw8g2m4(WHxSHqqJh7kQwfwrubrqA623S8BGfCTckzcagobxLj54GltX4OYKC8ioTc4ItReDfIax2WJC1fGaG5WbWbUKRRyQd4hCzOuiuQGRYKKhf7Ju4LykkA6YB47nW7n77VrzsYJI9rkTBQldu0MEviwrPu)n89g49M993ikMCPyhoIYgfTe1TfY1vm1FZ((Bo9MdEJOyYLcVetrrtxkKRRyQ)MfV5G3ikMCP0UPUmqrB6vHyfLs9c56kM6V5m4QmjhhCTHqqJh7kQwfwreqac4McbbGdadNa4axLj54GBOLIPqqwWLCDftDa)abiGRLaWbGHtaCGRYKCCWDtdDbCjxxXuhWpqaWalaoWLCDftDa)GB6cHqHTsmBa3oTg20uSBAF4isqRiLrfROSA8XDjGRYKCCWTJ00J2jedUPlecf2kXk8SQyWLtGaGzja4axLj54GRDt7dhX1blGl56kM6a(bcqacqacaa]] )


end