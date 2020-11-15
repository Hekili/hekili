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

            spend = PTR and function () return buff.fel_domination.up and 0 or 1 end or 1,
            spendType = "soul_shards",

            usable = function () return not pet.alive end,
            handler = function () summonPet( "imp" ) end,
        },


        summon_voidwalker = {
            id = 697,
            cast = 2.5,
            cooldown = 0,
            gcd = "spell",

            spend = PTR and function () return buff.fel_domination.up and 0 or 1 end or 1,
            spendType = "soul_shards",

            usable = function () return not pet.alive end,
            handler = function () summonPet( "voidwalker" ) end,
        },


        summon_felhunter = {
            id = 691,
            cast = function () return ( buff.fel_domination.up and 0.5 or 6 ) * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = PTR and function () return buff.fel_domination.up and 0 or 1 end or 1,
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

            spend = PTR and function () return buff.fel_domination.up and 0 or 1 end or 1,
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


    spec:RegisterPack( "Affliction", 20201112, [[dyuK6aqiPOEeOqBsLYNafeJsqPtjO4vGsZcu1TeezxQYVardtq1XuPAzcsptfX0urY1KI02urkFduGXjfHZjiuRtkI08afDpvv7du5GQivleeEOuevtuqixukIYjbfuTsPWmbfKUPGa2PkQFckOmubb1sfeONkvtvf8vPic7vXFPyWI6WOwms9yetwKldTzK8zvYObPtt1RvHMnWTfy3s(TsdxkDCbbz5eEoLMoPRluBxi(UQsJxkIOZRQy9cIA(cP9t0Z95W0tSIZ5qdp0WVF)(PE3p5(PcTjMU(PfNEltoYx40loaN(PtrbCI6Bn9w(dy50Cy62nwqWPdv1wBtkKqE5k0y6hzdG06bXaw9TicMsH06beiNoDSduy41qp9eR4Co0Wdn873VFQ39tUFQWpz62wKmNd90A60H6Pewd90tOLmDyuMpDkkGtuFlzUjblal5OSbmkZN3iyankK57HcVmhA4HgUSHSbmkZn5q56cTnPYgWOmhsY8PNsysM7TiaiZWqxYXNSbmkZHKmF6PeMK5qegzJfYCiaF5KNSbmkZHKmF6PeMKzAbYhjq5QqGmd2lNiZuRqMdrc2lzUVXGNSbmkZHKmF4lYhL5qagGuorMdb5wnwGYmyVCImRRm)DfhLzNsM)SXWqeOmh4wRxxYmlZkdWsLzVKzfkRYSy)(KnGrzoKK5MSIPbOmhcYbTCPY8PtrbCI6BzL5q4iHWYSYaS0NSbmkZHKmF4lYhTYSUYmhz9Kmtd2VEDjZHiwC8cWcuM9sMdIbQhsklUqvM)c5kZHiyyhSYCC7B6TILYb40Hrz(0POaor9TK5MeSaSKJYgWOmFEJGb0OqMVhk8YCOHhA4YgYgWOm3KdLRl02KkBaJYCijZNEkHjzU3IaGmddDjhFYgWOmhsY8PNsysMdryKnwiZHa8LtEYgWOmhsY8PNsysMPfiFKaLRcbYmyVCImtTczoejyVK5(gdEYgWOmhsY8HViFuMdbyas5ezoeKB1ybkZG9YjYSUY83vCuMDkz(ZgddrGYCGBTEDjZSmRmalvM9sMvOSkZI97t2agL5qsMBYkMgGYCiih0YLkZNoffWjQVLvMdHJeclZkdWsFYgWOmhsY8HViF0kZ6kZCK1tYmny)61LmhIyXXlalqz2lzoigOEiPS4cvz(lKRmhIGHDWkZXTpzdzdMO(w2xRajBanR)uiWK2aVy13cEN6x9aeUWV1ClQpg4rWBnthtr9UeEW6c0SuglteoLtWxCRSbtuFl7RvGKnGMvy)H0gheSLPfvzdMO(w2xRajBanRW(d5LWdwxGMLYyzIWPCccVt9Rmal9Dj8G1fOzPmwMiCkNGpSyAaMKnyI6BzFTcKSb0Sc7pKryHZ0ae(IdW)0QwJa50h4JWGy8NjQhbnPvFKviIBvFl4c)gtupcAsR(4RT(ax43yI6rqtA1xCzvMgGgMIc4e13cUWVf2MvgGL(SEl0TmaNcFyX0amfnktupcAsR(SEl0TmaNcHl8WClSPvFTq5s3aJ1RRyalC9ZtDYrVUIgTzLbyPVwOCPBGX61vmGfU(5HftdWuyKnyI6BzFTcKSb0Sc7pKXw04kgaFXb4phYwOSGTgQTuZszA3VOq2GjQVL91kqYgqZkS)qArmzwkdzfI4w13cEN632IaGrzXfQ2NfXKzPmKviIBvFldViC)NCRzmek2BBX07(PfIp5(PKnyI6BzFTcKSb0Sc7pKq54sLnyI6BzFTcKSb0Sc7pKwOCA)AOxGcVt93SYaS0huoU0hwmnat3STiayuwCHQ9zrmzwkdzfI4w13YWlcZtU1mgcf7TTy6D)0cXNC)uYgYgWOm3K1KejXkMKzmck(iZQhGYScfLzMORqMDRmZryhW0a8jBWe13Y(BBraWawYrzdMO(wwy)HmHr2yHjGVCISbtuFllS)qsyaWWe13YaCRcFXb4pVi8o1ptupcAWcdC0c3jYgmr9TSW(dzluU0nWy96kgWcx)iBWe13Yc7pK81wFG3P(fiLaTqzAakBWe13Yc7pK81wFGN8HaqJYIluT)3H3P(zI6rqdwyGJw4UFtGuc0cLPbOSbtuFllS)qsyaWWe13YaCRcFXb4FIfhVaSanTcSfEN6NjQhbnyHboAHl0BKDbP9B9SXbbBzsS44fGf4tGC6ZTiSWzAa(sRAncKtFKnyI6BzH9hslIjZsziRqe3Q(wW7u)mr9iOblmWrlCHERzLbyPVioank7L(WIPby6wyBwzaw67RWvOOXldFT1NhwmnatrJQmal9z3VgfkASiMSpSyAaMcZTMtR(SiMmlLHScrCR6B9uNC0RRBn7LHc4xq1BPvFKviIBvFRNaPeOfktdqzdMO(wwy)HmIdqJYEPW7u)H1UXaJfklsWDpAuMOEe0Gfg4OfUqdZnYUG0(TE24GGTmjwC8cWc8jWa2llC3dv2GjQVLf2FiTEl0TmaNcH3P(fiLaTqzAakBWe13Yc7pKXLvzAaAykkGtuFl4DQFMOEe0Kw9fxwLPbOHPOaor9T(dpAu1jh966MaPeOfktdqzdMO(wwy)HmUSktdqdtrbCI6BbVt9Ro5Oxx34qgfUIpcBjCYRldHbCGRFEyX0amDJoMI6rylHtEDzimGdC9ZtGbSxwyEISbtuFllS)qswHiUv9TG3P(dltupcAWcdC0cZtIgvzaw6lIdqJYEPpSyAaMIgvzaw67RWvOOXldFT1Nhwmnat3Awzaw6ZUFnku0yrmzFyX0amfMBcKsGwOmnaLnyI6BzH9hsOCCPYgmr9TSW(dzadqkNyeCRglq4DQF7gdmwOSib3PKnyI6BzH9hsR3cDldWPq4jFia0OS4cv7)D4DQFMOEe0Gfg4OfU73sR(SEl0TmaNcFcmG9YcZtKnyI6BzH9hsYkeXTQVf8KpeaAuwCHQ9)o8o1VadyVSW8KBHLjQhbnyHboAH5jrJQmal9fXbOrzV0hwmnatrJQmal99v4ku04LHV26ZdlMgGPBnRmal9z3VgfkASiMSpSyAaMcJSbtuFllS)qsyaWWe13YaCRcFXb4FIfhVaSanTcSfEN6NSliTFRNnoiyltIfhVaSaFcmG9YcZqVfHfotdWxAvRrGC6JSbtuFllS)qMyXrJDJbW7u)KDbP9B9SXbbBzsS44fGf4tGbSxw4upan6AsokBWe13Yc7pKegammr9Tma3QWxCa(t2fK2VLv2GjQVLf2FijmayyI6BzaUvHV4a83vmq2GjQVLf2FijmayyI6BzaUvHV4a83IW7u)amccGRPWGBHnH0XuupluoTFnyaTGj4ZQm5imd7jHetuFRNfkN2Vg6fOpVmua)cQgMOrtiDmf1ZcLt7xdgqlyc(eya7LfMNegzdMO(wwy)HmGbiLtmcUvJfi8o1FA1xehGgL9sFQto61v0OKDbP9B9I4a0OSx6tGbSxw4UhE0O2ngySqzr6VPYgmr9TSW(dzadqkNyeCRglq4DQFLbyPVwOCPBGX61vmGfU(5HftdW0TWMw91cLlDdmwVUIbSW1pp1jh96kAuYUG0(TETq5s3aJ1RRyalC9ZtGbSxw4UhA0O2ngySqzrcUtcJSbtuFllS)qgWaKYjgb3QXceEN6pSnRmal9fXbOrzV0hwmnat3Awzaw6Rfkx6gySEDfdyHRFEyX0amfgzdMO(wwy)HmjyVmaNcH3P(PJPOEEHrCLPbOjHbUfFwLjhH7KWJgLoMI65fgXvMgGMeg4w8f3Et9a0ORj5imBQSbtuFllS)qMeSxgGtHW7u)0XuupVWiUY0a0KWa3IgoKFwLjhH7KWJgLoMI65fgXvMgGMeg4w0WH8lU9M6bOrxtYry2uzdMO(wwy)HmjyVm2ngapbk71)D49srHiUvnEqaMCwX)7W7LIcrCRACQF1jhTW9hQSbtuFllS)qAHYP9RHEbQSHSbtuFl7Jx8Vfkx6gySEDfdyHRFKnyI6BzF8IW(djuoUuzdMO(w2hViS)qArmzwkdzfI4w13cEN6xzaw6ZUFnku0yrmzFyX0amDJWLXIys2GjQVL9Xlc7pKwetMLYqwHiUv9TG3P(Bwzaw6ZUFnku0yrmzFyX0amDR50QplIjZsziRqe3Q(wp1jh966wZEzOa(fu9wA1hzfI4w136jqkbAHY0au2GjQVL9Xlc7pK81wFGN8HaqJYIluT)3H3P(zI6rqtA1hFT1h4(p1nbsjqluMgG3sR(4RT(8uNC0RlzdMO(w2hViS)qYxB9bEYhcanklUq1(FhEN6NjQhbnPvF81wFG5PU1CA1hFT1NN6KJEDjBWe13Y(4fH9hY4YQmnanmffWjQVf8o1ptupcAsR(IlRY0a0WuuaNO(w)HhnQ6KJEDDtGuc0cLPbOSbtuFl7Jxe2FiJlRY0a0WuuaNO(wWt(qaOrzXfQ2)7W7u)nRo5Oxx3AJ0Qmal9j4GwUudtrbCI6BzFyX0amDJjQhbnPvFXLvzAaAykkGtuFlyEISbtuFl7Jxe2FiJ4a0OSxk8o1VDJbgluwKG7USbtuFl7Jxe2FijmayyI6BzaUvHV4a8pXIJxawGMwb2cVt9t2fK2V1ZgheSLjXIJxawGpbYPp3cBA1xluU0nWy96kgWcx)8eya7LfUqJgTzLbyPVwOCPBGX61vmGfU(5HftdWuyKnyI6BzF8IW(dzIfhn2ngaVt9t2fK2V1ZgheSLjXIJxawGpbgWEzHt9a0ORj5OSbtuFl7Jxe2FijmayyI6BzaUvHV4a8NSliTFlRSbtuFl7Jxe2FijmayyI6BzaUvHV4a83vmq2GjQVL9Xlc7pKbmaPCIrWTASaH3P(tR(I4a0OSx6tDYrVUKnyI6BzF8IW(dzadqkNyeCRglq4DQ)MvgGL(I4a0OSx6dlMgGjzdMO(w2hViS)qA9wOBzaofcp5dbGgLfxOA)VdVt9Ze1JGM0QpR3cDldWPqy(FYTMtR(SEl0TmaNcFQto61LSbtuFl7Jxe2Fitc2ldWPq4DQF6ykQNxyexzAaAsyGBXNvzYr4(BA4rJshtr98cJ4ktdqtcdCl(IBVPEaA01KCeMnv2GjQVL9Xlc7pKjb7LXUXazdMO(w2hViS)qAHYP9RHEbQSHSbtuFl7JSliTFl7)3vasrqVmc0Ufxeu2GjQVL9r2fK2VLf2FidWGv8XSugqmXtMKa5aRSbtuFl7JSliTFllS)qsd2nzwkJcfnyHbFKnyI6BzFKDbP9BzH9hYRywKCUmlLHdzuSkuzdMO(w2hzxqA)wwy)Hu4TTa04LX2Yeu2GjQVL9r2fK2VLf2FiPwsSftgoKrHROHg5azdMO(w2hzxqA)wwy)HSnw4uF86YqdyRkBWe13Y(i7cs73Yc7pKcKB96Yqb4a0cVt9RS4c1huKbkutlrHRjcpAuLfxO(GImqHAAjkmdn8OrvwCH6t9a0ORPLOMqdhUtfE0Ou(fu1iWa2llmdnCzdMO(w2hzxqA)wwy)HKSfblvWkMmuaoaLnyI6BzFKDbP9BzH9hsfkAIl6nUsgQvqq4DQF6ykQNajhbO1AOwbbFcmG9YkBWe13Y(i7cs73Yc7pKwYgl86YOUcfLnyI6BzFKDbP9BzH9hspOfRKxxgcRSvfBluu2GjQVL9r2fK2VLf2FiTBmWiwfEN6pS0XuupVWiUY0a0KWa3IpRYKJWDstenktupcAWcdC0c39WiBWe13Y(i7cs73Yc7pKjK4bS61LHEbk8o1FyvwCH6dkYafQPLOWSPHhnkLFbvncmG9YcxtdpmYgYgmr9TSVeloEbybAAfy7FehGgL9sLnyI6BzFjwC8cWc00kWwy)HmXIJg7gdKnyI6BzFjwC8cWc00kWwy)HSDvFlzdMO(w2xIfhVaSanTcSf2FiPCbsd2njBWe13Y(sS44fGfOPvGTW(djny3KHkw8r2GjQVL9LyXXlalqtRaBH9hsAuyrXrVUKnyI6BzFjwC8cWc00kWwy)H0gheSLjXIJxawGW7u)mr9iOjT6lIdqJYEPWfE0Omr9iOjT6Rfkx6gySEDfdyHRFGl8OrvgGL(S7xJcfnwet2hwmnatrJg2MvgGL(I4a0OSx6dlMgGPBnRmal91cLlDdmwVUIbSW1ppSyAaMcJSHSbtuFl7Zvm4p2IgxXaRSHSbtuFl7ZI)q54sLnyI6BzFwe2Fitc2lJDJbW7LIcrCRACQ)eshtr9Sq50(1Gb0cMGpRYKJW9FISbtuFl7ZIW(dPfkN2Vg6fOtpckS(wZ5qdp0WVFp8M4f60)YIYRl70HHh0UcftYmmqMzI6BjZa3Q2NSX0bUvTZHPNyXXlalqtRaBNdZ57ZHPZe13A6rCaAu2lD6yX0amnqm6Co05W0zI6Bn9eloASBmy6yX0amnqm6C(K5W0zI6Bn92v9TMowmnatdeJoNp1Cy6mr9TMoLlqAWUPPJftdW0aXOZ5MohMotuFRPtd2nzOIfFMowmnatdeJoNpT5W0zI6BnDAuyrXrVUMowmnatdeJoNHbZHPJftdW0aX0jcxrHZtNjQhbnPvFrCaAu2lvMHtMdxMJgvMzI6rqtA1xluU0nWy96kgWcx)iZWjZHlZrJkZkdWsF29RrHIglIj7dlMgGjzoAuzoSYCZYSYaS0xehGgL9sFyX0amjZ3K5MLzLbyPVwOCPBGX61vmGfU(5HftdWKmhMPZe13A624GGTmjwC8cWcC0rNEcP4yGohMZ3NdtNjQV10TTiayal540XIPbyAGy05COZHPZe13A6jmYglmb8LtMowmnatdeJoNpzomDSyAaMgiMor4kkCE6mr9iOblmWrRmdNmFY0zI6BnDcdagMO(wgGB1PdCRAkoaNoV4OZ5tnhMotuFRP3cLlDdmwVUIbSW1pthlMgGPbIrNZnDomDSyAaMgiMor4kkCE6cKsGwOmnaNotuFRPZxB9z058PnhMowmnatdetNjQV105RT(mDIWvu480zI6rqdwyGJwzgoz(UmFtMfiLaTqzAaoDYhcanklUq1oNVp6CggmhMowmnatdetNiCffopDMOEe0Gfg4OvMHtMdvMVjZKDbP9B9SXbbBzsS44fGf4tGC6JmFtMJWcNPb4lTQ1iqo9z6mr9TMoHbadtuFldWT60bUvnfhGtpXIJxawGMwb2o6CUjMdthlMgGPbIPteUIcNNotupcAWcdC0kZWjZHkZ3K5MLzLbyPVioank7L(WIPbysMVjZHvMBwMvgGL((kCfkA8YWxB95HftdWKmhnQmRmal9z3VgfkASiMSpSyAaMK5WiZ3K5ML50QplIjZsziRqe3Q(wp1jh96sMVjZnlZEzOa(fuvMVjZPvFKviIBvFRNaPeOfktdWPZe13A6wetMLYqwHiUv9TgDohINdthlMgGPbIPteUIcNNEyLz7gdmwOSijZWjZ3L5OrLzMOEe0Gfg4OvMHtMdvMdJmFtMj7cs736zJdc2YKyXXlalWNadyVSYmCY89qNotuFRPhXbOrzV0rNZ3dFomDSyAaMgiMor4kkCE6cKsGwOmnaNotuFRPB9wOBzaofo6C((95W0XIPbyAGy6eHROW5PZe1JGM0QV4YQmnanmffWjQVLm)lZHlZrJkZQto61LmFtMfiLaTqzAaoDMO(wtpUSktdqdtrbCI6Bn6C(EOZHPJftdW0aX0jcxrHZtxDYrVUK5BYmhYOWv8rylHtEDzimGdC9ZdlMgGjz(Mmthtr9iSLWjVUmegWbU(5jWa2lRmdtz(KPZe13A6XLvzAaAykkGtuFRrNZ3pzomDSyAaMgiMor4kkCE6HvMzI6rqdwyGJwzgMY8jYC0OYSYaS0xehGgL9sFyX0amjZrJkZkdWsFFfUcfnEz4RT(8WIPbysMVjZnlZkdWsF29RrHIglIj7dlMgGjzomY8nzwGuc0cLPb40zI6BnDYkeXTQV1OZ57NAomDMO(wthkhx60XIPbyAGy0589MohMowmnatdetNiCffopD7gdmwOSijZWjZNA6mr9TMEadqkNyeCRglWrNZ3pT5W0XIPbyAGy6mr9TMU1BHULb4u40jcxrHZtNjQhbnyHboALz4K57Y8nzoT6Z6Tq3YaCk8jWa2lRmdtz(KPt(qaOrzXfQ2589rNZ3HbZHPJftdW0aX0zI6BnDYkeXTQV10jcxrHZtxGbSxwzgMY8jY8nzoSYmtupcAWcdC0kZWuMprMJgvMvgGL(I4a0OSx6dlMgGjzoAuzwzaw67RWvOOXldFT1NhwmnatY8nzUzzwzaw6ZUFnku0yrmzFyX0amjZHz6KpeaAuwCHQDoFF0589MyomDSyAaMgiMor4kkCE6KDbP9B9SXbbBzsS44fGf4tGbSxwzgMYCOY8nzoclCMgGV0QwJa50NPZe13A6egammr9Tma3Qth4w1uCao9eloEbybAAfy7OZ57H45W0XIPbyAGy6eHROW5Pt2fK2V1ZgheSLjXIJxawGpbgWEzLz4Kz1dqJUMKJtNjQV10tS4OXUXGrNZHg(Cy6yX0amnqmDMO(wtNWaGHjQVLb4wD6a3QMIdWPt2fK2VLD05CO3NdthlMgGPbIPZe13A6egammr9Tma3Qth4w1uCaoDxXGrNZHg6Cy6yX0amnqmDIWvu480byeeiZWjZnfgiZ3K5WkZjKoMI6zHYP9RbdOfmbFwLjhLzykZHvMprMdjzMjQV1ZcLt7xd9c0NxgkGFbvL5WiZrJkZjKoMI6zHYP9RbdOfmbFcmG9YkZWuMprMdZ0zI6BnDcdagMO(wgGB1PdCRAkoaNUfhDoh6jZHPJftdW0aX0jcxrHZtpT6lIdqJYEPp1jh96sMJgvMj7cs736fXbOrzV0NadyVSYmCY89WL5OrLz7gdmwOSijZ)YCtNotuFRPhWaKYjgb3QXcC05CONAomDSyAaMgiMor4kkCE6kdWsFTq5s3aJ1RRyalC9ZdlMgGjz(MmhwzoT6Rfkx6gySEDfdyHRFEQto61LmhnQmt2fK2V1Rfkx6gySEDfdyHRFEcmG9YkZWjZ3dvMJgvMTBmWyHYIKmdNmFImhMPZe13A6bmaPCIrWTASahDohAtNdthlMgGPbIPteUIcNNEyL5MLzLbyPVioank7L(WIPbysMVjZnlZkdWsFTq5s3aJ1RRyalC9ZdlMgGjzomtNjQV10dyas5eJGB1ybo6Co0tBomDSyAaMgiMor4kkCE60XuupVWiUY0a0KWa3IpRYKJYmCY8jHlZrJkZ0XuupVWiUY0a0KWa3IV4wz(MmREaA01KCuMHPm30PZe13A6jb7Lb4u4OZ5qHbZHPJftdW0aX0jcxrHZtNoMI65fgXvMgGMeg4w0WH8ZQm5OmdNmFs4YC0OYmDmf1ZlmIRmnanjmWTOHd5xCRmFtMvpan6AsokZWuMB60zI6Bn9KG9YaCkC05COnXCy6yX0amnqmDMO(wtpjyVm2ngmDVuuiIBvJtnD1jhTW9h609srHiUvnEqaMCwXPFF6eOSxt)(OZ5qdXZHPZe13A6wOCA)AOxGoDSyAaMgigD0P3kqYgqZ6CyoFFomDSyAaMgiMor4kkCE6QhGYmCYC4Y8nzUzzUf1hd8iOmFtMBwMPJPOExcpyDbAwkJLjcNYj4lUD6mr9TMofcmPnWlw9TgDoh6Cy6mr9TMUnoiyldfcUIzrA6yX0amnqm6C(K5W0XIPbyAGy6eHROW5PRmal9Dj8G1fOzPmwMiCkNGpSyAaMMotuFRPFj8G1fOzPmwMiCkNGJoNp1Cy6yX0amnqm9TD6wuNotuFRPhHfotdWPhHbX40zI6rqtA1hzfI4w13sMHtMdxMVjZmr9iOjT6JV26JmdNmhUmFtMzI6rqtA1xCzvMgGgMIc4e13sMHtMdxMVjZHvMBwMvgGL(SEl0TmaNcFyX0amjZrJkZmr9iOjT6Z6Tq3YaCkuMHtMdxMdJmFtMdRmNw91cLlDdmwVUIbSW1pp1jh96sMJgvMBwMvgGL(AHYLUbgRxxXaw46NhwmnatYCyMEewykoaNEAvRrGC6ZOZ5MohMowmnatdetV4aC6CiBHYc2AO2snlLPD)IIPZe13A6CiBHYc2AO2snlLPD)IIrNZN2Cy6yX0amnqmDIWvu480TTiayuwCHQ9zrmzwkdzfI4w13YWlkZW9lZNiZ3K5MLzmek2BBX0JdzluwWwd1wQzPmT7xumDMO(wt3IyYSugYkeXTQV1OZzyWCy6mr9TMouoU0PJftdW0aXOZ5MyomDSyAaMgiMor4kkCE6nlZkdWsFq54sFyX0amjZ3KzBlcagLfxOAFwetMLYqwHiUv9Tm8IYmmL5tK5BYCZYmgcf7TTy6XHSfklyRHAl1SuM29lkMotuFRPBHYP9RHEb6OJoDYUG0(TSZH5895W0zI6Bn9VRaKIGEzeODlUi40XIPbyAGy05COZHPZe13A6byWk(ywkdiM4jtsGCGD6yX0amnqm6C(K5W0zI6BnDAWUjZszuOOblm4Z0XIPbyAGy058PMdtNjQV10VIzrY5YSugoKrXQqNowmnatdeJoNB6Cy6mr9TMUWBBbOXlJTLj40XIPbyAGy058PnhMotuFRPtTKylMmCiJcxrdnYbthlMgGPbIrNZWG5W0zI6Bn92yHt9XRldnGT60XIPbyAGy05CtmhMowmnatdetNiCffopDLfxO(GImqHAAjQmdNm3eHlZrJkZklUq9bfzGc10suzgMYCOHlZrJkZklUq9PEaA010sutOHlZWjZNkCzoAuzMYVGQgbgWEzLzykZHg(0zI6BnDbYTEDzOaCaAhDohINdtNjQV10jBrWsfSIjdfGdWPJftdW0aXOZ57HphMowmnatdetNiCffopD6ykQNajhbO1AOwbbFcmG9YoDMO(wtxHIM4IEJRKHAfeC05897ZHPZe13A6wYgl86YOUcfNowmnatdeJoNVh6Cy6mr9TMUh0IvYRldHv2QITfkoDSyAaMgigDoF)K5W0XIPbyAGy6eHROW5PhwzMoMI65fgXvMgGMeg4w8zvMCuMHtMpPjK5OrLzMOEe0Gfg4OvMHtMVlZHz6mr9TMUDJbgXQJoNVFQ5W0XIPbyAGy6eHROW5PhwzwzXfQpOiduOMwIkZWuMBA4YC0OYmLFbvncmG9YkZWjZnnCzomtNjQV10tiXdy1Rld9c0rhD6wComNVphMotuFRPdLJlD6yX0amnqm6Co05W09srHiUvno10tiDmf1ZcLt7xdgqlyc(Sktoc3)jtNjQV10tc2lJDJbthlMgGPbIrNZNmhMotuFRPBHYP9RHEb60XIPbyAGy0rNoV4CyoFFomDMO(wtVfkx6gySEDfdyHRFMowmnatdeJoNdDomDMO(wthkhx60XIPbyAGy058jZHPJftdW0aX0jcxrHZtxzaw6ZUFnku0yrmzFyX0amjZ3KzcxglIPPZe13A6wetMLYqwHiUv9TgDoFQ5W0XIPbyAGy6eHROW5P3SmRmal9z3VgfkASiMSpSyAaMK5BYCZYCA1NfXKzPmKviIBvFRN6KJEDjZ3K5MLzVmua)cQkZ3K50QpYkeXTQV1tGuc0cLPb40zI6BnDlIjZsziRqe3Q(wJoNB6Cy6yX0amnqmDMO(wtNV26Z0jcxrHZtNjQhbnPvF81wFKz4(L5tjZ3KzbsjqluMgGY8nzoT6JV26ZtDYrVUMo5dbGgLfxOANZ3hDoFAZHPJftdW0aX0zI6BnD(ARptNiCffopDMOEe0Kw9XxB9rMHPmFkz(Mm3SmNw9XxB95Po5OxxtN8HaqJYIluTZ57JoNHbZHPJftdW0aX0jcxrHZtNjQhbnPvFXLvzAaAykkGtuFlz(xMdxMJgvMvNC0Rlz(MmlqkbAHY0aC6mr9TMECzvMgGgMIc4e13A05CtmhMowmnatdetNjQV10JlRY0a0WuuaNO(wtNiCffop9MLz1jh96sMVjZTrAvgGL(eCqlxQHPOaor9TSpSyAaMK5BYmtupcAsR(IlRY0a0WuuaNO(wYmmL5tMo5dbGgLfxOANZ3hDohINdthlMgGPbIPteUIcNNUDJbgluwKKz4K57tNjQV10J4a0OSx6OZ57HphMowmnatdetNiCffopDYUG0(TE24GGTmjwC8cWc8jqo9rMVjZHvMtR(AHYLUbgRxxXaw46NNadyVSYmCYCOYC0OYCZYSYaS0xluU0nWy96kgWcx)8WIPbysMdZ0zI6BnDcdagMO(wgGB1PdCRAkoaNEIfhVaSanTcSD05897ZHPJftdW0aX0jcxrHZtNSliTFRNnoiyltIfhVaSaFcmG9YkZWjZQhGgDnjhNotuFRPNyXrJDJbJoNVh6Cy6yX0amnqmDMO(wtNWaGHjQVLb4wD6a3QMIdWPt2fK2VLD0589tMdthlMgGPbIPZe13A6egammr9Tma3Qth4w1uCaoDxXGrNZ3p1Cy6yX0amnqmDIWvu480tR(I4a0OSx6tDYrVUMotuFRPhWaKYjgb3QXcC0589MohMowmnatdetNiCffop9MLzLbyPVioank7L(WIPbyA6mr9TMEadqkNyeCRglWrNZ3pT5W0XIPbyAGy6mr9TMU1BHULb4u40jcxrHZtNjQhbnPvFwVf6wgGtHYmm)L5tK5BYCZYCA1N1BHULb4u4tDYrVUMo5dbGgLfxOANZ3hDoFhgmhMowmnatdetNiCffopD6ykQNxyexzAaAsyGBXNvzYrzgUFzUPHlZrJkZ0XuupVWiUY0a0KWa3IV4wz(MmREaA01KCuMHPm30PZe13A6jb7Lb4u4OZ57nXCy6mr9TMEsWEzSBmy6yX0amnqm6C(EiEomDMO(wt3cLt7xd9c0PJftdW0aXOJoDxXG5WC((Cy6mr9TMESfnUIb2PJftdW0aXOJo605yf6kME3dAYhD0za]] )


end