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
            tick_time = function () return haste end,
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

            tick_time = function () return class.auras.drain_soul.tick_time end,

            start = function ()
                applyDebuff( "target", "drain_soul" )
                applyBuff( "casting", 5 * haste )
                channelSpell( "drain_soul" )
                removeStack( "decimating_bolt" )
                removeBuff( "malefic_wrath" )

                if level > 51 then applyDebuff( "target", "shadow_embrace", nil, debuff.shadow_embrace.stack + 1 ) end
            end,

            tick = function ()
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


    spec:RegisterPack( "Affliction", 20201124, [[dyuNHbqivepsfj2Ks4tQijmkrWPeHEfrPzreULiI2Lu(frQHPsLJjIAzQeptePPPsvxtjQ2Mic(MsuyCQivNtjkzDIiKMNsK7bj7JO4GkrrlKi6HIiuMOksPlkIq1jvrsQvQIAMQij6MQif2PkPFQIKKHQIu0svrs5Pk1uvP8vrec7vv)LQgSOomQfRKEmutwQUmYMLuFwcJwfoTWRLiZg0THy3u(TIHlshxfjvlh45uz6KUUKSDIQVtKmEreIoVe16vIsnFi1(j8N8F73DwP)6L7UCxYjF5(2LKExstEz9BTCk97ugxIlOFBmc97LzDnmWAm2Vt5YWH7)TF7MkaM(9HQPUKOslDrOhvRn8GiTlqQGSgJHbCTkTlqWs)71QaQNQTF93DwP)6L7UCxYjF5(2LKE3Ll3)BxkH)Rxscl)3hrVt2V(7o5W)(ue5LzDnmWAmMiNebdGdUK48PiYxh5eYkbe5l3lHiF5Ul3joloFkICsSd2kixsuX5trKtsrEz27uxK3PeekYNkhCPM48PiYjPiVm7DQlYNws(ube5tdUiWnX5trKtsrEz27uxKxbexcFWMrqrgofbwKRhGiFAbCyI8EQGnX5trKtsr(MuexsKpnyivhyr(uJt1kajYWPiWISoISudOKih1IC5P6ubGezKW5cRqKzrwzizQihMiRhSkYGrQM48PiYjPiNe34vijYNAmskBQiVmRRHbwJXCI8PP8ttrwzizAtC(ue5KuKVjfXLCISoImlFIUiVchPcRqKpTmOubKbKihMiJub1ijvguqQilL0JiFApvDZjYvPTFNcM6as)(ue5LzDnmWAmMiNebdGdUK48PiYxh5eYkbe5l3lHiF5Ul3joloFkICsSd2kixsuX5trKtsrEz27uxK3PeekYNkhCPM48PiYjPiVm7DQlYNws(ube5tdUiWnX5trKtsrEz27uxKxbexcFWMrqrgofbwKRhGiFAbCyI8EQGnX5trKtsr(MuexsKpnyivhyr(uJt1kajYWPiWISoISudOKih1IC5P6ubGezKW5cRqKzrwzizQihMiRhSkYGrQM48PiYjPiNe34vijYNAmskBQiVmRRHbwJXCI8PP8ttrwzizAtC(ue5KuKVjfXLCISoImlFIUiVchPcRqKpTmOubKbKihMiJub1ijvguqQilL0JiFApvDZjYvPnXzXzgRXyUwkGWdYkROQjOVpiHXAmMernknqizUBXjPK2yyiNwCYAvDDRaeitai)u7Dmge1bMAvPIZmwJXCTuaHhKvwLfL0UkeKX8PKkoZyngZ1sbeEqwzvwusxacKjaKFQ9ogdI6atse1OugsM2kabYeaYp1EhJbrDGPgz8kK6IZmwJXCTuaHhKvwLfL0YzqWRqscJriu9rDEaX9YsiNHvekgRHCY3hTHhaOkvJXK5Ufmwd5KVpAJlgRSm3TGXAiN89rBvMt5vi556AyG1ymzUBrcNOmKmT5I0JX8WOMAKXRqQJgnJ1qo57J2Cr6XyEyutYCxIlsOpAl9GnDq8UWkQGmi0YnnWLcRan6tugsM2spytheVlSIkidcTCJmEfs9efNzSgJ5APacpiRSklkPRCKpucrcJriu8Y2DWa25Rht9tTpDKIaIZmwJXCTuaHhKvwLfL0oI6(P2JhaOkvJXKiQr5sji0RmOGuxZru3p1E8aavPAmMNhsgujDXj0PEvKMs9wYjHLvst(EXzgRXyUwkGWdYkRYIs6dUYuXzgRXyUwkGWdYkRYIsA3b3hP8RduLiQrDIYqY02bxzAJmEfs9fUucc9kdki11Ce19tThpaqvQgJ55HwkPloHo1RI0uQ3sojSSsAY3loloFkICs8KijCLsDrMKtGYISgiKiRhKiZyDaIC4ezwohqEfsnXzgRXyouUucc9WbxsCMXAmMtwus3j5tfWJWfbwCMXAmMtwusJzi0ZyngZddNkHXiekEijIAumwd5KNmcjiNmjvCMXAmMtwusNEWMoiExyfvqgeAzjIAuAGqYK07eNzSgJ5KfL0ygc9mwJX8WWPsymcHQZGsfqgq(uaLkruJcpYjJnTjNm9OmyrF0wGKswpScpMv2PGj9G89rBAGlfwXc8mW(iL1CviiJ57mOubKbudqiCyULUSiH(OT0d20bX7cROcYGql3aechMtMlOrFIYqY0w6bB6G4DHvubzqOLBKXRqQNO4mJ1ymNSOKgZqONXAmMhgovcJriuDguQaYaYNcOujIAu4rozSPnlkouFntl6J2Ctf0dgTPbUuyflWZa7JuwZvHGmMVZGsfqgqnaHWH5w6YIe6J2spytheVlSIkidcTCdqiCyozUGg9jkdjtBPhSPdI3fwrfKbHwUrgVcPEIIZmwJXCYIsAmdHEgRXyEy4ujmgHq1zqPcidiFkGsLiQrLaEKtgBAZimyGdOJgnEKtgBARuzqWgA04rozSPnBmkXf9rBPhSPdI3fwrfKbHwUPbUuyfl6J2spytheVlSIkidcTCdqiCyULUioZyngZjlkP5IXklruJQpAJlgRCdqiCyULUxCMXAmMtwusZfJvwcCzmK8kdki1HkzjIAujWynKtEYiKGCYKCIlsOpAJlgRCdqiCyULUprXzgRXyozrj9bxzQ4mJ1ymNSOKgZqONXAmMhgovcJriuDguQaYaYNcOujIAumwd5KNmcjiNmxwGh5KXM2KtMEugSib8mW(iL1cKuY6Hv4XSYofmPhudqCVmA09rBbskz9Wk8ywzNcM0dY3hTPbUuyfjUiH(OT0d20bX7cROcYGql30axkSc0OprzizAl9GnDq8UWkQGmi0YnY4vi1tuCMXAmMtwusJzi0ZyngZddNkHXieQodkvaza5tbuQernkgRHCYtgHeKtMllsapYjJnTzegmWb0rJgpYjJnTvQmiydnA8iNm20MngL4Ie6J2spytheVlSIkidcTCtdCPWkqJ(eLHKPT0d20bX7cROcYGql3iJxHuprXzgRXyozrjnMHqpJ1ympmCQegJqO6mOubKbKpfqPse1OySgYjpzesqozUSapYjJnTzrXH6RzArc4zG9rkR5MkOhmAdqCVmA09rBUPc6bJ20axkSIexKqF0w6bB6G4DHvubzqOLBAGlfwbA0NOmKmTLEWMoiExyfvqgeA5gz8kK6jkoZyngZjlkPDe19tThpaqvQgJjruJIXAiN8Krib5K5YcLHKPn3iLxpiVJOURrgVcP(It6J2Ce19tThpaqvQgJ10axkSIfNeMVggfhQ4mJ1ymNSOK2ru3p1E8aavPAmMernkgRHCYtgHeKtMllugsM2Cr6XyEyutnY4vi1xCsF0MJOUFQ94baQs1ySMg4sHvS4KW81WO4qx0hTHhaOkvJXAacHdZT09IZmwJXCYIsA5bK8khMkruJkb3ub9Udg0Ljz0OzSgYjpzesqozUK4c8mW(iL1CviiJ57mOubKbudqiCyozs(I4mJ1ymNSOKUYCkVcjpxxddSgJjruJQpARYCkVcjpxxddSgJ1aechMBP7fNzSgJ5KfL0Ui9ympmQjjIAu9rBUi9ympmQPgGq4WClDV4mJ1ymNSOK2fPhJ5HrnjbUmgsELbfK6qLSernQeySgYjpzesqozsoXfj0hT5I0JX8WOMAacHdZT09jkoZyngZjlkPXme6zSgJ5HHtLWyecfEKtgBQernQtWJCYytBgHbdCaDXzgRXyozrjnEaGQungtIOgfJ1qo5jJqcYT09jzckdjtBUrkVEqEhrDxJmEfsD0OvgsM2Cr6XyEyutnY4vi1tCrF0gEaGQungRbieom3sxeNzSgJ5KfL04baQs1ymjWLXqYRmOGuhQKLiQrLaJ1qo5jJqcYT09jzckdjtBUrkVEqEhrDxJmEfsD0OvgsM2Cr6XyEyutnY4vi1tmXfj0hTHhaOkvJXAacHdZT0LefNzSgJ5KfL0PhSPdI3fwrfKbHwwIOgfEKtgBAZimyGdOJgnEKtgBAZIId1xZeA04rozSPTsLbbBOrJh5KXM2SXiXzgRXyozrjncdP6a7bCQwbijIAuUPc6DhmOlZ9IZmwJXCYIsAmdHEgRXyEy4ujmgHq1zqPcidiFkGsLiQrHh5KXM2KtMEugSib8mW(iL1cKuY6Hv4XSYofmPhudqCVmA09rBbskz9Wk8ywzNcM0dY3hTPbUuyfjUapdSpsznxfcYy(odkvaza1aechMBPllsOpAl9GnDq8UWkQGmi0YnaHWH5K5cA0NOmKmTLEWMoiExyfvqgeA5gz8kK6jkoZyngZjlkPXme6zSgJ5HHtLWyecvNbLkGmG8PakvIOgvc4rozSPnJWGboGoA04rozSPTsLbbBOrJh5KXM2SXOexGNb2hPSMRcbzmFNbLkGmGAacHdZT0Lfj0hTLEWMoiExyfvqgeA5gGq4WCYCbn6tugsM2spytheVlSIkidcTCJmEfs9efNzSgJ5KfL0ygc9mwJX8WWPsymcHQZGsfqgq(uaLkruJcpYjJnTzrXH6RzArc4zG9rkR5MkOhmAdqCVmA09rBUPc6bJ20axkSIexGNb2hPSMRcbzmFNbLkGmGAacHdZT0Lfj0hTLEWMoiExyfvqgeA5gGq4WCYCbn6tugsM2spytheVlSIkidcTCJmEfs9efNzSgJ5KfL0DguY7MkOernk8mW(iL1CviiJ57mOubKbudqiCyoz0aH8647bjoZyngZjlkPXme6zSgJ5HHtLWyecvOeI4mJ1ymNSOKgZqONXAmMhgovcJriuosIOgvNwRQRBUdUps5jKvaJPMtzCPLs4ssYyngR5o4(iLFDGAlmFnmko0erJUtRv11n3b3hP8eYkGXudqiCyULsQ4mJ1ymNSOKgHHuDG9aovRaKernQ(OTajLSEyfEmRStbt6b57J20axkScXzgRXyozrjncdP6a7bCQwbijIAu9rBUPc6bJ20axkScXzgRXyozrjncdP6a7bCQwbijIAukdjtBPhSPdI3fwrfKbHwUrgVcP(Ie6J2spytheVlSIkidcTCtdCPWkqJ2nvqV7GbDzskA0AGqED89GwcpdSpszT0d20bX7cROcYGql3aechMlrXzgRXyozrjncdP6a7bCQwbijIAukdjtBUrkVEqEhrDxJmEfsDXzgRXyozrjDhWH5HrnjruJATQUUfgjpuEfs(oHeoQ5ugxsM7Vdn61Q66wyK8q5vi57es4Owv6cnqiVo(EqlDV4mJ1ymNSOKgZqONXAmMhgovcJriu4rozSPIZmwJXCYIsAUySYse1OaunGCh8kKeNzSgJ5KfL0CXyLLaxgdjVYGcsDOswIOgvcmwd5KNmcjiNmjN4IeaunGCh8kKsuCMXAmMtwusJhaOkvJXKiQrbOAa5o4viTGXAiN8Krib5w6(KmbLHKPn3iLxpiVJOURrgVcPoA0kdjtBUi9ympmQPgz8kK6jkoZyngZjlkPRmNYRqYZ11WaRXyse1OaunGCh8kKeNzSgJ5KfL0Ui9ympmQjjIAuaQgqUdEfsIZmwJXCYIsAxKEmMhg1Ke4Yyi5vguqQdvYse1OsGXAiN8Krib5Kj5exKaGQbK7GxHuIIZmwJXCYIsA8aavPAmMe4Yyi5vguqQdvYse1OsGXAiN8Krib5w6(KmbLHKPn3iLxpiVJOURrgVcPoA0kdjtBUi9ympmQPgz8kK6jM4IeaunGCh8kKsuCMXAmMtwus3bCyE3ubLimLaGQufvYIZmwJXCYIsA3b3hP8RdufNfNzSgJ5A8qOspytheVlSIkidcTS4mJ1ymxJhswusFWvMkoZyngZ14HKfL0ygc9mwJX8WWPsymcHQZGsfqgq(uaLkruJcpYjJnTjNm9OmyrF0wGKswpScpMv2PGj9G89rBAGlfwXc8mW(iL1CviiJ57mOubKbudqiCyULUSiH(OT0d20bX7cROcYGql3aechMtMlOrFIYqY0w6bB6G4DHvubzqOLBKXRqQNO4mJ1ymxJhswusJzi0ZyngZddNkHXieQodkvaza5tbuQernk8iNm20MffhQVMPf9rBUPc6bJ20axkSIf4zG9rkR5QqqgZ3zqPcidOgGq4WClDzrc9rBPhSPdI3fwrfKbHwUbieomNmxqJ(eLHKPT0d20bX7cROcYGql3iJxHuprXzgRXyUgpKSOKgZqONXAmMhgovcJriuDguQaYaYNcOujIAujGh5KXM2mcdg4a6OrJh5KXM2kvgeSHgnEKtgBAZgJsCrF0w6bB6G4DHvubzqOLBAGlfwXI(OT0d20bX7cROcYGql3aechMBPlIZmwJXCnEizrjTJOUFQ94baQs1ymjIAukdjtBUrkVEqEhrDxJmEfs9fy28oI6IZmwJXCnEizrjTJOUFQ94baQs1ymjIAuNOmKmT5gP86b5De1DnY4vi1xCsF0MJOUFQ94baQs1ySMg4sHvS4KW81WO4qx0hTHhaOkvJXAaQgqUdEfsIZmwJXCnEizrjnxmwzjWLXqYRmOGuhQKLiQrXynKt((OnUySYlDV4mJ1ymxJhswusZfJvwcCzmK8kdki1HkzjIAumwd5KVpAJlgRSmOUFbGQbK7GxH0I(OnUySYnnWLcRqCMXAmMRXdjlkPRmNYRqYZ11WaRXyse1OySgYjFF0wL5uEfsEUUggyngd1DOrRbUuyflaunGCh8kKeNzSgJ5A8qYIs6kZP8kK8CDnmWAmMe4Yyi5vguqQdvYse1OordCPWkwKkpvzizAdWiPSPEUUggyngZ1iJxHuFbJ1qo57J2QmNYRqYZ11WaRXylLuXzgRXyUgpKSOKwEajVYHPse1OCtf07oyqxMKfNzSgJ5A8qYIsAmdHEgRXyEy4ujmgHqHh5KXMkruJ6e8iNm20MryWahqxCMXAmMRXdjlkPXme6zSgJ5HHtLWyecvNbLkGmG8PakvIOgfEKtgBAtoz6rzWIeWZa7JuwlqsjRhwHhZk7uWKEqnaX9YOr3hTfiPK1dRWJzLDkyspiFF0Mg4sHvK4c8mW(iL1CviiJ57mOubKbudqiCyULUSiH(OT0d20bX7cROcYGql3aechMtMlOrFIYqY0w6bB6G4DHvubzqOLBKXRqQNO4mJ1ymxJhswusJzi0ZyngZddNkHXieQodkvaza5tbuQernQeWJCYytBgHbdCaD0OXJCYytBLkdc2qJgpYjJnTzJrjUapdSpsznxfcYy(odkvaza1aechMBPllsOpAl9GnDq8UWkQGmi0YnaHWH5K5cA0NOmKmTLEWMoiExyfvqgeA5gz8kK6jkoZyngZ14HKfL0ygc9mwJX8WWPsymcHQZGsfqgq(uaLkruJcpYjJnTzrXH6RzArc4zG9rkR5MkOhmAdqCVmA09rBUPc6bJ20axkSIexGNb2hPSMRcbzmFNbLkGmGAacHdZT0Lfj0hTLEWMoiExyfvqgeA5gGq4WCYCbn6tugsM2spytheVlSIkidcTCJmEfs9efNzSgJ5A8qYIs6odk5DtfuIOgfEgyFKYAUkeKX8DguQaYaQbieomNmAGqED89GeNzSgJ5A8qYIsAmdHEgRXyEy4ujmgHqfkHioZyngZ14HKfL0imKQdShWPAfGKiQr1hTjpGKx5W0Mg4sHvioZyngZ14HKfL0imKQdShWPAfGKiQr1hT5MkOhmAtdCPWkwCIYqY0MBKYRhK3ru31iJxHuxCMXAmMRXdjlkPryivhypGt1kajruJ6eLHKPn5bK8khM2iJxHuxCMXAmMRXdjlkPryivhypGt1kajruJYnvqV7GbDzUxCMXAmMRXdjlkPDr6XyEyutsGlJHKxzqbPoujlruJkbgRHCY3hT5I0JX8WOMwcvstCrcN0hT5I0JX8WOMAAGlfwrIIZmwJXCnEizrjDhWH5HrnjruJATQUUfgjpuEfs(oHeoQ5ugxsgul)o0OxRQRBHrYdLxHKVtiHJAvPl0aH8647bT0YfNzSgJ5A8qYIs6oGdZ7MkO4mJ1ymxJhswusJzi0ZyngZddNkHXiek8iNm2uXzgRXyUgpKSOKUd4W8WOMKiQrTwvx3cJKhkVcjFNqch1CkJljdQLFhA0Rv11TWi5HYRqY3jKWrTQ0fAGqED89GwA5OrVwvx3cJKhkVcjFNqch1CkJljdQKU8f9rBUPc6bJ20axkScXzgRXyUgpKSOKUd4W8UPckrykbavPkQKfNzSgJ5A8qYIsA3b3hP8RdufNfNzSgJ5A4rozSPOcKuY6Hv4XSYofmPhKernk8mW(iL1CviiJ57mOubKbudqiCyULs(o0OXZa7JuwZvHGmMVZGsfqgqnaHWH5Kz53joZyngZ1WJCYytLfL0DchiSgwHFDGQernk8mW(iL1CviiJ57mOubKbudqiCyozw(Ie60AvDD7GRmTbieomNm3Jg9jkdjtBhCLPnY4vi1tuCMXAmMRHh5KXMklkPDtf0dgvIOgfEgyFKYAUkeKX8DguQaYaQbieom3slhnA8mW(iL1CviiJ57mOubKbudqiCyozw(DOrJNb2hPSMRcbzmFNbLkGmGAacHdZjZLLVapwVk0gEaGQunScpKiqJmEfsDXzgRXyUgEKtgBQSOK2HNkqyfEn0dsCMXAmMRHh5KXMklkPLAaWUCkmpGCJXgMeNzSgJ5A4rozSPYIsAeczaL9tThwHJUVdigXjoZyngZ1WJCYytLfL0RWz6(P2RhKNmcPS4mJ1ymxdpYjJnvwusxuXGEWMFQ98YMaJEioZyngZ1WJCYytLfL0Ginfs(W8UugtIZmwJXCn8iNm2uzrjD9GRCu3ZlBcek5xjgrCMXAmMRHh5KXMklkPtRarD5Wk8Rq2PIZmwJXCn8iNm2uzrjnG40Wk81qgHCse1OuguqA7GyOE4tXQmN(DOrRmOG02bXq9WNI1LUChA0kdkiTPbc51XNIv)L7K5(7qJUokoupGq4WClD5oXzgRXyUgEKtgBQSOKgpgMmfWk191qgHeNzSgJ5A4rozSPYIsA9G8v26uzDF9aWKernQ1Q66gGWLGKZ5RhaMAacHdZjoZyngZ1WJCYytLfL0o8ubcRWRHEqIZmwJXCn8iNm2uzrjDGKswpScpMv2PGj9GeNzSgJ5A4rozSPYIsA3ub9GrLiQrLWAvDDlmsEO8kK8DcjCuZPmUKmj90rJMXAiN8Krib5Kj5efNzSgJ5A4rozSPYIs6oHdewdRWVoqvIOgvckdkiTDqmup8PyDPLFhA01rXH6bechMtMLFxIIZIZmwJXCTodkvaza5tbukk5bK8khMkruJcpdSpsznxfcYy(odkvaza1aechMBPlIZmwJXCTodkvaza5tbuQSOKUZGsE3ubfNzSgJ5ADguQaYaYNcOuzrjD6OXyIZmwJXCTodkvaza5tbuQSOKUoa0kCMU4mJ1ymxRZGsfqgq(uaLklkPxHZ091vGYIZmwJXCTodkvaza5tbuQSOKELaocukScXzgRXyUwNbLkGmG8PakvwusJzi0ZyngZddNkHXiek8iNm2ujIAuNGh5KXM2mcdg4a6lWZa7JuwZvHGmMVZGsfqgqnaHWH5w6I4mJ1ymxRZGsfqgq(uaLklkPDviiJ57mOubKbKernkgRHCY3hTjpGKx5WuzUdnAgRHCY3hTLEWMoiExyfvqgeAzzUdnALHKPn3iLxpiVJOURrgVcPoA0jCIYqY0M8asELdtBKXRqQV4eLHKPT0d20bX7cROcYGql3iJxHuprXzXzgRXyUwOecQkh5dLqCIZIZmwJXCnhH6GRmvCMXAmMR5izrjDhWH5DtfuIWucaQsvFbCwziQKLimLaGQu1h1O60AvDDZDW9rkpHScym1CkJljdQKkoZyngZ1CKSOK2DW9rk)6a1FlNaUyS)6L7UCxYjN8LFlfdSWkC)(uns6auQlYldrMXAmMiddN6AIZ)ggo193(nEKtgB6F7VM8F73KXRqQ)s(Bmiuce8VXZa7JuwZvHGmMVZGsfqgqnaHWH5e5Le5KVtKrJwKXZa7JuwZvHGmMVZGsfqgqnaHWH5ezze5LF3VzSgJ97ajLSEyfEmRStbt6b96F9YF73KXRqQ)s(Bmiuce8VXZa7JuwZvHGmMVZGsfqgqnaHWH5ezze5LlYle5ee5oTwvx3o4ktBacHdZjYYiY3lYOrlYNiYkdjtBhCLPnY4vi1f5e)nJ1ySF3jCGWAyf(1bQV(xt6F73KXRqQ)s(Bmiuce8VXZa7JuwZvHGmMVZGsfqgqnaHWH5e5Le5LlYOrlY4zG9rkR5QqqgZ3zqPcidOgGq4WCISmI8YVtKrJwKXZa7JuwZvHGmMVZGsfqgqnaHWH5ezze5llxKxiY4X6vH2WdauLQHv4HebAKXRqQ)BgRXy)2nvqpy0x)R3)3(nJ1ySF7WtfiScVg6b9BY4vi1FjF9VU8)2VzSgJ9BPgaSlNcZdi3ySHPFtgVcP(l5R)1KWF73mwJX(ncHmGY(P2dRWr33beJ4(nz8kK6VKV(xxg)TFZyng73RWz6(P2RhKNmcP8VjJxHu)L81)6P)3(nJ1ySFxuXGEWMFQ98YMaJE8BY4vi1FjF9VUS(B)MXAm2VbrAkK8H5DPmM(nz8kK6VKV(xt(U)2VzSgJ976bx5OUNx2eiuYVsmYVjJxHu)L81)AYj)3(nJ1ySFNwbI6YHv4xHSt)nz8kK6VKV(xt(YF73KXRqQ)s(Bmiuce8VvguqA7GyOE4tXQilJiF63jYOrlYkdkiTDqmup8PyvKxsKVCNiJgTiRmOG0MgiKxhFkw9xUtKLrKV)orgnArUokoupGq4WCI8sI8L7(nJ1ySFdionScFnKri3R)1Kt6F73mwJX(nEmmzkGvQ7RHmc9BY4vi1FjF9VM89)TFtgVcP(l5VXGqjqW)ETQUUbiCji5C(6bGPgGq4WC)MXAm2V1dYxzRtL191datV(xtE5)TFZyng73o8ubcRWRHEq)MmEfs9xYx)RjNe(B)MXAm2VdKuY6Hv4XSYofmPh0VjJxHu)L81)AYlJ)2VjJxHu)L83yqOei4FNGiVwvx3cJKhkVcjFNqch1CkJljYYiYj90fz0OfzgRHCYtgHeKtKLrKtwKt83mwJX(TBQGEWOV(xt(0)B)MmEfs9xYFJbHsGG)DcISYGcsBhed1dFkwf5Le5LFNiJgTixhfhQhqiCyorwgrE53jYj(BgRXy)Ut4aH1Wk8RduF91F3PAUcQ)T)AY)TFZyng73Uucc9Wbx63KXRqQ)s(6F9YF73mwJX(DNKpvapcxe4FtgVcP(l5R)1K(3(nz8kK6VK)gdcLab)BgRHCYtgHeKtKLrKt6VzSgJ9BmdHEgRXyEy40FddN6ngH(np0R)17)B)MmEfs9xYFJbHsGG)TgiKilJiN07(nJ1ySFNEWMoiExyfvqgeA5x)Rl)V9BY4vi1Fj)ngekbc(34rozSPn5KPhLbI8crUpAlqsjRhwHhZk7uWKEq((OnnWLcRqKxiY4zG9rkR5QqqgZ3zqPcidOgGq4WCI8sI8frEHiNGi3hTLEWMoiExyfvqgeA5gGq4WCISmI8frgnAr(erwzizAl9GnDq8UWkQGmi0YnY4vi1f5e)nJ1ySFJzi0ZyngZddN(By4uVXi0V7mOubKbKpfqPV(xtc)TFtgVcP(l5VXGqjqW)gpYjJnTzrXH6RzsKxiY9rBUPc6bJ20axkScrEHiJNb2hPSMRcbzmFNbLkGmGAacHdZjYljYxe5fICcICF0w6bB6G4DHvubzqOLBacHdZjYYiYxez0Of5tezLHKPT0d20bX7cROcYGql3iJxHuxKt83mwJX(nMHqpJ1ympmC6VHHt9gJq)UZGsfqgq(uaL(6FDz83(nz8kK6VK)gdcLab)7eez8iNm20MryWahqxKrJwKXJCYytBLkdc2ez0Ofz8iNm20MngjYjkYle5(OT0d20bX7cROcYGql30axkScrEHi3hTLEWMoiExyfvqgeA5gGq4WCI8sI8LFZyng73ygc9mwJX8WWP)ggo1Bmc97odkvaza5tbu6R)1t)V9BY4vi1Fj)ngekbc(39rBCXyLBacHdZjYljY3)BgRXy)MlgR8R)1L1F73KXRqQ)s(BgRXy)MlgR8VXGqjqW)obrMXAiN8Krib5ezze5Kf5ef5fICcICF0gxmw5gGq4WCI8sI89ICI)gxgdjVYGcsD)1KF9VM8D)TFZyng73hCLP)MmEfs9xYx)RjN8F73KXRqQ)s(Bmiuce8VzSgYjpzesqorwgr(IiVqKXJCYytBYjtpkde5fICcImEgyFKYAbskz9Wk8ywzNcM0dQbiUxwKrJwK7J2cKuY6Hv4XSYofmPhKVpAtdCPWke5ef5fICcICF0w6bB6G4DHvubzqOLBAGlfwHiJgTiFIiRmKmTLEWMoiExyfvqgeA5gz8kK6ICI)MXAm2VXme6zSgJ5HHt)nmCQ3ye63DguQaYaYNcO0x)RjF5V9BY4vi1Fj)ngekbc(3mwd5KNmcjiNilJiFrKxiYjiY4rozSPnJWGboGUiJgTiJh5KXM2kvgeSjYOrlY4rozSPnBmsKtuKxiYjiY9rBPhSPdI3fwrfKbHwUPbUuyfImA0I8jISYqY0w6bB6G4DHvubzqOLBKXRqQlYj(BgRXy)gZqONXAmMhgo93WWPEJrOF3zqPcidiFkGsF9VMCs)B)MmEfs9xYFJbHsGG)nJ1qo5jJqcYjYYiYxe5fImEKtgBAZIId1xZKiVqKtqKXZa7JuwZnvqpy0gG4EzrgnArUpAZnvqpy0Mg4sHviYjkYle5ee5(OT0d20bX7cROcYGql30axkScrgnAr(erwzizAl9GnDq8UWkQGmi0YnY4vi1f5e)nJ1ySFJzi0ZyngZddN(By4uVXi0V7mOubKbKpfqPV(xt(()2VjJxHu)L83yqOei4FZynKtEYiKGCISmI8frEHiRmKmT5gP86b5De1DnY4vi1f5fI8jICF0MJOUFQ94baQs1ySMg4sHviYle5te5W81WO4q)nJ1ySF7iQ7NApEaGQung71)AYl)V9BY4vi1Fj)ngekbc(3mwd5KNmcjiNilJiFrKxiYkdjtBUi9ympmQPgz8kK6I8cr(erUpAZru3p1E8aavPAmwtdCPWke5fI8jICy(AyuCOI8crUpAdpaqvQgJ1aechMtKxsKV)3mwJX(TJOUFQ94baQs1ySx)RjNe(B)MmEfs9xYFJbHsGG)DcISBQGE3bd6ISmICYImA0ImJ1qo5jJqcYjYYiYxe5ef5fImEgyFKYAUkeKX8DguQaYaQbieomNilJiN8LFZyng73Ydi5vom91)AYlJ)2VjJxHu)L83yqOei4F3hTvzoLxHKNRRHbwJXAacHdZjYljY3)BgRXy)UYCkVcjpxxddSgJ96Fn5t)V9BY4vi1Fj)ngekbc(39rBUi9ympmQPgGq4WCI8sI89)MXAm2VDr6XyEyutV(xtEz93(nz8kK6VK)MXAm2VDr6XyEyut)gdcLab)7eezgRHCYtgHeKtKLrKtwKtuKxiYjiY9rBUi9ympmQPgGq4WCI8sI89ICI)gxgdjVYGcsD)1KF9VE5U)2VjJxHu)L83yqOei4FFIiJh5KXM2mcdg4a6)MXAm2VXme6zSgJ5HHt)nmCQ3ye634rozSPV(xVK8F73KXRqQ)s(Bmiuce8VzSgYjpzesqorEjr(Erojf5eezLHKPn3iLxpiVJOURrgVcPUiJgTiRmKmT5I0JX8WOMAKXRqQlYjkYle5(On8aavPAmwdqiCyorEjr(YVzSgJ9B8aavPAm2R)1lx(B)MmEfs9xYFZyng734baQs1ySFJbHsGG)DcImJ1qo5jJqcYjYljY3lYjPiNGiRmKmT5gP86b5De1DnY4vi1fz0OfzLHKPnxKEmMhg1uJmEfsDrorrorrEHiNGi3hTHhaOkvJXAacHdZjYljYxe5e)nUmgsELbfK6(Rj)6F9ss)B)MmEfs9xYFJbHsGG)nEKtgBAZimyGdOlYOrlY4rozSPnlkouFntImA0ImEKtgBARuzqWMiJgTiJh5KXM2SXOFZyng73PhSPdI3fwrfKbHw(1)6L7)B)MmEfs9xYFJbHsGG)TBQGE3bd6ISmI89)MXAm2VryivhypGt1ka96F9YY)B)MmEfs9xYFJbHsGG)nEKtgBAtoz6rzGiVqKtqKXZa7JuwlqsjRhwHhZk7uWKEqnaX9YImA0ICF0wGKswpScpMv2PGj9G89rBAGlfwHiNOiVqKXZa7JuwZvHGmMVZGsfqgqnaHWH5e5Le5lI8crobrUpAl9GnDq8UWkQGmi0YnaHWH5ezze5lImA0I8jISYqY0w6bB6G4DHvubzqOLBKXRqQlYj(BgRXy)gZqONXAmMhgo93WWPEJrOF3zqPcidiFkGsF9VEjj83(nz8kK6VK)gdcLab)7eez8iNm20MryWahqxKrJwKXJCYytBLkdc2ez0Ofz8iNm20MngjYjkYlez8mW(iL1CviiJ57mOubKbudqiCyorEjr(IiVqKtqK7J2spytheVlSIkidcTCdqiCyorwgr(IiJgTiFIiRmKmTLEWMoiExyfvqgeA5gz8kK6ICI)MXAm2VXme6zSgJ5HHt)nmCQ3ye63DguQaYaYNcO0x)Rxwg)TFtgVcP(l5VXGqjqW)gpYjJnTzrXH6RzsKxiYjiY4zG9rkR5MkOhmAdqCVSiJgTi3hT5MkOhmAtdCPWke5ef5fImEgyFKYAUkeKX8DguQaYaQbieomNiVKiFrKxiYjiY9rBPhSPdI3fwrfKbHwUbieomNilJiFrKrJwKprKvgsM2spytheVlSIkidcTCJmEfsDroXFZyng73ygc9mwJX8WWP)ggo1Bmc97odkvaza5tbu6R)1lN(F73KXRqQ)s(Bmiuce8VXZa7JuwZvHGmMVZGsfqgqnaHWH5ezzeznqiVo(Eq)MXAm2V7mOK3nvWx)Rxww)TFtgVcP(l5VzSgJ9BmdHEgRXyEy40FddN6ngH(DOeYR)1KE3F73KXRqQ)s(Bmiuce8V70AvDDZDW9rkpHScym1CkJljYljYjiYxe5KuKzSgJ1ChCFKYVoqTfMVggfhQiNOiJgTi3P1Q66M7G7JuEczfWyQbieomNiVKiN0FZyng73ygc9mwJX8WWP)ggo1Bmc9Bh96FnPj)3(nz8kK6VK)gdcLab)7(OTajLSEyfEmRStbt6b57J20axkSIFZyng73imKQdShWPAfGE9VM0l)TFtgVcP(l5VXGqjqW)UpAZnvqpy0Mg4sHv8BgRXy)gHHuDG9aovRa0R)1KM0)2VjJxHu)L83yqOei4FRmKmTLEWMoiExyfvqgeA5gz8kK6I8crobrUpAl9GnDq8UWkQGmi0YnnWLcRqKrJwKDtf07oyqxKLrKtQiJgTiRbc51X3dsKxsKXZa7Juwl9GnDq8UWkQGmi0YnaHWH5e5e)nJ1ySFJWqQoWEaNQva61)AsV)V9BY4vi1Fj)ngekbc(3kdjtBUrkVEqEhrDxJmEfs9FZyng73imKQdShWPAfGE9VM0L)3(nz8kK6VK)gdcLab)71Q66wyK8q5vi57es4OMtzCjrwgr((7ez0Of51Q66wyK8q5vi57es4OwvQiVqK1aH8647bjYljY3)BgRXy)Ud4W8WOME9VM0KWF73KXRqQ)s(BgRXy)gZqONXAmMhgo93WWPEJrOFJh5KXM(6FnPlJ)2VjJxHu)L83yqOei4FdOAa5o4vi9BgRXy)MlgR8R)1KE6)TFtgVcP(l5VzSgJ9BUySY)gdcLab)7eezgRHCYtgHeKtKLrKtwKtuKxiYjiYaQgqUdEfsICI)gxgdjVYGcsD)1KF9VM0L1F73KXRqQ)s(Bmiuce8VbunGCh8kKe5fImJ1qo5jJqcYjYljY3lYjPiNGiRmKmT5gP86b5De1DnY4vi1fz0OfzLHKPnxKEmMhg1uJmEfsDroXFZyng734baQs1ySx)R3F3F73KXRqQ)s(Bmiuce8VbunGCh8kK(nJ1ySFxzoLxHKNRRHbwJXE9VEFY)TFtgVcP(l5VXGqjqW)gq1aYDWRq63mwJX(TlspgZdJA61)69x(B)MmEfs9xYFZyng73Ui9ympmQPFJbHsGG)DcImJ1qo5jJqcYjYYiYjlYjkYle5eezavdi3bVcjroXFJlJHKxzqbPU)AYV(xVpP)TFtgVcP(l5VzSgJ9B8aavPAm2VXGqjqW)obrMXAiN8Krib5e5Le57f5KuKtqKvgsM2CJuE9G8oI6Ugz8kK6ImA0ISYqY0MlspgZdJAQrgVcPUiNOiNOiVqKtqKbunGCh8kKe5e)nUmgsELbfK6(Rj)6F9(7)B)omLaGQu93j)BgRXy)Ud4W8UPc(BY4vi1FjF9VE)Y)B)MXAm2VDhCFKYVoq93KXRqQ)s(6R)ofq4bzL1)2Fn5)2VjJxHu)L83yqOei4FRbcjYYiY3jYle5te5usBmmKtI8cr(erETQUUvacKjaKFQ9ogdI6atTQ0FZyng731e03hKWyng71)6L)2VzSgJ9BxfcYy(AcEuzkb(nz8kK6VKV(xt6F73KXRqQ)s(Bmiuce8VvgsM2kabYeaYp1EhJbrDGPgz8kK6)MXAm2VlabYeaYp1EhJbrDGPx)R3)3(nz8kK6VK)Es)TJ0FZyng73YzqWRq63Yzyf9BgRHCY3hTHhaOkvJXezze57e5fImJ1qo57J24IXklYYiY3jYlezgRHCY3hTvzoLxHKNRRHbwJXezze57e5fICcI8jISYqY0MlspgZdJAQrgVcPUiJgTiZynKt((OnxKEmMhg1KilJiFNiNOiVqKtqK7J2spytheVlSIkidcTCtdCPWkez0Of5tezLHKPT0d20bX7cROcYGql3iJxHuxKt83YzG3ye639rDEaX9YV(xx(F73KXRqQ)s(BJrOFZlB3bdyNVEm1p1(0rkc8BgRXy)Mx2UdgWoF9yQFQ9PJue41)As4V9BY4vi1Fj)ngekbc(3Uucc9kdki11Ce19tThpaqvQgJ55HezzqjYjvKxiYNiY0PEvKMs9gVSDhmGD(6Xu)u7thPiWVzSgJ9BhrD)u7XdauLQXyV(xxg)TFZyng73hCLP)MmEfs9xYx)RN(F73KXRqQ)s(Bmiuce8VprKvgsM2o4ktBKXRqQlYlezxkbHELbfK6AoI6(P2JhaOkvJX88qI8sICsf5fI8jImDQxfPPuVXlB3bdyNVEm1p1(0rkc8BgRXy)2DW9rk)6a1xF938q)T)AY)TFZyng73PhSPdI3fwrfKbHw(3KXRqQ)s(6F9YF73mwJX(9bxz6VjJxHu)L81)As)B)MmEfs9xYFJbHsGG)nEKtgBAtoz6rzGiVqK7J2cKuY6Hv4XSYofmPhKVpAtdCPWke5fImEgyFKYAUkeKX8DguQaYaQbieomNiVKiFrKxiYjiY9rBPhSPdI3fwrfKbHwUbieomNilJiFrKrJwKprKvgsM2spytheVlSIkidcTCJmEfsDroXFZyng73ygc9mwJX8WWP)ggo1Bmc97odkvaza5tbu6R)17)B)MmEfs9xYFJbHsGG)nEKtgBAZIId1xZKiVqK7J2Ctf0dgTPbUuyfI8crgpdSpsznxfcYy(odkvaza1aechMtKxsKViYle5ee5(OT0d20bX7cROcYGql3aechMtKLrKViYOrlYNiYkdjtBPhSPdI3fwrfKbHwUrgVcPUiN4VzSgJ9BmdHEgRXyEy40FddN6ngH(DNbLkGmG8Pak91)6Y)B)MmEfs9xYFJbHsGG)DcImEKtgBAZimyGdOlYOrlY4rozSPTsLbbBImA0ImEKtgBAZgJe5ef5fICF0w6bB6G4DHvubzqOLBAGlfwHiVqK7J2spytheVlSIkidcTCdqiCyorEjr(YVzSgJ9BmdHEgRXyEy40FddN6ngH(DNbLkGmG8Pak91)As4V9BY4vi1Fj)ngekbc(3kdjtBUrkVEqEhrDxJmEfsDrEHiJzZ7iQ)BgRXy)2ru3p1E8aavPAm2R)1LXF73KXRqQ)s(Bmiuce8VprKvgsM2CJuE9G8oI6Ugz8kK6I8cr(erUpAZru3p1E8aavPAmwtdCPWke5fI8jICy(AyuCOI8crUpAdpaqvQgJ1aunGCh8kK(nJ1ySF7iQ7NApEaGQung71)6P)3(nz8kK6VK)MXAm2V5IXk)Bmiuce8VzSgYjFF0gxmwzrEjr((FJlJHKxzqbPU)AYV(xxw)TFtgVcP(l5VzSgJ9BUySY)gdcLab)BgRHCY3hTXfJvwKLbLiFViVqKbunGCh8kKe5fICF0gxmw5Mg4sHv8BCzmK8kdki19xt(1)AY393(nz8kK6VK)gdcLab)BgRHCY3hTvzoLxHKNRRHbwJXezuI8DImA0ISg4sHviYlezavdi3bVcPFZyng73vMt5vi556AyG1ySx)RjN8F73KXRqQ)s(BgRXy)UYCkVcjpxxddSgJ9Bmiuce8VprK1axkScrEHiNkpvzizAdWiPSPEUUggyngZ1iJxHuxKxiYmwd5KVpARYCkVcjpxxddSgJjYljYj934Yyi5vguqQ7VM8R)1KV83(nz8kK6VK)gdcLab)B3ub9Udg0fzze5K)nJ1ySFlpGKx5W0x)RjN0)2VjJxHu)L83yqOei4FFIiJh5KXM2mcdg4a6)MXAm2VXme6zSgJ5HHt)nmCQ3ye634rozSPV(xt(()2VjJxHu)L83yqOei4FJh5KXM2KtMEugiYle5eez8mW(iL1cKuY6Hv4XSYofmPhudqCVSiJgTi3hTfiPK1dRWJzLDkyspiFF0Mg4sHviYjkYlez8mW(iL1CviiJ57mOubKbudqiCyorEjr(IiVqKtqK7J2spytheVlSIkidcTCdqiCyorwgr(IiJgTiFIiRmKmTLEWMoiExyfvqgeA5gz8kK6ICI)MXAm2VXme6zSgJ5HHt)nmCQ3ye63DguQaYaYNcO0x)RjV8)2VjJxHu)L83yqOei4FNGiJh5KXM2mcdg4a6ImA0ImEKtgBARuzqWMiJgTiJh5KXM2SXirorrEHiJNb2hPSMRcbzmFNbLkGmGAacHdZjYljYxe5fICcICF0w6bB6G4DHvubzqOLBacHdZjYYiYxez0Of5tezLHKPT0d20bX7cROcYGql3iJxHuxKt83mwJX(nMHqpJ1ympmC6VHHt9gJq)UZGsfqgq(uaL(6Fn5KWF73KXRqQ)s(Bmiuce8VXJCYytBwuCO(AMe5fICcImEgyFKYAUPc6bJ2ae3llYOrlY9rBUPc6bJ20axkScrorrEHiJNb2hPSMRcbzmFNbLkGmGAacHdZjYljYxe5fICcICF0w6bB6G4DHvubzqOLBacHdZjYYiYxez0Of5tezLHKPT0d20bX7cROcYGql3iJxHuxKt83mwJX(nMHqpJ1ympmC6VHHt9gJq)UZGsfqgq(uaL(6Fn5LXF73KXRqQ)s(Bmiuce8VXZa7JuwZvHGmMVZGsfqgqnaHWH5ezzeznqiVo(Eq)MXAm2V7mOK3nvWx)RjF6)TFtgVcP(l5VzSgJ9BmdHEgRXyEy40FddN6ngH(DOeYR)1Kxw)TFtgVcP(l5VXGqjqW)UpAtEajVYHPnnWLcR43mwJX(ncdP6a7bCQwbOx)RxU7V9BY4vi1Fj)ngekbc(39rBUPc6bJ20axkScrEHiFIiRmKmT5gP86b5De1DnY4vi1)nJ1ySFJWqQoWEaNQva61)6LK)B)MmEfs9xYFJbHsGG)9jISYqY0M8asELdtBKXRqQ)BgRXy)gHHuDG9aovRa0R)1lx(B)MmEfs9xYFJbHsGG)TBQGE3bd6ISmI89)MXAm2VryivhypGt1ka96F9ss)B)MmEfs9xYFZyng73Ui9ympmQPFJbHsGG)DcImJ1qo57J2Cr6XyEyutI8sOe5KkYjkYle5ee5te5(OnxKEmMhg1utdCPWke5e)nUmgsELbfK6(Rj)6F9Y9)TFtgVcP(l5VXGqjqW)ETQUUfgjpuEfs(oHeoQ5ugxsKLbLiV87ez0Of51Q66wyK8q5vi57es4OwvQiVqK1aH8647bjYljYl)3mwJX(DhWH5Hrn96F9YY)B)MXAm2V7aomVBQG)MmEfs9xYx)Rxsc)TFtgVcP(l5VzSgJ9BmdHEgRXyEy40FddN6ngH(nEKtgB6R)1llJ)2VjJxHu)L83yqOei4FVwvx3cJKhkVcjFNqch1CkJljYYGsKx(DImA0I8AvDDlmsEO8kK8DcjCuRkvKxiYAGqED89Ge5Le5LlYOrlYRv11TWi5HYRqY3jKWrnNY4sISmOe5KUCrEHi3hT5MkOhmAtdCPWk(nJ1ySF3bCyEyutV(xVC6)TFhMsaqvQ(7K)nJ1ySF3bCyE3ub)nz8kK6VKV(xVSS(B)MXAm2VDhCFKYVoq93KXRqQ)s(6R)2r)T)AY)TFZyng73hCLP)MmEfs9xYx)Rx(B)MmEfs9xYFhMsaqvQ6J6F3P1Q66M7G7JuEczfWyQ5ugxsguj93mwJX(DhWH5Dtf83HPeauLQ(c4SYWFN8R)1K(3(nJ1ySF7o4(iLFDG6VjJxHu)L81x)DOeYF7VM8F73mwJX(DLJ8HsiUFtgVcP(l5RV(7odkvaza5tbu6F7VM8F73KXRqQ)s(Bmiuce8VXZa7JuwZvHGmMVZGsfqgqnaHWH5e5Le5l)MXAm2VLhqYRCy6R)1l)TFZyng73DguY7Mk4VjJxHu)L81)As)B)MXAm2Vthng73KXRqQ)s(6F9()2VzSgJ976aqRWz6)MmEfs9xYx)Rl)V9BgRXy)Efot3xxbk)BY4vi1FjF9VMe(B)MXAm2VxjGJaLcR43KXRqQ)s(6FDz83(nz8kK6VK)gdcLab)7tez8iNm20MryWahqxKxiY4zG9rkR5QqqgZ3zqPcidOgGq4WCI8sI8LFZyng73ygc9mwJX8WWP)ggo1Bmc9B8iNm20x)RN(F73KXRqQ)s(Bmiuce8VzSgYjFF0M8asELdtfzze57ez0OfzgRHCY3hTLEWMoiExyfvqgeAzrwgr(orgnArwzizAZns51dY7iQ7AKXRqQlYOrlYjiYNiYkdjtBYdi5vomTrgVcPUiVqKprKvgsM2spytheVlSIkidcTCJmEfsDroXFZyng73UkeKX8DguQaYa61xF93CLEmGFVdKKyV(6)a]] )


end