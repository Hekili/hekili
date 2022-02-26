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


if UnitClassBase( "player" ) == 'WARLOCK' then
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
            if k == "count" or k == "current" then return t.actual

            elseif k == "actual" then
                t.actual = UnitPower( "player", Enum.PowerType.SoulShards )
                return t.actual

            else
                local amount = k:match( "time_to_(%d+)" )
                amount = amount and tonumber( amount )

                if amount then return state:TimeToResource( t, amount ) end
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
            aliasMode = "longest",
            aliasType = "debuff",
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


    spec:RegisterGear( "tier28", 188884, 188887, 188888, 188889, 188890 )
    
    -- Tier 28
    spec:RegisterSetBonuses( "tier28_2pc", 364437, "tier28_4pc", 363953 )
    -- 2-Set - Deliberate Malice - Malefic Rapture's damage is increased by 15% and each cast extends the duration of Corruption, Agony, and Unstable Affliction by 2 sec.
    -- 4-Set - Calamitous Crescendo - While Agony, Corruption, and Unstable Affliction are active, your Drain Soul has a 10% chance / Shadow Bolt has a 20% chance to make your next Malefic Rapture cost no Soul Shards and cast instantly.
    spec:RegisterAura( "calamitous_crescendo", {
        id = 364322,
        duration = 10,
        max_stack = 1,
    } )

    spec:RegisterGear( "tier21", 152174, 152177, 152172, 152176, 152173, 152175 )
    spec:RegisterGear( "tier20", 147183, 147186, 147181, 147185, 147182, 147184 )
    spec:RegisterGear( "tier19", 138314, 138323, 138373, 138320, 138311, 138317 )
    spec:RegisterGear( "class", 139765, 139768, 139767, 139770, 139764, 139769, 139766, 139763 )

    spec:RegisterGear( "amanthuls_vision", 154172 )
    spec:RegisterGear( "hood_of_eternal_disdain", 132394 )
    spec:RegisterGear( "norgannons_foresight", 132455 )
    spec:RegisterGear( "pillars_of_the_dark_portal", 132357 )
    spec:RegisterGear( "power_cord_of_lethtendris", 132457 )
    spec:RegisterGear( "reap_and_sow", 144364 )
    spec:RegisterGear( "sacrolashs_dark_strike", 132378 )
    spec:RegisterGear( "soul_of_the_netherlord", 151649 )
    spec:RegisterGear( "stretens_sleepless_shackles", 132381 )
    spec:RegisterGear( "the_master_harvester", 151821 )


    --[[ spec:RegisterStateFunction( "applyUnstableAffliction", function( duration )
        for i = 1, 5 do
            local aura = "unstable_affliction_" .. i

            if debuff[ aura ].down then
                applyDebuff( "target", aura, duration or 8 )
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
            cast = function () return buff.calamitous_crescendo.up and 0 or 1.5 end,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return buff.calamitous_crescendo.up and 0 or 1 end,
            spendType = "soul_shards",
            
            startsCombat = true,
            texture = 236296,
            
            handler = function ()
                if legendary.malefic_wrath.enabled then addStack( "malefic_wrath", nil, 1 ) end

                if set_bonus.tier28_2pc > 0 then
                    if debuff.corruption.up then debuff.corruption.expires = debuff.corruption.expires + 2 end
                    if debuff.agony.up then debuff.agony.expires = debuff.agony.expires + 2 end
                    if debuff.unstable_affliction.up then debuff.unstable_affliction.expires = debuff.unstable_affliction.expires + 2 end
                end

                if buff.calamitous_crescendo.up then removeBuff( "calamitous_crescendo" ) end
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

            indicator = function()
                if active_enemies > 1 and settings.cycle and target.time_to_die > shortest_ttd then return "cycle" end
            end,

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


    spec:RegisterPack( "Affliction", 20220226, [[dq1FFdqikPSikPQIhbj0MarFIankiPtbPSkvbPxPkYSOKClqa7sIFPkQHbjYXGuTmkv9mjHMMQaxJsQSnqG(gLuLXbjOZraH1bjQ3rjvvQ5bs5Ess7JaCqciTqvHEiiKjQkOUiivXgvfe9rciIrQki4KeqzLGKxsarQzcsLBccQDsPYpbPknuqqwkbu9uiMQKORsjvLTsar9vibgRKG3sjvvYDjGiXEf8xv1Gv5WuTyvPhtXKvQlJSzH8zLy0sQtlA1Qcc9AcA2qDBqTBs)wXWvshhKQA5apNOPJ66eA7uIVlunEqOoVqz9usvvZNs5(eqK0(L6a6HkdiBNPGD2Js2BpkzV9qWc6qq7RyfHGbeo2kfqwDJqFHciQdtbebAueonCoAaz1JHhFhQmGihrGHci1mVkr5NFEj5AX3IzGFwMWIyNZrnapIFwMWMNdiVIjMfyA4nGSDMc2zpkzV9OK92dblOdbTVIvmGixjtWo7HGwxaPo3BsdVbKnjnbebAueonCoAFOahGhJWgQhs6fi6Gy9zV1zvF2Js2BFdvdfev76cjr5gkiqFc09M29HSsyCFq3yewAOGa9jq3BA33dtwgrqFqyFjnLgkiqFc09M299cixOP2vLW9HNL00x0a67HbEQ9HmI4sdfeOVkJtUW(GWoMIstFcCFLfbuF4zjn9XtFXhGW(YO(InIccO(GtPm1L(8(yhtk3xQ9X1o3hyIxAOGa9b9O(lM6tG7WRUY9jqJIWPHZrL9bHSaH6JDmPCPHcc0xLXjxOSpE6ZTm5UVx8ep1L(EyhiCb7aQVu7dweZjeGDWcX9f)5PVhg6TszFIRLgkiqFq0OBsLuFYbM67HDGWfSdO(GqaATpJJXY(4PpaTfnuFMbEvKDohTpoHPsdfeOpeI7toWuFghJ)UHZr)4uY9rkdss2hp9jzqA4(4Pp3YK7(m1KryQl9Htjl7JRDUV4Jki33l1hGCtnT7dvFXt1AOvAOGa9b9Q4y9Hq0UVrnuFRaccSkIXLgkiqFc09drrj3N1pVIaTpi6HL99srdG6J0DFtuFr5snB9tF4zjn9XtF(6kowFJIJ1hp99oszFr5snl7dvD4(yGlR7B1ncLOvAOGa99qIjzTb4r8ZcKhSZjM6dzWwiL7Z4QHW)mQptTRl0UpE6lvMaaXv(NrLgkiqFcmLPfGZuF2rgW0hegf03kihqYX6dNsUeqwbtuIPackII9jqJIWPHZr7df4a8ye2qHIOyFpK0lq0bX6ZERZQ(ShLS3(gQgkuef7dIQDDHKOCdfkII9bb6tGU30UpKvcJ7d6gJWsdfkII9bb6tGU30UVhMSmIG(GW(sAknuOik2heOpb6Et7(EbKl0u7Qs4(WZsA6lAa99Wap1(qgrCPHcfrX(Ga9vzCYf2he2XuuA6tG7RSiG6dplPPpE6l(ae2xg1xSruqa1hCkLPU0N3h7ys5(sTpU25(at8sdfkII9bb6d6r9xm1Na3HxDL7tGgfHtdNJk7dczbc1h7ys5sdfkII9bb6RY4Klu2hp95wMC33lEIN6sFpSdeUGDa1xQ9blI5ecWoyH4(I)803dd9wPSpX1sdfkII9bb6dIgDtQK6toWuFpSdeUGDa1hecqR9zCmw2hp9bOTOH6ZmWRISZ5O9XjmvAOqruSpiqFie3NCGP(mog)DdNJ(XPK7JugKKSpE6tYG0W9XtFULj39zQjJWux6dNsw2hx7CFXhvqUVxQpa5MAA3hQ(INQ1qR0qHIOyFqG(GEvCS(qiA33OgQVvabbwfX4sdfkII9bb6tGUFikk5(S(5veO9brpSSVxkAauFKU7BI6lkxQzRF6dplPPpE6ZxxXX6BuCS(4PV3rk7lkxQzzFOQd3hdCzDFRUrOeTsdfkII9bb67HetYAdWJ4NfipyNtm1hYGTqk3NXvdH)zuFMAxxODF80xQmbaIR8pJknuOik2heOpbMY0cWzQp7idy6dcJc6BfKdi5y9HtjxAOAOCdNJklRaYmWVoxnIW)9aNQZ5OwLrv5eMeakbP1wjU440cbP1EfJIklGeEsa9NOV0nGmknurCTHYnCoQSSciZa)68tvFwkcdp6FL4gk3W5OYYkGmd8RZpv9zrj9tMGTsDyQkpW0FI(WJkzWik)MrLmq0W5OYgk3W5OYYkGmd8RZpv9zrj9tMGTsDyQQCWKxl)sYai(ZKPwtOVi1q5gohvwwbKzGFD(PQpVas4jb0FI(s3aYO0qwLrvzhtkxwaj8Ka6prFPBazuAOcP(lM2nuUHZrLLvazg4xNFQ6ZryswBaEe3q5gohvwwbKzGFD(PQpBXbP)IjRuhMQUhw(bKVJzLfhlsvDdNwO)E4IzaaXvohvaOeKUHtl0FpCXxgnMaqjiDdNwO)E4IOkz)ftFpkcNgohvaOeKOAn2XKYfzUwp6hNruHu)ftBB2CdNwO)E4ImxRh9JZisaOeAqI6E4YATR8a)LPUiIDqYXkCAeM6InBwJDmPCzT2vEG)YuxeXoi5yfs9xmTrRHYnCoQSSciZa)68tvFws0(prFZaaIRCoQv4uPVzxfDuYQmQQCLW4p7GfILfjr7)e9ndaiUY5OFFibuTInuUHZrLLvazg4xNFQ6Z1UOYnuUHZrLLvazg4xNFQ6ZIQK9xm99OiCA4C0gQgkuef7d6bIjJit7(ileiwFCct9X1uFUHhqFPSp3INy)ftLgk3W5OYQYvcJ)4XiSHYnCoQ8PQpVjlJi4d7lPPHYnCoQ8PQpBCm(7goh9JtjBL6WuvFiRKminCv0TkJQ6goTqFsj4KKcOInuUHZrLpv9zyhtrP5d8vweqwLrvFfJIkgh7WjpIYVbqsdP7PiU2qHI9brog3NKwDGZuFUHZr7dNsUVOb0NDKbm4bS7dcJc6l1(qQS0hejcaKY4y9nkowFZkNWP1FA3x0a6tus9fp56(GqiLgk3W5OYNQ(mqu)UHZr)4uYwPomvvjdy(WXTsYG0Wvr3QmQQzSqQRCrjdyWdydjquPObSqfyhtrP5hh4CnKUHtl0Nucojzv0HKDmPCzT2vEG)YuxeXoi5ynuOyFcudNJ2hoLSSVOb0hdsviX99s1ULCaL(qyNL95aQpPBH29fnG(EPObq9HmI4(e4d)SadEL0DQl9bro7sgmR10ZqOAx5bUpKuxeXoi5yw13W1eiEkP(gTpZm49exlnuUHZrLpv9zJJXF3W5OFCkzRuhMQYGufs8xUIt(BQjJWgk3W5OYNQ(SXX4VB4C0poLSvQdtv3e2Jr7pdsviXYgk3W5OYNQ(SXX4VB4C0poLSvQdtvLSZFgKQqILwjzqA4QOBvgvf19Wf5iI)GHlCAeM6InB7Hlj8kP7ux(gNDjdM1A6VhUWPryQl2SThUSw7kpWFzQlIyhKCScNgHPUGgKYre)L1oylGkAZ2E4ILetF2tLlCAeM6InBSJjLlYj(NRPVKOTSHYnCoQ8PQpBCm(7goh9JtjBL6Wu1Td7l0NbPkKyPvzuvZyHux5IMl18pYjir1AwCq6VyQWGufs8xUIt2MnZm49exlYre)bdxaeSNQua2Js2SHQfhK(lMkmivHe)hLG0mdEpX1ICeXFWWfab7PkHgdsviXf0lMzW7jUwaeSNQenB2q1Ids)ftfgKQqI)C8bsZm49exlYre)bdxaeSNQeAmivHexSVyMbVN4AbqWEQs0qZMnZyHux5Ifs56yair1AwCq6VyQWGufs8xUIt2MnZm49exlj8kP7ux(gNDjdM1AQaiypvPaShLSzdvloi9xmvyqQcj(pkbPzg8EIRLeEL0DQlFJZUKbZAnvaeSNQeAmivHexqVyMbVN4AbqWEQs0Szdvloi9xmvyqQcj(ZXhinZG3tCTKWRKUtD5BC2LmywRPcGG9uLqJbPkK4I9fZm49exlac2tvIgA2SHQzSqQRCrjdyWdyBZMzSqQRCrymq6QnBMXcPUYfDucnir1AwCq6VyQWGufs8xUIt2MnZm49exlR1UYd8xM6Ii2bjhRaiypvPaShLSzdvloi9xmvyqQcj(pkbPzg8EIRL1Ax5b(ltDre7GKJvaeSNQeAmivHexqVyMbVN4AbqWEQs0Szdvloi9xmvyqQcj(ZXhinZG3tCTSw7kpWFzQlIyhKCScGG9uLqJbPkK4I9fZm49exlac2tvIgA2Szn2XKYL1Ax5b(ltDre7GKJvi1FX0gsuTMfhK(lMkmivHe)LR4KTzZmdEpX1IuegE0)2bcxWoGkac2tvka7rjB2q1Ids)ftfgKQqI)JsqAMbVN4Arkcdp6F7aHlyhqfab7PkHgdsviXf0lMzW7jUwaeSNQenB2q1Ids)ftfgKQqI)C8bsZm49exlsry4r)BhiCb7aQaiypvj0yqQcjUyFXmdEpX1cGG9uLOHwdfk23JIaTp5iI7tw7GTSVmQVOCPM7lL95y4rY9nwiqdLB4Cu5tvFg2XuuA(aFLfbKvzu13rkHmkxQ5pGG9uLqJGyYiY0Nty6Hkhr8xw7GnK7HlIQK9xm99OiCA4C0cNgHPU0qHI9jWI6Zmwi1vUV9WpdHQDLh4(qsDre7GKJ1xk7diQAQlw1NOK67HDGWfSdO(4PpcIzs39X1uFgraGuUpjXnuUHZrLpv9zJJXF3W5OFCkzRuhMQUDGWfSdO)kGwTkJQIQzSqQRCXcPCDmaK7Hlj8kP7ux(gNDjdM1A6VhUWPryQlqAMbVN4Arkcdp6F7aHlyhqfab7PkHM9qI6E4YATR8a)LPUiIDqYXkac2tvka7TzZASJjLlR1UYd8xM6Ii2bjhdn0SzdvZyHux5IMl18pYji3dxKJi(dgUWPryQlqAMbVN4Arkcdp6F7aHlyhqfab7PkHM9qI6E4YATR8a)LPUiIDqYXkac2tvka7TzZASJjLlR1UYd8xM6Ii2bjhdn0SzdvunJfsDLlkzadEaBB2mJfsDLlcJbsxTzZmwi1vUOJsOb5E4YATR8a)LPUiIDqYXkCAeM6cK7HlR1UYd8xM6Ii2bjhRaiypvj0ShTgkuSpbofbizDF7HL9roahRVmQVLj1L(sLN(8(K1oy3NCL0DQl9Tw7sQHYnCoQ8PQpBCm(7goh9JtjBL6Wu19W)vaTAvgvfvZyHux5IMl18pYjiT2E4ICeXFWWfonctDbsZm49exlYre)bdxaeSNQeApanB2q1mwi1vUyHuUogasRThUKWRKUtD5BC2LmywRP)E4cNgHPUaPzg8EIRLeEL0DQlFJZUKbZAnvaeSNQeApanB2qfvZyHux5IsgWGhW2MnZyHux5IWyG0vB2mJfsDLl6OeAqYoMuUSw7kpWFzQlIyhKCmiT2E4YATR8a)LPUiIDqYXkCAeM6cKMzW7jUwwRDLh4Vm1frSdsowbqWEQsO9a0AOqX(eyr9bHQDLh4(qsDre7GKJ1xk7JtJWuxSQVK7lL9j9iQpE6tus99WoqyFiJiUHYnCoQ8PQpVDGWVCeXwLrv3dxwRDLh4Vm1frSdsowHtJWuxAOCdNJkFQ6ZBhi8lhrSvzuvRXoMuUSw7kpWFzQlIyhKCmirDpCroI4py4cNgHPUyZ2E4scVs6o1LVXzxYGzTM(7HlCAeM6cAnuOyFiXutFqOAx5bUpKuxeXoi5y9fp56(eitkxhd8SD5sn33dPt9zglK6k33EyR6B4AcepLuFIsQVr7ZmdEpX1sFcSO(GEGxJbih3h0lyRUAO(EfJI6lL9LQzGtDXQ(Qh8UprLtCFjlOSpa57y9Hk6OW(KKz0TSppIjqFIscTgk3W5OYNQ(8ATR8a)LPUiIDqYXSkJQAglK6kx0CPM)robjNWKaSoinZG3tCTihr8hmCbqWEQsOHoKOYGufsCHGxJbih)hWwD1qfZm49exlac2tvcn0HG2BZM1iOVyUUs7cbVgdqo(pGT6QHqRHYnCoQ8PQpVw7kpWFzQlIyhKCmRYOQMXcPUYflKY1XaqYjmjaRdsZm49exlj8kP7ux(gNDjdM1AQaiypvj0qhsuzqQcjUqWRXaKJ)dyRUAOIzg8EIRfab7PkHg6qq7TzZAe0xmxxPDHGxJbih)hWwD1qO1qHI9zhzadEa7(INCDFqyhtrPPpuaW56(mUKL9Tw7kpW9jtDre7GKJ1xQ9HtL6lEY199WKjHDo1L(ECWCdLB4Cu5tvFET2vEG)YuxeXoi5ywLrvnJfsDLlkzadEaBibIkfnGfQa7ykkn)4aNRHKtysawhKMzW7jUw2KjHDo1L)7G5cGG9uLqRIqIkdsviXfcEngGC8FaB1vdvmZG3tCTaiypvj0qhcAVnBwJG(I56kTle8Ama54)a2QRgcTgkuSpOxUMa9zglK6kl7d1unyXDQl9PJcbGWOG(SJmGbT(mUK7dcH03O9zMbVN4AdLB4Cu5tvFET2vEG)YuxeXoi5ywLrvr1mwi1vUimgiD1MnZyHux5IokzZgQMXcPUYfLmGbpGnKwdiQu0awOcSJPO08JdCUgn0GevgKQqIle8Ama54)a2QRgQyMbVN4AbqWEQsOHoe0EB2Sgb9fZ1vAxi41yaYX)bSvxneAnuUHZrLpv951Ax5b(ltDre7GKJzvgv9DKsiJYLA(diypvj0qhc2qHI9jWI6dcv7kpW9HK6Ii2bjhRVu2hNgHPUyvFjlOSpoHP(4Pprj13W1eOpy)H4a6BpSSHYnCoQ8PQpBCm(7goh9JtjBL6WuvZyHuxzRKminCv0TkJQUhUSw7kpWFzQlIyhKCScNgHPUajQMXcPUYfnxQ5FKt2SzglK6kxSqkxhdGwdLB4Cu5tvF2xgnMvMygm9zhSqSSk6wLrv3dx8LrJvaeSNQeApOHYnCoQ8PQpx7Ik3qHI9HmX7JRP(qiAl7B0(QyFSdwiw2xg1xY9LsvqUpJiaqkJJ1xQ9fHZLAUVb03O9X1uFSdwiU0hki56(qY16r7d6YiQVKfu2NJLtFVeZeOpE6tus9Hq0UVXcb6d2vrhJJ1NVUIJL6sFvSpiAaaXvohvwAOCdNJkFQ6ZsI2)j6BgaqCLZrTkJQ6goTqFsj4KKcWEizhtkxKt8pxtFjrBjKwBpCrs0(prFZaaIRCoAHtJWuxG0AP(JW5sn3q5gohv(u1NLeT)t03maG4kNJAvgv1nCAH(KsWjjfG9qYoMuUiZ16r)4mIG0A7HlsI2)j6BgaqCLZrlCAeM6cKwl1FeoxQzi3dxmdaiUY5Ofab7PkH2dAOCdNJkFQ6Zwsm9zpv2QmQkQYre)L1oyla0TzZnCAH(KsWjjfG9ObPzg8EIRfPim8O)TdeUGDavaeSNQuaOBFdLB4Cu5tvFwuLS)IPVhfHtdNJAvgv1nCAH(7HlIQK9xm99OiCA4C0QOKnBCAeM6cK7HlIQK9xm99OiCA4C0cGG9uLq7bnuUHZrLpv9zzUwp6hNrKvMygm9zhSqSSk6wLrv3dxK5A9OFCgrfab7PkH2dAOCdNJkFQ6ZghJ)UHZr)4uYwPomv1mwi1v2kjdsdxfDRYOQwZmwi1vUOKbm4bSBOqX(eORR4y9brdaiUY5O9b7QOJXX6B0(qhcyFFSdwiwAvFdOVr7RI9fp56(eOVYblYuFq0aaIRCoAdLB4Cu5tvF2maG4kNJALjMbtF2blelRIUvzuv3WPf6tkbNKeApacGk7ys5ICI)5A6ljAlTzJDmPCrMR1J(XzeHgK7HlMbaex5C0cGG9uLqZ(gkuSpbAetG(4AQVzLucyvFYvs3959jRDWUV41K2NZ9zD9nAFqyhtrPPpbUVYIaQpE6ZTm5UVXcbm(6AQlnuUHZrLpv9zyhtrP5d8vweqwLrvLJi(lRDWwapasoHjbyp6nuOyFOGAs7thUpzm1K6sFqOAx5bUpKuxeXoi5y9XtFcKjLRJbE2UCPM77H0jR6dregE0(EyhiCb7aQVmQphJ7BpSSphq95RR4K2nuUHZrLpv9zJJXF3W5OFCkzRuhMQUDGWfSdO)kGwTkJQIQzSqQRCXcPCDmaKwJDmPCzT2vEG)YuxeXoi5yqUhUKWRKUtD5BC2LmywRP)E4cNgHPUaPzg8EIRfPim8O)TdeUGDavaKVJHMnBOAglK6kx0CPM)robP1yhtkxwRDLh4Vm1frSdsogK7HlYre)bdx40im1finZG3tCTifHHh9VDGWfSdOcG8Dm0SzdvunJfsDLlkzadEaBB2mJfsDLlcJbsxTzZmwi1vUOJsObPzg8EIRfPim8O)TdeUGDavaKVJHwdfk2N1NK67HDGW(qgrCFzuFpSdeUGDa1x8rfK77L6dq(owF(INQv9nG(YO(4Acq9fpX4(EP(CUpm5sUp77dEauFpSdeUGDa1NOKKnuUHZrLpv95Tde(LJi2QmQ67iLqAMbVN4Arkcdp6F7aHlyhqfab7PkfquUuZFab7PkHevRXoMuUSw7kpWFzQlIyhKCmB2mZG3tCTSw7kpWFzQlIyhKCScGG9uLcikxQ5pGG9uLO1q5gohv(u1N3oq4xoIyRYOQVJucP1yhtkxwRDLh4Vm1frSdsogKMzW7jUwKIWWJ(3oq4c2bubqWEQYNmZG3tCTifHHh9VDGWfSdOYwe4Cok0IYLA(diypvzdfk2he5SPgc4yCFjtW9jk9fQVOb0NRX46ux6thUp5kzYOK29ryjfVMaudLB4Cu5tvF24y83nCo6hNs2k1HPQjtWnuOik2NaNIaKSUpKAFpX7d6b(f4gQVxkAauFYvs3PU0NS2bBzFJ2he2XuuA6tG7RSiGAOCdNJkFQ6ZghJ)UHZr)4uYwPomvvswLrvzhtkxK1(EI)j4xGBOcP(lM2qI6MEfJIkYAFpX)e8lWnurYUri0q1EiGB4C0IS23t8)7G5sQ)iCUuZOzZ2MEfJIkYAFpX)e8lWnubqWEQsOvr0AOqX(S(KuFqyhtrPPpbUVYIaQV41K2hS)qCa9Thw2NdO(exTQVb0xg1hxtaQV4jg33l1Nmx0mknUY9Xjm1NOYjUpUM6tjiM7dcv7kpW9HK6Ii2bjhR0NalQproXP1)ux6dc7ykkn9HcaoxBvF1dE3N3NS2b7(4PpafbizDFCn13RyuudLB4Cu5tvFg2XuuA(aFLfbKvzuvu3dxSKy6ZEQCHtJWuxSzBpCjHxjDN6Y34SlzWSwt)9WfonctDXMT9Wf5iI)GHlCAeM6cAqIQ1aIkfnGfQa7ykkn)4aNRTz7vmkQa7ykkn)4aNRls2ncHwfTztoI4VS2bBbGoAnuOyFwFsQpiSJPO00Na3xzra1hp9b7PYEQ9X1uFWoMIstFXbox33RyuuFIkN4(K1oyl7tjA3hp99s9TqkbCM29fnG(4AQpLGyUVxrGK7lEQ7jEFOApk1NKmJUL9LY(Gha1hx7AFsXOO0KKY9XtFlKsaNP(QyFYAhSLO1q5gohv(u1NHDmfLMpWxzrazvgvfiQu0awOcSJPO08JdCUgsZm49exlYre)bdxaeSNQua2Jsq(kgfvGDmfLMFCGZ1fab7PkH2dAOqX(GWEQSNAFqyhtrPPpuaW56(CUphJ7Jtys2x0a6JRP(SJmGbpGDFdOpbshdKU2NzSqQRCdLB4Cu5tvFg2XuuA(aFLfbKvzuvGOsrdyHkWoMIsZpoW5Air1mwi1vUOKbm4bSTzZmwi1vUimgiDfniFfJIkWoMIsZpoW56cGG9uLq7bnuOyFwFsQpiSJPO00Na3xzra13O9bHQDLh4(qsDre7GKJ1NXLS0Q(GDHPU0Nueq9XtFs3c1N3NS2b7(4Ppj7gH9bHDmfLM(qbaNR7lJ6tuM6sFj3q5gohv(u1NHDmfLMpWxzrazvgvLDmPCzT2vEG)YuxeXoi5yqI6E4YATR8a)LPUiIDqYXkCAeM6InBMzW7jUwwRDLh4Vm1frSdsowbqWEQsbyV1zZ27iLqYjm955VtcAMzW7jUwwRDLh4Vm1frSdsowbqWEQs0GevRbevkAalub2XuuA(XboxBZ2Ryuub2XuuA(XboxxKSBecTkAZMCeXFzTd2caD0AOCdNJkFQ6ZWoMIsZh4RSiGSkJQYoMuUiN4FUM(sI2YgkuSVhg4P2h0LruFPSVrXX6Z77HHqi9T4P2x8KR7tGPKLK9xm13dtWPK6tjh0hSdX9jz3iuw6tGf1xuUuZ9LY(83rK7JN(iD33E6thUp4uk7tUs6o1L(4AQpj7gHYgk3W5OYNQ(8g4P(Xzezvgv9vmkQKkzjz)ft)nbNsQiz3iuapaLSz7vmkQKkzjz)ft)nbNsQiUc57iLqgLl18hqWEQsO9Ggk3W5OYNQ(SXX4VB4C0poLSvQdtvnJfsDLBOCdNJkFQ6Z(YOXSYeZGPp7GfILvr3QmQkGIaKS2FXudLB4Cu5tvFwuLS)IPVhfHtdNJAvgv1nCAH(7HlIQK9xm99OiCA4C0QOKnBCAeM6cKakcqYA)ftnuUHZrLpv9zzUwp6hNrKvMygm9zhSqSSk6wLrvbueGK1(lMAOCdNJkFQ6ZMbaex5CuRmXmy6ZoyHyzv0TkJQcOiajR9xmbPB40c9jLGtscThabqLDmPCroX)Cn9LeTL2SXoMuUiZ16r)4mIqRHYnCoQ8PQphHjzTb4rSvzuv5iIFtDxSmyNtm9Ld2cPSvPYeaiUY)mQ6RyuuXYGDoX0xoylKYfX1gk3W5OYNQ(8g4P(LJi2Quzcaex5QO3q5gohv(u1NL1(EI)Fhm3q1q5gohvw8HQUw7kpWFzQlIyhKCSgk3W5OYIp0tvFU2fvUHYnCoQS4d9u1Nnog)DdNJ(XPKTsDyQ62bcxWoG(RaA1QmQQzSqQRCXcPCDmaK7Hlj8kP7ux(gNDjdM1A6VhUWPryQlqAMbVN4Arkcdp6F7aHlyhqfa57yqI6E4YATR8a)LPUiIDqYXkac2tvka7TzZASJjLlR1UYd8xM6Ii2bjhdnB2mJfsDLlAUuZ)iNGCpCroI4py4cNgHPUaPzg8EIRfPim8O)TdeUGDavaKVJbjQ7HlR1UYd8xM6Ii2bjhRaiypvPaS3MnRXoMuUSw7kpWFzQlIyhKCm0SzdvZyHux5IsgWGhW2MnZyHux5IWyG0vB2mJfsDLl6OeAqUhUSw7kpWFzQlIyhKCScNgHPUa5E4YATR8a)LPUiIDqYXkac2tvcn7BOCdNJkl(qpv9zjr7)e9ndaiUY5OwLrvzhtkxKt8pxtFjrBjKgx)sI2nuUHZrLfFONQ(SKO9FI(Mbaex5CuRYOQwJDmPCroX)Cn9LeTLqAT9Wfjr7)e9ndaiUY5OfonctDbsRL6pcNl1mK7HlMbaex5C0cGIaKS2FXudLB4CuzXh6PQp7lJgZktmdM(SdwiwwfDRYOQUHtl0FpCXxgng0EaKwBpCXxgnwHtJWuxAOCdNJkl(qpv9zFz0ywzIzW0NDWcXYQOBvgv1nCAH(7Hl(YOXeq1hajGIaKS2FXeK7Hl(YOXkCAeM6sdLB4CuzXh6PQplQs2FX03JIWPHZrTkJQ6goTq)9WfrvY(lM(EueonCoAvuYMnonctDbsafbizT)IPgk3W5OYIp0tvFwuLS)IPVhfHtdNJALjMbtF2blelRIUvzuvRXPryQlqUAzLDmPCb4WRUYFpkcNgohvwi1FX0gs3WPf6VhUiQs2FX03JIWPHZrHwfBOCdNJkl(qpv9zljM(SNkBvgvvoI4VS2bBbGEdLB4CuzXh6PQpBCm(7goh9JtjBL6WuvZyHuxzRKminCv0TkJQAnZyHux5IsgWGhWUHYnCoQS4d9u1Nnog)DdNJ(XPKTsDyQ62bcxWoG(RaA1QmQkQMXcPUYflKY1XaqIQzg8EIRLeEL0DQlFJZUKbZAnvaKVJzZ2E4scVs6o1LVXzxYGzTM(7HlCAeM6cAqAMbVN4Arkcdp6F7aHlyhqfa57yqI6E4YATR8a)LPUiIDqYXkac2tvka7TzZASJjLlR1UYd8xM6Ii2bjhdn0GevunJfsDLlkzadEaBB2mJfsDLlcJbsxTzZmwi1vUOJsObPzg8EIRfPim8O)TdeUGDavaeSNQeA2djQ7HlR1UYd8xM6Ii2bjhRaiypvPaS3MnRXoMuUSw7kpWFzQlIyhKCm0qZMnunJfsDLlAUuZ)iNGevZm49exlYre)bdxaKVJzZ2E4ICeXFWWfonctDbninZG3tCTifHHh9VDGWfSdOcGG9uLqZEirDpCzT2vEG)YuxeXoi5yfab7PkfG92Szn2XKYL1Ax5b(ltDre7GKJHgAnuUHZrLfFONQ(82bc)YreBvgv9DKsinZG3tCTifHHh9VDGWfSdOcGG9uLcikxQ5pGG9uLqIQ1yhtkxwRDLh4Vm1frSdsoMnBMzW7jUwwRDLh4Vm1frSdsowbqWEQsbeLl18hqWEQs0AOCdNJkl(qpv95Tde(LJi2QmQ67iLqAMbVN4Arkcdp6F7aHlyhqfab7PkFYmdEpX1IuegE0)2bcxWoGkBrGZ5OqlkxQ5pGG9uLnuUHZrLfFONQ(SXX4VB4C0poLSvQdtvtMGBOCdNJkl(qpv9zJJXF3W5OFCkzRuhMQUjShJ2FgKQqILnuUHZrLfFONQ(SXX4VB4C0poLSvQdtv3oSVqFgKQqILnuUHZrLfFONQ(SXX4VB4C0poLSvQdtvLSZFgKQqILwjzqA4QOBvgvDpCzT2vEG)YuxeXoi5yfonctDXMnRXoMuUSw7kpWFzQlIyhKCSgk3W5OYIp0tvFg2XuuA(aFLfbKvzu19WfljM(SNkx40im1Lgk3W5OYIp0tvFg2XuuA(aFLfbKvzu19Wf5iI)GHlCAeM6cKwJDmPCroX)Cn9LeTLnuUHZrLfFONQ(mSJPO08b(klciRYOQwJDmPCXsIPp7PYnuUHZrLfFONQ(mSJPO08b(klciRYOQYre)L1oylGh0q5gohvw8HEQ6ZYCTE0poJiRmXmy6ZoyHyzv0TkJQ6goTq)9WfzUwp6hNre0QwribueGK1(lMG0A7HlYCTE0poJOcNgHPU0q5gohvw8HEQ6ZghJ)UHZr)4uYwPomv1mwi1v2kjdsdxfDRYOQMXcPUYfLmGbpGDdLB4CuzXh6PQpVbEQFCgrwLrvFfJIkPsws2FX0FtWPKks2ncfqvRdLSz7DKsiFfJIkPsws2FX0FtWPKkIRqgLl18hqWEQsOzD2S9kgfvsLSKS)IP)MGtjvKSBekGQv06GCpCroI4py4cNgHPU0q5gohvw8HEQ6ZryswBaEeBvgvvoI43u3fld25etF5GTqkBvQmbaIR8pJQ(kgfvSmyNtm9Ld2cPCrCTHYnCoQS4d9u1N3ap1VCeXwLktaG4kxf9gk3W5OYIp0tvFww77j()DWCdvdLB4CuzXmwi1vUAcVs6o1LVXzxYGzTMSkJQAn2XKYL1Ax5b(ltDre7GKJbjQMzW7jUwKIWWJ(3oq4c2bubqWEQsOHokzZMzg8EIRfPim8O)TdeUGDavaeSNQuawhkzZMzg8EIRfPim8O)TdeUGDavaeSNQua2BDqAgDlMCXmaG4kN6YhteaTgk3W5OYIzSqQR8tvFoHxjDN6Y34SlzWSwtwLrvzhtkxwRDLh4Vm1frSdsogK7HlR1UYd8xM6Ii2bjhRWPryQlnuUHZrLfZyHux5NQ(8MmjSZPU8FhmBvgv1mdEpX1IuegE0)2bcxWoGkac2tvkaRdsu30RyuuP2fvUaiypvPaEGnBwJDmPCP2fvgTgk3W5OYIzSqQR8tvFwoI4pyyRYOQwJDmPCzT2vEG)YuxeXoi5yqIQzg8EIRfPim8O)TdeUGDavaeSNQeAwNnBMzW7jUwKIWWJ(3oq4c2bubqWEQsbyDOKnBMzW7jUwKIWWJ(3oq4c2bubqWEQsbyV1bPz0TyYfZaaIRCQlFmra0AOCdNJklMXcPUYpv9z5iI)GHTkJQYoMuUSw7kpWFzQlIyhKCmi3dxwRDLh4Vm1frSdsowHtJWuxAOCdNJklMXcPUYpv9zPzebPU85KRPgQgk3W5OYY2H9f6ZGufsSSQOK(jtWwPomvvoI4FUOjtGgk3W5OYY2H9f6ZGufsS8PQplkPFYeSvQdtv3aY3rjG(wiPKWnuUHZrLLTd7l0NbPkKy5tvFwus)KjyRuhMQUGJTw)NOVlLjCIDohTHYnCoQSSDyFH(mivHelFQ6ZIs6NmbBL6Wuvr1u7Ps7)c23PZdq(L1UriMKnuUHZrLLTd7l0NbPkKy5tvFwus)KjyRuhMQsVJkhr83sAOgQgk3W5OYY2bcxWoG(RaATQLetF2tLBOCdNJklBhiCb7a6VcO1NQ(82bc)Yre3q5gohvw2oq4c2b0FfqRpv951HZrBOCdNJklBhiCb7a6VcO1NQ(CucOx8m7gk3W5OYY2bcxWoG(RaA9PQp)INz)JebXAOCdNJklBhiCb7a6VcO1NQ(8lbKeqyQlnuUHZrLLTdeUGDa9xb06tvF24y83nCo6hNs2k1HPQMXcPUYwjzqA4QOBvgv1AMXcPUYfLmGbpGDdLB4Cuzz7aHlyhq)vaT(u1NLIWWJ(3oq4c2budvdLB4CuzztypgT)mivHelRkkPFYeSvQdtvj41yaYX)bSvxnKvzuvunJfsDLlAUuZ)iNG0mdEpX1ICeXFWWfab7PkHM9OeA2SHQzSqQRCXcPCDmaKMzW7jUws4vs3PU8no7sgmR1ubqWEQsOzpkHMnBOAglK6kxuYag8a22SzglK6kxegdKUAZMzSqQRCrhLqRHYnCoQSSjShJ2FgKQqILpv9zrj9tMGTsDyQQuuFXZS)omX1XKSvzuvunJfsDLlAUuZ)iNG0mdEpX1ICeXFWWfab7PkHgeenB2q1mwi1vUyHuUogasZm49exlj8kP7ux(gNDjdM1AQaiypvj0GGOzZgQMXcPUYfLmGbpGTnBMXcPUYfHXaPR2SzglK6kx0rj0AOCdNJklBc7XO9NbPkKy5tvFwus)KjyRuhMQkhrmMyo1Lpq8nMvzuvunJfsDLlAUuZ)iNG0mdEpX1ICeXFWWfab7PkHgkenB2q1mwi1vUyHuUogasZm49exlj8kP7ux(gNDjdM1AQaiypvj0qHOzZgQMXcPUYfLmGbpGTnBMXcPUYfHXaPR2SzglK6kx0rj0AOCdNJklBc7XO9NbPkKy5tvFwus)KjyRuhMQkR99eN2)b8(NOppayszRYOQOAglK6kx0CPM)robPzg8EIRf5iI)GHlac2tvcThGMnBOAglK6kxSqkxhdaPzg8EIRLeEL0DQlFJZUKbZAnvaeSNQeApanB2q1mwi1vUOKbm4bSTzZmwi1vUimgiD1MnZyHux5IokHwdvdLB4Cuzzp8FfqRv9LrJzvgvDpCXxgnwbqWEQsOHcH0mdEpX1IuegE0)2bcxWoGkac2tvkG9WfFz0yfab7PkBOCdNJkl7H)RaA9PQplZ16r)4mISkJQUhUiZ16r)4mIkac2tvcnuiKMzW7jUwKIWWJ(3oq4c2bubqWEQsbShUiZ16r)4mIkac2tv2q5gohvw2d)xb06tvFwuLS)IPVhfHtdNJAvgvDpCruLS)IPVhfHtdNJwaeSNQeAOqinZG3tCTifHHh9VDGWfSdOcGG9uLcypCruLS)IPVhfHtdNJwaeSNQSHYnCoQSSh(VcO1NQ(SzaaXvoh1QmQ6E4IzaaXvohTaiypvj0qHqAMbVN4Arkcdp6F7aHlyhqfab7PkfWE4IzaaXvohTaiypvzdvdLB4CuzjzcUQOK(jtWYgQgk3W5OYIsgW8HJx1Ids)ftwPomvDpS8ZPryQlwzXXIu19WfZaaIRCoAbqWEQsbypK7Hl(YOXkac2tvka7HCpCruLS)IPVhfHtdNJwaeSNQua2djQwJDmPCrMR1J(XzezZ2E4ImxRh9JZiQaiypvPaShTgkuSVkbPkKyzFoox0(INCDFqiK(IgqFi1(EI3h0d8lWnKv99Wp2x0a67HGlQCPHYnCoQSOKbmF44pv9zloi9xmzL6WuvgKQqI)Bc7XSYIJfPQMzW7jUwwRDLh4Vm1frSdsowbqWEQsRS4yr6tyjv1mdEpX1YMmjSZPU8FhmxaeSNQ0QzTQK4mYkZO7KZrRYoMuUiR99e)tWVa3qwLrvnJfsDLlkzadEa7gkuSVhfbAFYre3NS2bBzFzuFCn1xuUuZ9fpX4(EP(iDN6sFYz0sdLB4Cuzrjdy(WXFQ6ZWoMIsZh4RSiGSkJQYjm955VtcAeetgrM(Cctpu5iI)YAhSHCpCruLS)IPVhfHtdNJw40im1LgkuSpiYLCF1UOY9XtFakcqY6(EPObq9f5y8efvAOCdNJklkzaZho(tvFU2fv2QmQ6E4sTlQCbqWEQsOz)teetgrM(CctnuOyFpeYL6(Ga9TcYbKCS(GWOG(aueGK19Lr9jxjDN6sFJs9TGNxh3x8reV7Z4IsQprzF80hCkL9X1uFZ66ayrn5y9XtFakcqY6(GWOGsFnuUHZrLfLmG5dh)PQpd7ykknFGVYIaYQmQkNWKaSEq(kgfvGDmfLMFCGZ1fab7PkH2IzxGDi(jcIjJitFoHPgkuSVhYeq9TjShJ29XGufsSSVu7Zvon5QZ5O9nr99WKjHDo1L(ECWCPHYnCoQSOKbmF44pv9zrj9tMGTsDyQkbVgdqo(pGT6QHSkJQAXbP)IPcdsviX)nH9yqZEuQHYnCoQSOKbmF44pv9zrj9tMGTsDyQQuuFXZS)omX1XKSvzuvloi9xmvyqQcj(VjShdAqWgk3W5OYIsgW8HJ)u1NfL0pzc2k1HPQYreJjMtD5deFJzvgv1Ids)ftfgKQqI)Bc7XGgkSHYnCoQSOKbmF44pv9zrj9tMGTsDyQQ6WuvzTVN40(pG3)e95batkBvgv1Ids)ftfgKQqI)Bc7XG2dAOqX(eyr9X1uFRypgb6lL9jktDPVhcUOYw1xucO(Gqi9nAFMzW7jU2hxtAFrdgpX7lEY199Wp2q5gohvwuYaMpC8NQ(8ATR8a)LPUiIDqYXSkJQYoMuUu7IkdPfhK(lMk7HLFonctDPHYnCoQSOKbmF44pv95nzsyNtD5)oy2QmQk7ys5sTlQmKMzW7jUwwRDLh4Vm1frSdsowbqWEQsbGsnuOyFcSO(4AQVvShJa9LY(eLPU0hc0Jv9fLaQVh(X(gTpZm49ex7JRjTVObJN4PU0x8KR7dcH0q5gohvwuYaMpC8NQ(8MmjSZPU8FhmBvgvLDmPCrw77j(NGFbUHG0Ids)ftL9WYpNgHPU0q5gohvwuYaMpC8NQ(8ATR8a)LPUiIDqYXSkJQYoMuUiR99e)tWVa3qqAMbVN4AztMe25ux(VdMlac2tvkauQHYnCoQSOKbmF44pv9zrvY(lM(EueonCoQvzu19WfrvY(lM(EueonCoAbqWEQsObbBOCdNJklkzaZho(tvF2xgnMvzu19WfFz0yfab7PkH2dAOCdNJklkzaZho(tvFwMR1J(XzezvgvDpCrMR1J(XzevaeSNQeApOHYnCoQSOKbmF44pv9zZaaIRCoQvzu19WfZaaIRCoAbqWEQsO9GgkuSpbofbizDFqyuqFEetG(4AQVzLuc0xg132bcxWoG(RaATV4JiE3NXfLuFIY(4Pp4uk7Z7dcJc6dqrasw3q5gohvwuYaMpC8NQ(mSJPO08b(klciRYOQCctcW6b5Ryuub2XuuA(XboxxaeSNQeA2)qxm7cSdXprqmzez6Zjm1qHI9brog332bcxWoG(RaATVmQpiuTR8a3hsQlIyhKCS(szFgraGughRponctDPHYnCoQSOKbmF44pv9zJJXF3W5OFCkzRuhMQUDGWfSdO)kGwTsYG0Wvr3QmQ6E4YATR8a)LPUiIDqYXkCAeM6sdfk2N1hN406p1NRX6B4Ac0NKDUpgKQqIL9Lr9bHQDLh4(qsDre7GKJ1xk7JtJWuxAOCdNJklkzaZho(tvF24y83nCo6hNs2k1HPQs25pdsviXsRKminCv0TkJQUhUSw7kpWFzQlIyhKCScNgHPU0qHI9HWUryFqyhtrPPpuaW56(4PVkAvFdOpafbizDFXRjTVfI5ux6dpX7d1CtoghRp8mctDPVOb0N3NXXgrSZ0Upve(Law13Ri33dkwNSpab7PM6sFPSpUM6dqsrm33e1htso1L(INCDFvAV1dTgk3W5OYIsgW8HJ)u1NHDmfLMpWxzrazvgvLtysawpir9vmkQa7ykkn)4aNRls2ncHwfTz7vmkQa7ykkn)4aNRlac2tvcThuSo0AOqX(eO7DY5OoUpiSaVp5kPBzFXRjTpcIzG3NS2bBzFoG6ZT4j2FXuFUU7JsUMa9bHQDLh4(qsDre7GKJ1xk7JtJWuxSQVb0hxt9fLl1CFPSps3PUuAOCdNJklkzaZho(tvFg2XuuA(aFLfbKvzuvu3dxwRDLh4Vm1frSdsowHtJWuxSzJty6ZZFNe0mZG3tCTSw7kpWFzQlIyhKCScGG9uLObjQVIrrfyhtrP5hh4CDrYUri0QOnBYre)L1oyla0rRHcf7tGU3jNJ64(EyGNAFiJiUpJl5(IxtAFqiK(szFCAeM6sdLB4Cuzrjdy(WXFQ6ZBGN6xoIyRYOQ7HlR1UYd8xM6Ii2bjhRWPryQlnuOyFq3eVpiqFRGCajhRV9W9bOiajR7lEnP9bOiajR9xmvAOCdNJklkzaZho(tvF2xgnMvzuvafbizT)IPgk3W5OYIsgW8HJ)u1Nfvj7Vy67rr40W5OwLrvbueGK1(lMAOCdNJklkzaZho(tvF2maG4kNJAvgvfqrasw7VyQHYnCoQSOKbmF44pv9zzUwp6hNrKvzuv2XKYfzUwp6hNreKakcqYA)ftnuOyFpKyswBaEe3hp9b7PYEQ9jqEWoNyQpKbBHuU0q5gohvwuYaMpC8NQ(CeMK1gGhXwLrvLJi(n1DXYGDoX0xoylKYwzC1q4Fgv9vmkQyzWoNy6lhSfs5FTiSRtUlIRnuOyFq3ehcScYbKCS(QDrL7dqraswxAOCdNJklkzaZho(tvFU2fv2QmQ6E4sTlQCbqWEQsOvXgkuSpRpnvMaaXvoFXuFpmsFMAxvc3xg1xCQVA3c1hxt99Wp23RyuuPHYnCoQSOKbmF44pv95nWt9lhrSvzu1xXOOYMmjSZPU8FhmxexBOCdNJklkzaZho(tvFEd8u)YreBvgvLDmPCrw77j(NGFbUHGCtVIrrfzTVN4Fc(f4gQaiypvj0QOnBB6vmkQiR99e)tWVa3qfj7gHqRIwLktaG4k)ZOQB6vmkQiR99e)tWVa3qfj7gHcOAfHCtVIrrfzTVN4Fc(f4gQaiypvPaQydLB4Cuzrjdy(WXFQ6ZBGN6xoIyRsLjaqCLRIEdLB4Cuzrjdy(WXFQ6ZYAFpX)VdMBOAOCdNJklsQATlQCdLB4Cuzrspv95nWt9lhrSvPYeaiUY)f8864QOBvQmbaIR8pJQUPxXOOIS23t8pb)cCdvKSBekGQvSHYnCoQSiPNQ(SS23t8)7G5gQgk3W5OYIKD(ZGufsSSQOK(jtWwPomvnvPbiY(lM(qFrxzr4)MSKgQHYnCoQSizN)mivHelFQ6ZIs6NmbBL6Wu1uLmq0Wdq(3PLuP)lHXnuUHZrLfj78NbPkKy5tvFwus)KjyRuhMQowiqeEIN6Y31e2)gFHAOCdNJkls25pdsviXYNQ(SOK(jtWwPomvD7aHWZO)nze(xfzajnKAOgk3W5OYIKD(ZGufsS8PQplkPFYeSvQdtvHDJ)cOVSMi(dlkttdLB4CuzrYo)zqQcjw(u1NfL0pzc2k1HPQryhM(t0)1zgtnuUHZrLfj78NbPkKy5tvFwus)KjyRuhMQg3fskbK)iWO7gk3W5OYIKD(ZGufsS8PQplkPFYeSvQdtvz)ft8FI(BsU6jOHYnCoQSizN)mivHelFQ6ZIs6NmbBL6WuvzQrI4VlxtGRS8)67f6pr)icmMKJ1q5gohvwKSZFgKQqILpv9zrj9tMGTsDyQQm1ir8Fb7705bi)V(EH(t0pIaJj5ynuUHZrLfj78NbPkKy5tvF(fpZ(hjcI1q5gohvwKSZFgKQqILpv95OeqV4z2nuUHZrLfj78NbPkKy5tvF(Lascim1LgQgkuSpua13Eub5(KIRRdG7Rfi1(CzFva6vG3xQ9bDIUv9jN(eycAH6ZmQfcW0UpUoL9XtFoi5AyIttPHYnCoQSWGufs8xUIt(BQjJWQwCq6VyYk1HPQYvYKo(tqFXCDL2wzXXIuvurf9hkb9fZ1vAxi41yaYX)bSvxneApHk6puc6lMRR0UKQ0aez)ftFOVORSi8FtwsdH2tOI(dLG(I56kTlYreJjMtD5deFJH2tOI(dLG(I56kTlsr9fpZ(7WexhtYOHwv0BOCdNJklmivHe)LR4K)MAYi8PQpBXbP)IjRuhMQYGufs8FuYklowKQIkdsviXf0l1U8VcgdKmivHexqVu7YVzg8EIRO1q5gohvwyqQcj(lxXj)n1Kr4tvF2Ids)ftwPomvLbPkK4phFSYIJfPQOYGufsCX(sTl)RGXajdsviXf7l1U8BMbVN4kAnuUHZrLfgKQqI)YvCYFtnze(u1NT4G0FXKvQdtv3oSVqFgKQqITYIJfPQOAnuzqQcjUGEP2L)vWyGKbPkK4c6LAx(nZG3tCfn0SzdvRHkdsviXf7l1U8VcgdKmivHexSVu7YVzg8EIROHMnBe0xmxxPDzbhBT(prFxkt4e7CoAdLB4CuzHbPkK4VCfN83utgHpv9zloi9xmzL6WuvgKQqI)YvCYwzXXIuvuT4G0FXuHbPkK4)OeKwCq6VyQSDyFH(mivHeJMnBOAXbP)IPcdsviXFo(aPfhK(lMkBh2xOpdsviXOzZgQO)qT4G0FXuHbPkK4)OeApHk6puloi9xmvKRKjD8NG(I56kTrRk62SHk6puloi9xmvyqQcj(ZXh0Ecv0FOwCq6VyQixjt64pb9fZ1vAJwv0diwiGmhnyN9OK92Js2Bp6bK4oqtDrgqqbcubUDcm7eibL7RVkRP(s41bW9fnG(eKbPkK4VCfN83utgHc2hGG(IjG29jhyQpxKhyNPDFMAxxizPHc6sL6ZEuUpiAuleGPDFcYGufsCb9sfeSpE6tqgKQqIlm6LkiyFOApeJwPHc6sL6RIOCFq0Owiat7(eKbPkK4I9LkiyF80NGmivHexy7lvqW(q1EigTsdf0Lk13dq5(GOrTqaM29jidsviXf0lvqW(4PpbzqQcjUWOxQGG9HQ9qmALgkOlvQVhGY9brJAHamT7tqgKQqIl2xQGG9XtFcYGufsCHTVubb7dv7Hy0knunuOabQa3obMDcKGY91xL1uFj86a4(IgqFcAglK6klyFac6lMaA3NCGP(CrEGDM29zQDDHKLgkOlvQp0r5(GOrTqaM29ji7ys5sfeSpE6tq2XKYLkui1FX0wW(qfDigTsdf0Lk1h6OCFq0Owiat7(e0m6wm5sfeSpE6tqZOBXKlvOqQ)IPTG9Hk6qmALgkOlvQp7r5(GOrTqaM29ji7ys5sfeSpE6tq2XKYLkui1FX0wW(qfDigTsdf0Lk1xfr5(GOrTqaM29ji7ys5sfeSpE6tq2XKYLkui1FX0wW(qfDigTsdf0Lk13dq5(GOrTqaM29ji7ys5sfeSpE6tq2XKYLkui1FX0wW(qfDigTsdf0Lk13dq5(GOrTqaM29jOz0TyYLkiyF80NGMr3IjxQqHu)ftBb7dv0Hy0knuqxQuFwhk3henQfcW0UpbzhtkxQGG9XtFcYoMuUuHcP(lM2c2hQOdXOvAOAOqbcubUDcm7eibL7RVkRP(s41bW9fnG(eCtrUiMfSpab9ftaT7toWuFUipWot7(m1UUqYsdf0Lk1N1HY9brJAHamT7tq2XKYLkiyF80NGSJjLlvOqQ)IPTG95CFqpqVqxFOIoeJwPHc6sL6Z6q5(GOrTqaM29jiquPObSqLkiyF80NGarLIgWcvQqHu)ftBb7dv0Hy0knuqxQuFOquUpiAuleGPDFcYoMuUubb7JN(eKDmPCPcfs9xmTfSpN7d6b6f66dv0Hy0knuqxQuFceOCFq0Owiat7(eKbPkK4c6LkiyF80NGmivHexy0lvqW(q9bqmALgkOlvQpbcuUpiAuleGPDFcYGufsCX(sfeSpE6tqgKQqIlS9LkiyFO(aigTsdf0Lk1h6OJY9brJAHamT7tq2XKYLkiyF80NGSJjLlvOqQ)IPTG9HQ9qmALgkOlvQp0ThL7dIg1cbyA3NGSJjLlvqW(4PpbzhtkxQqHu)ftBb7dv0Hy0knuqxQuFO)auUpiAuleGPDFcYoMuUubb7JN(eKDmPCPcfs9xmTfSpurhIrR0qbDPs9HU1HY9brJAHamT7tqgKQqIl(RPyMbVN4QG9XtFcAMbVN4AXFnc2hQOdXOvAOGUuP(qhcIY9brJAHamT7tqgKQqIl(RPyMbVN4QG9XtFcAMbVN4AXFnc2hQOdXOvAOGUuP(q36HY9brJAHamT7tqGOsrdyHkvqW(4PpbbIkfnGfQuHcP(lM2c2hQOdXOvAOGUuP(q36HY9brJAHamT7tqgKQqIl(RPyMbVN4QG9XtFcAMbVN4AXFnc2hQOdXOvAOGUuP(qhfIY9brJAHamT7tqGOsrdyHkvqW(4PpbbIkfnGfQuHcP(lM2c2hQOdXOvAOGUuP(qhfIY9brJAHamT7tqgKQqIl(RPyMbVN4QG9XtFcAMbVN4AXFnc2hQOdXOvAOGUuP(SVIOCFq0Owiat7(eKDmPCPcc2hp9ji7ys5sfkK6VyAlyFOIoeJwPHc6sL6Z(hGY9brJAHamT7tq2XKYLkiyF80NGSJjLlvOqQ)IPTG9Hk6qmALgkOlvQp7fiq5(GOrTqaM29ji7ys5sfeSpE6tq2XKYLkui1FX0wW(q1EigTsdf0Lk1xfrhL7dIg1cbyA3NGSJjLlvqW(4PpbzhtkxQqHu)ftBb7dv7Hy0knuqxQuFv0EuUpiAuleGPDFcYoMuUubb7JN(eKDmPCPcfs9xmTfSpurhIrR0qbDPs9vXkIY9brJAHamT7tq2XKYLkiyF80NGSJjLlvOqQ)IPTG9Hk6qmALgkOlvQVkcbr5(GOrTqaM29jiquPObSqLkiyF80NGarLIgWcvQqHu)ftBb7dv0Hy0knuqxQuFv06HY9brJAHamT7tqGOsrdyHkvqW(4PpbbIkfnGfQuHcP(lM2c2hQOdXOvAOGUuP(QikeL7dIg1cbyA3NGarLIgWcvQGG9XtFccevkAaluPcfs9xmTfSpurhIrR0qbDPs9vrbcuUpiAuleGPDFcYoMuUubb7JN(eKDmPCPcfs9xmTfSpurhIrR0qbDPs9vrbcuUpiAuleGPDFccevkAaluPcc2hp9jiquPObSqLkui1FX0wW(qfDigTsdf0Lk13dqjuUpiAuleGPDFcYoMuUubb7JN(eKDmPCPcfs9xmTfSpN7d6b6f66dv0Hy0knuqxQuFpacIY9brJAHamT7tq2XKYLkiyF80NGSJjLlvOqQ)IPTG9HQ9qmALgkOlvQVhy9q5(GOrTqaM29jOCeXVPUlvqW(4PpbLJi(n1DPcfs9xmTfSpN7d6b6f66dv0Hy0knunuOabQa3obMDcKGY91xL1uFj86a4(IgqFc6djyFac6lMaA3NCGP(CrEGDM29zQDDHKLgkOlvQVkIY9brJAHamT7tq2XKYLkiyF80NGSJjLlvOqQ)IPTG9HQ9qmALgkOlvQVhGY9brJAHamT7tq2XKYLkiyF80NGSJjLlvOqQ)IPTG9Hk6qmALgkOlvQpRdL7dIg1cbyA3NGSJjLlvqW(4PpbzhtkxQqHu)ftBb7dv0Hy0knuqxQuFOBpk3henQfcW0UpbzhtkxQGG9XtFcYoMuUuHcP(lM2c2hQveIrR0qbDPs9HEfr5(GOrTqaM29ji7ys5sfeSpE6tq2XKYLkui1FX0wW(qfDigTsdf0Lk1h6OquUpiAuleGPDFcYoMuUubb7JN(eKDmPCPcfs9xmTfSpN7d6b6f66dv0Hy0knuqxQuF2JsOCFq0Owiat7(eKDmPCPcc2hp9ji7ys5sfkK6VyAlyFo3h0d0l01hQOdXOvAOGUuP(ShDuUpiAuleGPDFcYoMuUubb7JN(eKDmPCPcfs9xmTfSpN7d6b6f66dv0Hy0knuqxQuF2dbr5(GOrTqaM29jOCeXVPUlvqW(4PpbLJi(n1DPcfs9xmTfSpN7d6b6f66dv0Hy0knunuOabQa3obMDcKGY91xL1uFj86a4(IgqFcQKbmF44c2hGG(IjG29jhyQpxKhyNPDFMAxxizPHc6sL6dDuUpiAuleGPDFcYoMuUubb7JN(eKDmPCPcfs9xmTfSpurhIrR0qbDPs9zpk3henQfcW0UpbzhtkxQGG9XtFcYoMuUuHcP(lM2c2NZ9b9a9cD9Hk6qmALgkOlvQpbcuUpRpvkUUoaM29jkPFYeCFUHZr7Z6x9Pomvvw77joT)d49prFEaWKYcKI1V7JugeRVDk9xmTlnuqxQuFOJsOCFq0Owiat7(eKDmPCPcc2hp9ji7ys5sfkK6VyAlyFOIoeJwPHc6sL6dD0r5(GOrTqaM29ji7ys5sfeSpE6tq2XKYLkui1FX0wW(qfDigTsdf0Lk1h62JY9brJAHamT7tq2XKYLkiyF80NGSJjLlvOqQ)IPTG9Hk6qmALgkOlvQp0Rik3henQfcW0UpbzhtkxQGG9XtFcYoMuUuHcP(lM2c2hQOdXOvAOGUuP(S36HY9brJAHamT7tq2XKYLkiyF80NGSJjLlvOqQ)IPTG9Hk6qmALgkOlvQp7rHOCFq0Owiat7(euoI43u3LkiyF80NGYre)M6UuHcP(lM2c2NZ9b9a9cD9Hk6qmALgkOlvQVkIok3henQfcW0UpbzhtkxQGG9XtFcYoMuUuHcP(lM2c2hQOdXOvAOAOeyWRdGPDFOxX(CdNJ2hoLSS0qfqWPKLHkdis25pdsviXYqLb7qpuzaHu)ft7WJbe1HPasQsdqK9xm9H(IUYIW)nzjnuaXnCoAajvPbiY(lM(qFrxzr4)MSKgkWb7SpuzaHu)ft7WJbe1HPasQsgiA4bi)70sQ0)LW4aIB4C0asQsgiA4bi)70sQ0)LW4ahSRIHkdiK6VyAhEmGOomfqgleicpXtD57Ac7FJVqbe3W5ObKXcbIWt8ux(UMW(34luGd29GqLbes9xmTdpgquhMciBhieEg9VjJW)QidiPHudfqCdNJgq2oqi8m6FtgH)vrgqsdPgkWb7SUqLbes9xmTdpgquhMciWUXFb0xwte)HfLPjG4gohnGa7g)fqFznr8hwuMMahSdcgQmGqQ)IPD4XaI6Wuajc7W0FI(VoZykG4gohnGeHDy6pr)xNzmf4GDwVqLbes9xmTdpgquhMciXDHKsa5pcm6oG4gohnGe3fskbK)iWO7ahSdfgQmGqQ)IPD4XaI6WuaH9xmX)j6Vj5QNGaIB4C0ac7VyI)t0FtYvpbboyNarOYacP(lM2HhdiQdtbezQrI4VlxtGRS8)67f6pr)icmMKJfqCdNJgqKPgjI)UCnbUYY)RVxO)e9JiWysowGd2HokfQmGqQ)IPD4XaI6WuarMAKi(VG9D68aK)xFVq)j6hrGXKCSaIB4C0aIm1ir8Fb7705bi)V(EH(t0pIaJj5yboyh6OhQmG4gohnG8INz)JebXciK6VyAhEmWb7q3(qLbe3W5ObKOeqV4z2bes9xmTdpg4GDOxXqLbe3W5ObKxcijGWuxciK6VyAhEmWboGWGufs8xUIt(BQjJWqLb7qpuzaHu)ft7WJbKznGijoG4gohnGyXbP)IPaIfhlsbeu7d1(qVVhAFe0xmxxPDHGxJbih)hWwD1q9HwFp1hQ9HEFp0(iOVyUUs7sQsdqK9xm9H(IUYIW)nzjnuFO13t9HAFO33dTpc6lMRR0UihrmMyo1Lpq8nwFO13t9HAFO33dTpc6lMRR0Uif1x8m7VdtCDmj3hA9HwFv7d9aYMKgqUY5Obeua13Eub5(KIRRdG7lGyXbF1HPaICLmPJ)e0xmxxPDGd2zFOYacP(lM2HhdiZAarsCaXnCoAaXIds)ftbelowKciO2hdsviXfg9sTl)RGX0hK9XGufsCHrVu7YVzg8EIR9HwaXId(QdtbegKQqI)Jsboyxfdvgqi1FX0o8yazwdisIdiUHZrdiwCq6VykGyXXIuab1(yqQcjUW2xQD5FfmM(GSpgKQqIlS9LAx(nZG3tCTp0ciwCWxDykGWGufs8NJpboy3dcvgqi1FX0o8yazwdisIdiUHZrdiwCq6VykGyXXIuab1(SwFO2hdsviXfg9sTl)RGX0hK9XGufsCHrVu7YVzg8EIR9HwFO1NnB9HAFwRpu7JbPkK4cBFP2L)vWy6dY(yqQcjUW2xQD53mdEpX1(qRp06ZMT(iOVyUUs7Yco2A9FI(UuMWj25C0aIfh8vhMciBh2xOpdsviXboyN1fQmGqQ)IPD4XaYSgqKehqCdNJgqS4G0FXuaXIJfPacQ9zXbP)IPcdsviX)rP(GSploi9xmv2oSVqFgKQqI7dT(SzRpu7ZIds)ftfgKQqI)C8Ppi7ZIds)ftLTd7l0NbPkK4(qRpB26d1(qVVhAFwCq6VyQWGufs8FuQp067P(qTp077H2NfhK(lMkYvYKo(tqFXCDL29HwFv7d9(SzRpu7d9(EO9zXbP)IPcdsviXFo(0hA99uFO2h699q7ZIds)ftf5kzsh)jOVyUUs7(qRVQ9HEaXId(QdtbegKQqI)YvCYboWbKTd7l0NbPkKyzOYGDOhQmGqQ)IPD4XaI6WuaroI4FUOjtGaIB4C0aICeX)CrtMaboyN9HkdiK6VyAhEmGOomfq2aY3rjG(wiPKWbe3W5ObKnG8DucOVfskjCGd2vXqLbes9xmTdpgquhMcil4yR1)j67szcNyNZrdiUHZrdil4yR1)j67szcNyNZrdCWUheQmGqQ)IPD4XaI6Wuarun1EQ0(VG9D68aKFzTBeIjzaXnCoAarun1EQ0(VG9D68aKFzTBeIjzGd2zDHkdiK6VyAhEmGOomfqO3rLJi(BjnuaXnCoAaHEhvoI4VL0qboWbKnH9y0(ZGufsSmuzWo0dvgqi1FX0o8yaXnCoAaHGxJbih)hWwD1qbedizcKEab1(mJfsDLlAUuZ)iN6dY(mZG3tCTihr8hmCbqWEQY(GwF2Js9HwF2S1hQ9zglK6kxSqkxhd0hK9zMbVN4AjHxjDN6Y34SlzWSwtfab7Pk7dA9zpk1hA9zZwFO2NzSqQRCrjdyWdy3NnB9zglK6kxegdKU2NnB9zglK6kx0rP(qlGOomfqi41yaYX)bSvxnuGd2zFOYacP(lM2HhdiUHZrdisr9fpZ(7WexhtYbedizcKEab1(mJfsDLlAUuZ)iN6dY(mZG3tCTihr8hmCbqWEQY(GwFqW(qRpB26d1(mJfsDLlwiLRJb6dY(mZG3tCTKWRKUtD5BC2LmywRPcGG9uL9bT(GG9HwF2S1hQ9zglK6kxuYag8a29zZwFMXcPUYfHXaPR9zZwFMXcPUYfDuQp0ciQdtbePO(INz)DyIRJj5ahSRIHkdiK6VyAhEmG4gohnGihrmMyo1Lpq8nwaXasMaPhqqTpZyHux5IMl18pYP(GSpZm49exlYre)bdxaeSNQSpO1hkSp06ZMT(qTpZyHux5Ifs56yG(GSpZm49exlj8kP7ux(gNDjdM1AQaiypvzFqRpuyFO1NnB9HAFMXcPUYfLmGbpGDF2S1NzSqQRCrymq6AF2S1NzSqQRCrhL6dTaI6WuaroIymXCQlFG4BSahS7bHkdiK6VyAhEmG4gohnGiR99eN2)b8(NOppays5aIbKmbspGGAFMXcPUYfnxQ5FKt9bzFMzW7jUwKJi(dgUaiypvzFqRVh0hA9zZwFO2NzSqQRCXcPCDmqFq2Nzg8EIRLeEL0DQlFJZUKbZAnvaeSNQSpO13d6dT(SzRpu7Zmwi1vUOKbm4bS7ZMT(mJfsDLlcJbsx7ZMT(mJfsDLl6OuFOfquhMciYAFpXP9FaV)j6ZdaMuoWboGSDGWfSdO)kGwdvgSd9qLbe3W5ObeljM(SNkhqi1FX0o8yGd2zFOYaIB4C0aY2bc)Yrehqi1FX0o8yGd2vXqLbe3W5ObK1HZrdiK6VyAhEmWb7EqOYaIB4C0asucOx8m7acP(lM2HhdCWoRluzaXnCoAa5fpZ(hjcIfqi1FX0o8yGd2bbdvgqCdNJgqEjGKactDjGqQ)IPD4XahSZ6fQmGqQ)IPD4XaIbKmbspGyT(mJfsDLlkzadEa7aIKbPHd2HEaXnCoAaX4y83nCo6hNsoGGtj)vhMciMXcPUYboyhkmuzaXnCoAarkcdp6F7aHlyhqbes9xmTdpg4ahqmJfsDLdvgSd9qLbes9xmTdpgqmGKjq6beR1h7ys5YATR8a)LPUiIDqYXkK6VyA3hK9HAFMzW7jUwKIWWJ(3oq4c2bubqWEQY(GwFOJs9zZwFMzW7jUwKIWWJ(3oq4c2bubqWEQY(eqFwhk1NnB9zMbVN4Arkcdp6F7aHlyhqfab7Pk7ta9zV11hK9zgDlMCXmaG4kN6YhteOqQ)IPDFOfqCdNJgqs4vs3PU8no7sgmR1uGd2zFOYacP(lM2HhdigqYei9ac7ys5YATR8a)LPUiIDqYXkK6VyA3hK9ThUSw7kpWFzQlIyhKCScNgHPUeqCdNJgqs4vs3PU8no7sgmR1uGd2vXqLbes9xmTdpgqmGKjq6beZm49exlsry4r)BhiCb7aQaiypvzFcOpRRpi7d1(20RyuuP2fvUaiypvzFcOVh0NnB9zT(yhtkxQDrLlK6VyA3hAbe3W5ObKnzsyNtD5)oyoWb7EqOYacP(lM2HhdigqYei9aI16JDmPCzT2vEG)YuxeXoi5yfs9xmT7dY(qTpZm49exlsry4r)BhiCb7aQaiypvzFqRpRRpB26ZmdEpX1IuegE0)2bcxWoGkac2tv2Na6Z6qP(SzRpZm49exlsry4r)BhiCb7aQaiypvzFcOp7TU(GSpZOBXKlMbaex5ux(yIafs9xmT7dTaIB4C0aICeXFWWboyN1fQmGqQ)IPD4XaIbKmbspGWoMuUSw7kpWFzQlIyhKCScP(lM29bzF7HlR1UYd8xM6Ii2bjhRWPryQlbe3W5Obe5iI)GHdCWoiyOYaIB4C0aI0mIGux(CY1uaHu)ft7WJboWbK9W)vaTgQmyh6HkdiK6VyAhEmGyajtG0di7Hl(YOXkac2tv2h06df2hK9zMbVN4Arkcdp6F7aHlyhqfab7Pk7ta9ThU4lJgRaiypvzaXnCoAaXxgnwGd2zFOYacP(lM2HhdigqYei9aYE4ImxRh9JZiQaiypvzFqRpuyFq2Nzg8EIRfPim8O)TdeUGDavaeSNQSpb03E4ImxRh9JZiQaiypvzaXnCoAarMR1J(Xzef4GDvmuzaHu)ft7WJbedizcKEazpCruLS)IPVhfHtdNJwaeSNQSpO1hkSpi7ZmdEpX1IuegE0)2bcxWoGkac2tv2Na6BpCruLS)IPVhfHtdNJwaeSNQmG4gohnGiQs2FX03JIWPHZrdCWUheQmGqQ)IPD4XaIbKmbspGShUygaqCLZrlac2tv2h06df2hK9zMbVN4Arkcdp6F7aHlyhqfab7Pk7ta9ThUygaqCLZrlac2tvgqCdNJgqmdaiUY5OboWbKnf5IyouzWo0dvgqCdNJgqKReg)XJryaHu)ft7WJboyN9HkdiUHZrdiBYYic(W(sAciK6VyAhEmWb7QyOYacP(lM2HhdigqYei9aIB40c9jLGts2Na6RIbejdsdhSd9aIB4C0aIXX4VB4C0poLCabNs(Romfq8HcCWUheQmGqQ)IPD4XaIbKmbspG8kgfvmo2HtEeLFdGKgs3trCnG4gohnGa7ykknFGVYIakWb7SUqLbes9xmTdpgq2K0aYvohnGarog3NKwDGZuFUHZr7dNsUVOb0NDKbm4bS7dcJc6l1(qQS0hejcaKY4y9nkowFZkNWP1FA3x0a6tus9fp56(GqiLaIB4C0acqu)UHZr)4uYbejdsdhSd9aIbKmbspGyglK6kxuYag8a29bzFarLIgWcvGDmfLMFCGZ1fs9xmT7dY(CdNwOpPeCsY(Q2h69bzFSJjLlR1UYd8xM6Ii2bjhRqQ)IPDabNs(RomfquYaMpC8ahSdcgQmGqQ)IPD4XaYMKgqUY5ObebQHZr7dNsw2x0a6JbPkK4(EPA3soGsFiSZY(Ca1N0Tq7(IgqFVu0aO(qgrCFc8HFwGbVs6o1L(GiNDjdM1A6ziuTR8a3hsQlIyhKCmR6B4AcepLuFJ2Nzg8EIRLaIB4C0aIXX4VB4C0poLCabNs(RomfqyqQcj(lxXj)n1KryGd2z9cvgqi1FX0o8yaXnCoAaX4y83nCo6hNsoGGtj)vhMciBc7XO9NbPkKyzGd2Hcdvgqi1FX0o8yaXasMaPhqqTV9Wf5iI)GHlCAeM6sF2S13E4scVs6o1LVXzxYGzTM(7HlCAeM6sF2S13E4YATR8a)LPUiIDqYXkCAeM6sFO1hK9jhr8xw7GDFcOVk2NnB9ThUyjX0N9u5cNgHPU0NnB9XoMuUiN4FUM(sI2YcP(lM2bejdsdhSd9aIB4C0aIXX4VB4C0poLCabNs(RomfqKSZFgKQqILboyNarOYacP(lM2HhdigqYei9aIzSqQRCrZLA(h5uFq2hQ9zT(S4G0FXuHbPkK4VCfNCF2S1Nzg8EIRf5iI)GHlac2tv2Na6ZEuQpB26d1(S4G0FXuHbPkK4)OuFq2Nzg8EIRf5iI)GHlac2tv2h06JbPkK4cJEXmdEpX1cGG9uL9HwF2S1hQ9zXbP)IPcdsviXFo(0hK9zMbVN4AroI4py4cGG9uL9bT(yqQcjUW2xmZG3tCTaiypvzFO1hA9zZwFMXcPUYflKY1Xa9bzFO2N16ZIds)ftfgKQqI)YvCY9zZwFMzW7jUws4vs3PU8no7sgmR1ubqWEQY(eqF2Js9zZwFO2NfhK(lMkmivHe)hL6dY(mZG3tCTKWRKUtD5BC2LmywRPcGG9uL9bT(yqQcjUWOxmZG3tCTaiypvzFO1NnB9HAFwCq6VyQWGufs8NJp9bzFMzW7jUws4vs3PU8no7sgmR1ubqWEQY(GwFmivHexy7lMzW7jUwaeSNQSp06dT(SzRpu7Zmwi1vUOKbm4bS7ZMT(mJfsDLlcJbsx7ZMT(mJfsDLl6OuFO1hK9HAFwRploi9xmvyqQcj(lxXj3NnB9zMbVN4AzT2vEG)YuxeXoi5yfab7Pk7ta9zpk1NnB9HAFwCq6VyQWGufs8FuQpi7ZmdEpX1YATR8a)LPUiIDqYXkac2tv2h06JbPkK4cJEXmdEpX1cGG9uL9HwF2S1hQ9zXbP)IPcdsviXFo(0hK9zMbVN4AzT2vEG)YuxeXoi5yfab7Pk7dA9XGufsCHTVyMbVN4AbqWEQY(qRp06ZMT(SwFSJjLlR1UYd8xM6Ii2bjhRqQ)IPDFq2hQ9zT(S4G0FXuHbPkK4VCfNCF2S1Nzg8EIRfPim8O)TdeUGDavaeSNQSpb0N9OuF2S1hQ9zXbP)IPcdsviX)rP(GSpZm49exlsry4r)BhiCb7aQaiypvzFqRpgKQqIlm6fZm49exlac2tv2hA9zZwFO2NfhK(lMkmivHe)54tFq2Nzg8EIRfPim8O)TdeUGDavaeSNQSpO1hdsviXf2(Izg8EIRfab7Pk7dT(qlG4gohnGyCm(7goh9JtjhqWPK)QdtbKTd7l0NbPkKyzGd2HokfQmGqQ)IPD4XaIB4C0acSJPO08b(klcOaYMKgqUY5ObKhfbAFYre3NS2bBzFzuFr5sn3xk7ZXWJK7BSqGaIbKmbspG8oszFq2xuUuZFab7Pk7dA9rqmzez6Zjm13dTp5iI)YAhS7dY(2dxevj7Vy67rr40W5OfonctDjWb7qh9qLbes9xmTdpgq2K0aYvohnGiWI6Zmwi1vUV9WpdHQDLh4(qsDre7GKJ1xk7diQAQlw1NOK67HDGWfSdO(4PpcIzs39X1uFgraGuUpjXbe3W5ObeJJXF3W5OFCk5aIbKmbspGGAFMXcPUYflKY1Xa9bzF7Hlj8kP7ux(gNDjdM1A6VhUWPryQl9bzFMzW7jUwKIWWJ(3oq4c2bubqWEQY(GwF23hK9HAF7HlR1UYd8xM6Ii2bjhRaiypvzFcOp77ZMT(SwFSJjLlR1UYd8xM6Ii2bjhRqQ)IPDFO1hA9zZwFO2NzSqQRCrZLA(h5uFq23E4ICeXFWWfonctDPpi7ZmdEpX1IuegE0)2bcxWoGkac2tv2h06Z((GSpu7BpCzT2vEG)YuxeXoi5yfab7Pk7ta9zFF2S1N16JDmPCzT2vEG)YuxeXoi5yfs9xmT7dT(qRpB26d1(qTpZyHux5IsgWGhWUpB26Zmwi1vUimgiDTpB26Zmwi1vUOJs9HwFq23E4YATR8a)LPUiIDqYXkCAeM6sFq23E4YATR8a)LPUiIDqYXkac2tv2h06Z((qlGGtj)vhMciBhiCb7a6VcO1ahSdD7dvgqi1FX0o8yaztsdix5C0aIaNIaKSUV9WY(ihGJ1xg13YK6sFPYtFEFYAhS7tUs6o1L(wRDjfqCdNJgqmog)DdNJ(XPKdigqYei9acQ9zglK6kx0CPM)ro1hK9zT(2dxKJi(dgUWPryQl9bzFMzW7jUwKJi(dgUaiypvzFqRVh0hA9zZwFO2NzSqQRCXcPCDmqFq2N16BpCjHxjDN6Y34SlzWSwt)9WfonctDPpi7ZmdEpX1scVs6o1LVXzxYGzTMkac2tv2h067b9HwF2S1hQ9HAFMXcPUYfLmGbpGDF2S1NzSqQRCrymq6AF2S1NzSqQRCrhL6dT(GSp2XKYL1Ax5b(ltDre7GKJvi1FX0Upi7ZA9ThUSw7kpWFzQlIyhKCScNgHPU0hK9zMbVN4AzT2vEG)YuxeXoi5yfab7Pk7dA99G(qlGGtj)vhMci7H)RaAnWb7qVIHkdiK6VyAhEmG4gohnGSDGWVCeXbKnjnGCLZrdicSO(Gq1UYdCFiPUiIDqYX6lL9XPryQlw1xY9LY(KEe1hp9jkP(EyhiSpKrehqmGKjq6bK9WL1Ax5b(ltDre7GKJv40im1LahSd9heQmGqQ)IPD4XaIbKmbspGyT(yhtkxwRDLh4Vm1frSdsowHu)ft7(GSpu7BpCroI4py4cNgHPU0NnB9ThUKWRKUtD5BC2LmywRP)E4cNgHPU0hAbe3W5ObKTde(LJioWb7q36cvgqi1FX0o8yaXnCoAazT2vEG)YuxeXoi5ybKnjnGCLZrdiiXutFqOAx5bUpKuxeXoi5y9fp56(eitkxhd8SD5sn33dPt9zglK6k33EyR6B4AcepLuFIsQVr7ZmdEpX1sFcSO(GEGxJbih3h0lyRUAO(EfJI6lL9LQzGtDXQ(Qh8UprLtCFjlOSpa57y9Hk6OW(KKz0TSppIjqFIscTaIbKmbspGyglK6kx0CPM)ro1hK9Xjm1Na6Z66dY(mZG3tCTihr8hmCbqWEQY(GwFO3hK9HAFMzW7jUwi41yaYX)bSvxnubqWEQY(GwFOdbTVpB26ZA9rqFXCDL2fcEngGC8FaB1vd1hAboyh6qWqLbes9xmTdpgqmGKjq6beZyHux5Ifs56yG(GSpoHP(eqFwxFq2Nzg8EIRLeEL0DQlFJZUKbZAnvaeSNQSpO1h69bzFO2Nzg8EIRfcEngGC8FaB1vdvaeSNQSpO1h6qq77ZMT(SwFe0xmxxPDHGxJbih)hWwD1q9HwaXnCoAazT2vEG)YuxeXoi5yboyh6wVqLbes9xmTdpgqCdNJgqwRDLh4Vm1frSdsowaztsdix5C0aIDKbm4bS7lEY19bHDmfLM(qbaNR7Z4sw23ATR8a3Nm1frSdsowFP2hovQV4jx33dtMe25ux67XbZbedizcKEaXmwi1vUOKbm4bS7dY(aIkfnGfQa7ykkn)4aNRlK6VyA3hK9Xjm1Na6Z66dY(mZG3tCTSjtc7CQl)3bZfab7Pk7dA9vX(GSpu7ZmdEpX1cbVgdqo(pGT6QHkac2tv2h06dDiO99zZwFwRpc6lMRR0UqWRXaKJ)dyRUAO(qlWb7qhfgQmGqQ)IPD4XaIB4C0aYATR8a)LPUiIDqYXciBsAa5kNJgqGE5Ac0NzSqQRSSput1Gf3PU0NokeacJc6ZoYag06Z4sUpiesFJ2Nzg8EIRbedizcKEab1(mJfsDLlcJbsx7ZMT(mJfsDLl6OuF2S1hQ9zglK6kxuYag8a29bzFwRpGOsrdyHkWoMIsZpoW56cP(lM29HwFO1hK9HAFMzW7jUwi41yaYX)bSvxnubqWEQY(GwFOdbTVpB26ZA9rqFXCDL2fcEngGC8FaB1vd1hAboyh6ceHkdiK6VyAhEmGyajtG0diVJu2hK9fLl18hqWEQY(GwFOdbdiUHZrdiR1UYd8xM6Ii2bjhlWb7ShLcvgqi1FX0o8yaztsdix5C0aIalQpiuTR8a3hsQlIyhKCS(szFCAeM6Iv9LSGY(4eM6JN(eLuFdxtG(G9hIdOV9WYaIB4C0aIXX4VB4C0poLCarYG0Wb7qpGyajtG0di7HlR1UYd8xM6Ii2bjhRWPryQl9bzFO2NzSqQRCrZLA(h5uF2S1NzSqQRCXcPCDmqFOfqWPK)QdtbeZyHux5ahSZE0dvgqi1FX0o8yaXnCoAaXxgnwaXasMaPhq2dx8LrJvaeSNQSpO13dciMygm9zhSqSmyh6boyN92hQmG4gohnGu7Ikhqi1FX0o8yGd2zFfdvgqi1FX0o8yaXnCoAars0(prFZaaIRCoAaztsdix5C0acYeVpUM6dHOTSVr7RI9XoyHyzFzuFj3xkvb5(mIaaPmowFP2xeoxQ5(gqFJ2hxt9XoyH4sFOGKR7djxRhTpOlJO(swqzFowo99smtG(4Pprj1hcr7(gleOpyxfDmowF(6kowQl9vX(GObaex5CuzjGyajtG0diUHtl0NucojzFcOp77dY(yhtkxKt8pxtFjrBzHu)ft7(GSpR13E4IKO9FI(Mbaex5C0cNgHPU0hK9zT(s9hHZLAoWb7S)bHkdiK6VyAhEmGyajtG0diUHtl0NucojzFcOp77dY(yhtkxK5A9OFCgrfs9xmT7dY(SwF7HlsI2)j6BgaqCLZrlCAeM6sFq2N16l1FeoxQ5(GSV9WfZaaIRCoAbqWEQY(GwFpiG4gohnGijA)NOVzaaXvohnWb7S36cvgqi1FX0o8yaXasMaPhqqTp5iI)YAhS7ta9HEF2S1NB40c9jLGts2Na6Z((qRpi7ZmdEpX1IuegE0)2bcxWoGkac2tv2Na6dD7diUHZrdiwsm9zpvoWb7ShcgQmGqQ)IPD4XaIbKmbspG4goTq)9WfrvY(lM(EueonCoAFv7dL6ZMT(40im1L(GSV9WfrvY(lM(EueonCoAbqWEQY(GwFpiG4gohnGiQs2FX03JIWPHZrdCWo7TEHkdiK6VyAhEmG4gohnGiZ16r)4mIcigqYei9aYE4ImxRh9JZiQaiypvzFqRVheqmXmy6ZoyHyzWo0dCWo7rHHkdiK6VyAhEmGyajtG0diwRpZyHux5IsgWGhWoGizqA4GDOhqCdNJgqmog)DdNJ(XPKdi4uYF1HPaIzSqQRCGd2zVarOYacP(lM2HhdiUHZrdiMbaex5C0aIjMbtF2bleld2HEaXasMaPhqCdNwOpPeCsY(GwFpOpiqFO2h7ys5ICI)5A6ljAllK6VyA3NnB9XoMuUiZ16r)4mIkK6VyA3hA9bzF7HlMbaex5C0cGG9uL9bT(SpGSjPbKRCoAarGUUIJ1henaG4kNJ2hSRIoghRVr7dDiG99XoyHyPv9nG(gTVk2x8KR7tG(khSit9brdaiUY5OboyxfrPqLbes9xmTdpgqCdNJgqGDmfLMpWxzrafq2K0aYvohnGiqJyc0hxt9nRKsaR6tUs6UpVpzTd29fVM0(CUpRRVr7dc7ykkn9jW9vweq9XtFULj39nwiGXxxtDjGyajtG0diYre)L1oy3Na67b9bzFCct9jG(Sh9ahSRIOhQmGqQ)IPD4XaYMKgqUY5ObeuqnP9Pd3NmMAsDPpiuTR8a3hsQlIyhKCS(4PpbYKY1XapBxUuZ99q6Kv9HicdpAFpSdeUGDa1xg1NJX9Thw2NdO(81vCs7aIB4C0aIXX4VB4C0poLCaXasMaPhqqTpZyHux5Ifs56yG(GSpR1h7ys5YATR8a)LPUiIDqYXkK6VyA3hK9ThUKWRKUtD5BC2LmywRP)E4cNgHPU0hK9zMbVN4Arkcdp6F7aHlyhqfa57y9HwF2S1hQ9zglK6kx0CPM)ro1hK9zT(yhtkxwRDLh4Vm1frSdsowHu)ft7(GSV9Wf5iI)GHlCAeM6sFq2Nzg8EIRfPim8O)TdeUGDavaKVJ1hA9zZwFO2hQ9zglK6kxuYag8a29zZwFMXcPUYfHXaPR9zZwFMXcPUYfDuQp06dY(mZG3tCTifHHh9VDGWfSdOcG8DS(qlGGtj)vhMciBhiCb7a6VcO1ahSRI2hQmGqQ)IPD4XaIB4C0aY2bc)Yrehq2K0aYvohnGy9jP(EyhiSpKre3xg13d7aHlyhq9fFub5(EP(aKVJ1NV4PAvFdOVmQpUMauFXtmUVxQpN7dtUK7Z((Gha13d7aHlyhq9jkjzaXasMaPhqEhPSpi7ZmdEpX1IuegE0)2bcxWoGkac2tv2Na6lkxQ5pGG9uL9bzFO2N16JDmPCzT2vEG)YuxeXoi5yfs9xmT7ZMT(mZG3tCTSw7kpWFzQlIyhKCScGG9uL9jG(IYLA(diypvzFOf4GDvSIHkdiK6VyAhEmGyajtG0diVJu2hK9zT(yhtkxwRDLh4Vm1frSdsowHu)ft7(GSpZm49exlsry4r)BhiCb7aQaiypvzFp1Nzg8EIRfPim8O)TdeUGDav2IaNZr7dA9fLl18hqWEQYaIB4C0aY2bc)Yreh4GDv8bHkdiK6VyAhEmGSjPbKRCoAabIC2udbCmUVKj4(eL(c1x0a6Z1yCDQl9Pd3NCLmzus7(iSKIxtakG4gohnGyCm(7goh9JtjhqWPK)QdtbKKj4ahSRIwxOYacP(lM2HhdigqYei9ac7ys5IS23t8pb)cCdvi1FX0Upi7d1(20Ryuurw77j(NGFbUHks2nc7dA9HAF23heOp3W5OfzTVN4)3bZLu)r4CPM7dT(SzRVn9kgfvK1(EI)j4xGBOcGG9uL9bT(QyFOfqCdNJgqmog)DdNJ(XPKdi4uYF1HPaIKcCWUkcbdvgqi1FX0o8yaXnCoAab2XuuA(aFLfbuaztsdix5C0aI1NK6dc7ykkn9jW9vweq9fVM0(G9hIdOV9WY(Ca1N4Qv9nG(YO(4Acq9fpX4(EP(K5IMrPXvUpoHP(evoX9X1uFkbXCFqOAx5bUpKuxeXoi5yL(eyr9jYjoT(N6sFqyhtrPPpuaW5AR6REW7(8(K1oy3hp9bOiajR7JRP(EfJIcigqYei9acQ9ThUyjX0N9u5cNgHPU0NnB9ThUKWRKUtD5BC2LmywRP)E4cNgHPU0NnB9ThUihr8hmCHtJWux6dT(GSpu7ZA9bevkAalub2XuuA(Xboxxi1FX0UpB267vmkQa7ykkn)4aNRls2nc7dA9vX(SzRp5iI)YAhS7ta9HEFOf4GDv06fQmGqQ)IPD4XaIB4C0acSJPO08b(klcOaYMKgqUY5ObeRpj1he2XuuA6tG7RSiG6JN(G9uzp1(4AQpyhtrPPV4aNR77vmkQprLtCFYAhSL9PeT7JN(EP(wiLaot7(IgqFCn1Nsqm33RiqY9fp19eVpuThL6tsMr3Y(szFWdG6JRDTpPyuuAss5(4PVfsjGZuFvSpzTd2s0cigqYei9acquPObSqfyhtrP5hh4CDHu)ft7(GSpZm49exlYre)bdxaeSNQSpb0N9OuFq23Ryuub2XuuA(XboxxaeSNQSpO13dcCWUkIcdvgqi1FX0o8yaXnCoAab2XuuA(aFLfbuaztsdix5C0ace2tL9u7dc7ykkn9Hcaox3NZ95yCFCctY(IgqFCn1NDKbm4bS7Ba9jq6yG01(mJfsDLdigqYei9acquPObSqfyhtrP5hh4CDHu)ft7(GSpu7Zmwi1vUOKbm4bS7ZMT(mJfsDLlcJbsx7dT(GSVxXOOcSJPO08JdCUUaiypvzFqRVhe4GDvuGiuzaHu)ft7WJbe3W5ObeyhtrP5d8vweqbKnjnGCLZrdiwFsQpiSJPO00Na3xzra13O9bHQDLh4(qsDre7GKJ1NXLS0Q(GDHPU0Nueq9XtFs3c1N3NS2b7(4Ppj7gH9bHDmfLM(qbaNR7lJ6tuM6sFjhqmGKjq6be2XKYL1Ax5b(ltDre7GKJvi1FX0Upi7d1(2dxwRDLh4Vm1frSdsowHtJWux6ZMT(mZG3tCTSw7kpWFzQlIyhKCScGG9uL9jG(S366ZMT(EhPSpi7Jty6ZZFNuFqRpZm49exlR1UYd8xM6Ii2bjhRaiypvzFO1hK9HAFwRpGOsrdyHkWoMIsZpoW56cP(lM29zZwFVIrrfyhtrP5hh4CDrYUryFqRVk2NnB9jhr8xw7GDFcOp07dTahS7bOuOYacP(lM2HhdigqYei9ac7ys5ICI)5A6ljAllK6VyAhqCdNJgqGDmfLMpWxzraf4GDpa9qLbes9xmTdpgqCdNJgq2ap1poJOaYMKgqUY5ObKhg4P2h0LruFPSVrXX6Z77HHqi9T4P2x8KR7tGPKLK9xm13dtWPK6tjh0hSdX9jz3iuw6tGf1xuUuZ9LY(83rK7JN(iD33E6thUp4uk7tUs6o1L(4AQpj7gHYaIbKmbspG8kgfvsLSKS)IP)MGtjvKSBe2Na67bOuF2S13RyuujvYsY(lM(BcoLurCTpi77DKY(GSVOCPM)ac2tv2h067bboy3dSpuzaHu)ft7WJbe3W5ObeJJXF3W5OFCk5acoL8xDykGyglK6kh4GDpOIHkdiK6VyAhEmG4gohnG4lJglGyajtG0diakcqYA)ftbetmdM(SdwiwgSd9ahS7bpiuzaHu)ft7WJbedizcKEaXnCAH(7HlIQK9xm99OiCA4C0(Q2hk1NnB9XPryQl9bzFakcqYA)ftbe3W5ObervY(lM(EueonCoAGd29aRluzaHu)ft7WJbe3W5ObezUwp6hNruaXasMaPhqaueGK1(lMciMygm9zhSqSmyh6boy3dGGHkdiK6VyAhEmG4gohnGygaqCLZrdigqYei9acGIaKS2FXuFq2NB40c9jLGts2h067b9bb6d1(yhtkxKt8pxtFjrBzHu)ft7(SzRp2XKYfzUwp6hNruHu)ft7(qlGyIzW0NDWcXYGDOh4GDpW6fQmGqQ)IPD4XaIB4C0aseMK1gGhXbedizcKEaroI43u3fld25etF5GTqkxi1FX0oGKktaG4k)ZOaYRyuuXYGDoX0xoylKYfX1ahS7bOWqLbKuzcaex5ac6be3W5ObKnWt9lhrCaHu)ft7WJboy3deicvgqCdNJgqK1(EI)Fhmhqi1FX0o8yGdCazfqMb(15qLb7qpuzaHu)ft7WJbedizcKEaHtyQpb0hk1hK9zT(wjU440c1hK9zT(EfJIklGeEsa9NOV0nGmknurCnG4gohnGer4)EGt15C0ahSZ(qLbe3W5ObePim8O)icxlQmbciK6VyAhEmWb7QyOYacP(lM2HhdiQdtbeEGP)e9HhvYGru(nJkzGOHZrLbe3W5ObeEGP)e9HhvYGru(nJkzGOHZrLboy3dcvgqi1FX0o8yarDykGihm51YVKmaI)mzQ1e6lsbe3W5Obe5GjVw(LKbq8NjtTMqFrkWb7SUqLbes9xmTdpgqmGKjq6be2XKYLfqcpjG(t0x6gqgLgQqQ)IPDaXnCoAazbKWtcO)e9LUbKrPHcCWoiyOYaIB4C0aseMK1gGhXbes9xmTdpg4GDwVqLbes9xmTdpgqM1aIK4aIB4C0aIfhK(lMciwCSifqCdNwO)E4IzaaXvohTpb0hk1hK95goTq)9WfFz0y9jG(qP(GSp3WPf6VhUiQs2FX03JIWPHZr7ta9Hs9bzFO2N16JDmPCrMR1J(Xzevi1FX0UpB26ZnCAH(7HlYCTE0poJO(eqFOuFO1hK9HAF7HlR1UYd8xM6Ii2bjhRWPryQl9zZwFwRp2XKYL1Ax5b(ltDre7GKJvi1FX0Up0ciwCWxDykGShw(bKVJf4GDOWqLbes9xmTdpgqCdNJgqKeT)t03maG4kNJgqmGKjq6be5kHXF2blellsI2)j6BgaqCLZr)(q9jGQ9vXacov6B2be0rPahStGiuzaXnCoAaP2fvoGqQ)IPD4XahSdDukuzaXnCoAaruLS)IPVhfHtdNJgqi1FX0o8yGdCaXhkuzWo0dvgqCdNJgqwRDLh4Vm1frSdsowaHu)ft7WJboyN9HkdiUHZrdi1UOYbes9xmTdpg4GDvmuzaHu)ft7WJbedizcKEaXmwi1vUyHuUogOpi7BpCjHxjDN6Y34SlzWSwt)9WfonctDPpi7ZmdEpX1IuegE0)2bcxWoGkaY3X6dY(qTV9WL1Ax5b(ltDre7GKJvaeSNQSpb0N99zZwFwRp2XKYL1Ax5b(ltDre7GKJvi1FX0Up06ZMT(mJfsDLlAUuZ)iN6dY(2dxKJi(dgUWPryQl9bzFMzW7jUwKIWWJ(3oq4c2bubq(owFq2hQ9ThUSw7kpWFzQlIyhKCScGG9uL9jG(SVpB26ZA9XoMuUSw7kpWFzQlIyhKCScP(lM29HwF2S1hQ9zglK6kxuYag8a29zZwFMXcPUYfHXaPR9zZwFMXcPUYfDuQp06dY(2dxwRDLh4Vm1frSdsowHtJWux6dY(2dxwRDLh4Vm1frSdsowbqWEQY(GwF2hqCdNJgqmog)DdNJ(XPKdi4uYF1HPaY2bcxWoG(RaAnWb7EqOYacP(lM2HhdigqYei9ac7ys5ICI)5A6ljAllK6VyA3hK9zC9ljAhqCdNJgqKeT)t03maG4kNJg4GDwxOYacP(lM2HhdigqYei9aI16JDmPCroX)Cn9LeTLfs9xmT7dY(SwF7HlsI2)j6BgaqCLZrlCAeM6sFq2N16l1FeoxQ5(GSV9WfZaaIRCoAbqrasw7VykG4gohnGijA)NOVzaaXvohnWb7GGHkdiK6VyAhEmG4gohnG4lJglGyajtG0diUHtl0FpCXxgnwFqRVh0hK9zT(2dx8LrJv40im1LaIjMbtF2bleld2HEGd2z9cvgqi1FX0o8yaXnCoAaXxgnwaXasMaPhqCdNwO)E4IVmAS(eq1(EqFq2hGIaKS2FXuFq23E4IVmAScNgHPUeqmXmy6ZoyHyzWo0dCWouyOYacP(lM2HhdigqYei9aIB40c93dxevj7Vy67rr40W5O9vTpuQpB26JtJWux6dY(aueGK1(lMciUHZrdiIQK9xm99OiCA4C0ahStGiuzaHu)ft7WJbe3W5ObervY(lM(EueonCoAaXasMaPhqSwFCAeM6sFq23QLv2XKYfGdV6k)9OiCA4CuzHu)ft7(GSp3WPf6VhUiQs2FX03JIWPHZr7dA9vXaIjMbtF2bleld2HEGd2HokfQmGqQ)IPD4XaIbKmbspGihr8xw7GDFcOp0diUHZrdiwsm9zpvoWb7qh9qLbes9xmTdpgqmGKjq6beR1NzSqQRCrjdyWdyhqKminCWo0diUHZrdighJ)UHZr)4uYbeCk5V6WuaXmwi1voWb7q3(qLbes9xmTdpgqmGKjq6beu7Zmwi1vUyHuUogOpi7d1(mZG3tCTKWRKUtD5BC2LmywRPcG8DS(SzRV9WLeEL0DQlFJZUKbZAn93dx40im1L(qRpi7ZmdEpX1IuegE0)2bcxWoGkaY3X6dY(qTV9WL1Ax5b(ltDre7GKJvaeSNQSpb0N99zZwFwRp2XKYL1Ax5b(ltDre7GKJvi1FX0Up06dT(GSpu7d1(mJfsDLlkzadEa7(SzRpZyHux5IWyG01(SzRpZyHux5Iok1hA9bzFMzW7jUwKIWWJ(3oq4c2bubqWEQY(GwF23hK9HAF7HlR1UYd8xM6Ii2bjhRaiypvzFcOp77ZMT(SwFSJjLlR1UYd8xM6Ii2bjhRqQ)IPDFO1hA9zZwFO2NzSqQRCrZLA(h5uFq2hQ9zMbVN4AroI4py4cG8DS(SzRV9Wf5iI)GHlCAeM6sFO1hK9zMbVN4Arkcdp6F7aHlyhqfab7Pk7dA9zFFq2hQ9ThUSw7kpWFzQlIyhKCScGG9uL9jG(SVpB26ZA9XoMuUSw7kpWFzQlIyhKCScP(lM29HwFOfqCdNJgqmog)DdNJ(XPKdi4uYF1HPaY2bcxWoG(RaAnWb7qVIHkdiK6VyAhEmGyajtG0diVJu2hK9zMbVN4Arkcdp6F7aHlyhqfab7Pk7ta9fLl18hqWEQY(GSpu7ZA9XoMuUSw7kpWFzQlIyhKCScP(lM29zZwFMzW7jUwwRDLh4Vm1frSdsowbqWEQY(eqFr5sn)beSNQSp0ciUHZrdiBhi8lhrCGd2H(dcvgqi1FX0o8yaXasMaPhqEhPSpi7ZmdEpX1IuegE0)2bcxWoGkac2tv23t9zMbVN4Arkcdp6F7aHlyhqLTiW5C0(GwFr5sn)beSNQmG4gohnGSDGWVCeXboyh6wxOYacP(lM2HhdiUHZrdighJ)UHZr)4uYbeCk5V6WuajzcoWb7qhcgQmGqQ)IPD4XaIB4C0aIXX4VB4C0poLCabNs(Romfq2e2Jr7pdsviXYahSdDRxOYacP(lM2HhdiUHZrdighJ)UHZr)4uYbeCk5V6Wuaz7W(c9zqQcjwg4GDOJcdvgqi1FX0o8yaXasMaPhq2dxwRDLh4Vm1frSdsowHtJWux6ZMT(SwFSJjLlR1UYd8xM6Ii2bjhRqQ)IPDarYG0Wb7qpG4gohnGyCm(7goh9JtjhqWPK)Qdtbej78NbPkKyzGd2HUarOYacP(lM2HhdigqYei9aYE4ILetF2tLlCAeM6saXnCoAab2XuuA(aFLfbuGd2zpkfQmGqQ)IPD4XaIbKmbspGShUihr8hmCHtJWux6dY(SwFSJjLlYj(NRPVKOTSqQ)IPDaXnCoAab2XuuA(aFLfbuGd2zp6HkdiK6VyAhEmGyajtG0diwRp2XKYfljM(SNkxi1FX0oG4gohnGa7ykknFGVYIakWb7S3(qLbes9xmTdpgqmGKjq6be5iI)YAhS7ta99GaIB4C0acSJPO08b(klcOahSZ(kgQmGqQ)IPD4XaIB4C0aImxRh9JZikGyajtG0diUHtl0FpCrMR1J(Xze1h0Q2xf7dY(aueGK1(lM6dY(SwF7HlYCTE0poJOcNgHPUeqmXmy6ZoyHyzWo0dCWo7FqOYacP(lM2HhdigqYei9aIzSqQRCrjdyWdyhqKminCWo0diUHZrdighJ)UHZr)4uYbeCk5V6WuaXmwi1voWb7S36cvgqi1FX0o8yaXasMaPhqEfJIkPsws2FX0FtWPKks2nc7tav7Z6qP(SzRV3rk7dY(EfJIkPsws2FX0FtWPKkIR9bzFr5sn)beSNQSpO1N11NnB99kgfvsLSKS)IP)MGtjvKSBe2NaQ2xfTU(GSV9Wf5iI)GHlCAeM6saXnCoAazd8u)4mIcCWo7HGHkdiK6VyAhEmG4gohnGeHjzTb4rCaXasMaPhqKJi(n1DXYGDoX0xoylKYfs9xmTdiPYeaiUY)mkG8kgfvSmyNtm9Ld2cPCrCnWb7S36fQmGKktaG4khqqpG4gohnGSbEQF5iIdiK6VyAhEmWb7ShfgQmG4gohnGiR99e))oyoGqQ)IPD4Xah4asYeCOYGDOhQmG4gohnGikPFYeSmGqQ)IPD4Xah4aIKcvgSd9qLbe3W5ObKAxu5acP(lM2HhdCWo7dvgqi1FX0o8yajvMaaXv(NrbKn9kgfvK1(EI)j4xGBOIKDJqbuTIbe3W5ObKnWt9lhrCajvMaaXv(VGNxhhqqpWb7QyOYaIB4C0aIS23t8)7G5acP(lM2HhdCGdikzaZhoEOYGDOhQmGqQ)IPD4XaYSgqKehqCdNJgqS4G0FXuaXIJfPaYE4IzaaXvohTaiypvzFcOp77dY(2dx8LrJvaeSNQSpb0N99bzF7HlIQK9xm99OiCA4C0cGG9uL9jG(SVpi7d1(SwFSJjLlYCTE0poJOcP(lM29zZwF7HlYCTE0poJOcGG9uL9jG(SVp0ciwCWxDykGShw(50im1LahSZ(qLbes9xmTdpgqM1aIK4mkGyajtG0diMXcPUYfLmGbpGDaztsdix5C0asLGufsSSphNlAFXtUUpiesFrdOpKAFpX7d6b(f4gYQ(E4h7lAa99qWfvUeqS4GV6WuaHbPkK4)MWESaIB4C0aIfhK(lMciwCSi9jSKciMzW7jUw2KjHDo1L)7G5cGG9uLbelowKciMzW7jUwwRDLh4Vm1frSdsowbqWEQYahSRIHkdiK6VyAhEmG4gohnGa7ykknFGVYIakGSjPbKRCoAa5rrG2NCeX9jRDWw2xg1hxt9fLl1CFXtmUVxQps3PU0NCgTeqmGKjq6beoHPpp)Ds9bT(iiMmIm95eM67H2NCeXFzTd29bzF7HlIQK9xm99OiCA4C0cNgHPUe4GDpiuzaHu)ft7WJbe3W5ObKAxu5aYMKgqUY5ObeiYLCF1UOY9XtFakcqY6(EPObq9f5y8efvcigqYei9aYE4sTlQCbqWEQY(GwF233t9rqmzez6Zjmf4GDwxOYacP(lM2HhdiUHZrdiWoMIsZh4RSiGciBsAa5kNJgqEiKl19bb6BfKdi5y9bHrb9bOiajR7lJ6tUs6o1L(gL6BbpVoUV4JiE3NXfLuFIY(4Pp4uk7JRP(M11bWIAYX6JN(aueGK19bHrbL(cigqYei9acNWuFcOpRxFq23Ryuub2XuuA(XboxxaeSNQSpO13IzxGDiUVN6JGyYiY0NtykWb7GGHkdiK6VyAhEmGSjPbKRCoAa5HmbuFBc7XODFmivHel7l1(CLttU6CoAFtuFpmzsyNtDPVhhmxciQdtbecEngGC8FaB1vdfqmGKjq6beloi9xmvyqQcj(VjShRpO1N9OuaXnCoAaHGxJbih)hWwD1qboyN1luzaHu)ft7WJbe3W5ObePO(INz)DyIRJj5aIbKmbspGyXbP)IPcdsviX)nH9y9bT(GGbe1HPaIuuFXZS)omX1XKCGd2Hcdvgqi1FX0o8yaXnCoAaroIymXCQlFG4BSaIbKmbspGyXbP)IPcdsviX)nH9y9bT(qHbe1HPaICeXyI5ux(aX3yboyNarOYacP(lM2HhdigqYei9aIfhK(lMkmivHe)3e2J1h067bbe1HPaI6WuvzTVN40(pG3)e95batkh4GDOJsHkdiK6VyAhEmG4gohnGSw7kpWFzQlIyhKCSaYMKgqUY5ObebwuFCn13k2JrG(szFIYux67HGlQSv9fLaQpiesFJ2Nzg8EIR9X1K2x0GXt8(INCDFp8JbedizcKEaHDmPCP2fvUqQ)IPDFq2NfhK(lMk7HLFonctDjWb7qh9qLbes9xmTdpgqmGKjq6be2XKYLAxu5cP(lM29bzFMzW7jUwwRDLh4Vm1frSdsowbqWEQY(eqFOuaXnCoAaztMe25ux(VdMdCWo0TpuzaHu)ft7WJbe3W5ObKnzsyNtD5)oyoGSjPbKRCoAarGf1hxt9TI9yeOVu2NOm1L(qGESQVOeq99Wp23O9zMbVN4AFCnP9fny8ep1L(INCDFqiKaIbKmbspGWoMuUiR99e)tWVa3qfs9xmT7dY(S4G0FXuzpS8ZPryQlboyh6vmuzaHu)ft7WJbedizcKEaHDmPCrw77j(NGFbUHkK6VyA3hK9zMbVN4AztMe25ux(VdMlac2tv2Na6dLciUHZrdiR1UYd8xM6Ii2bjhlWb7q)bHkdiK6VyAhEmGyajtG0di7HlIQK9xm99OiCA4C0cGG9uL9bT(GGbe3W5ObervY(lM(EueonCoAGd2HU1fQmGqQ)IPD4XaIbKmbspGShU4lJgRaiypvzFqRVheqCdNJgq8LrJf4GDOdbdvgqi1FX0o8yaXasMaPhq2dxK5A9OFCgrfab7Pk7dA99GaIB4C0aImxRh9JZikWb7q36fQmGqQ)IPD4XaIbKmbspGShUygaqCLZrlac2tv2h067bbe3W5ObeZaaIRCoAGd2HokmuzaHu)ft7WJbe3W5ObeyhtrP5d8vweqbKnjnGCLZrdicCkcqY6(GWOG(8iMa9X1uFZkPeOVmQVTdeUGDa9xb0AFXhr8UpJlkP(eL9XtFWPu2N3hegf0hGIaKSoGyajtG0diCct9jG(SE9bzFVIrrfyhtrP5hh4CDbqWEQY(GwF233dTVfZUa7qCFp1hbXKrKPpNWuGd2HUarOYacP(lM2HhdiBsAa5kNJgqGihJ7B7aHlyhq)vaT2xg1heQ2vEG7dj1frSdsowFPSpJiaqkJJ1hNgHPUeqCdNJgqmog)DdNJ(XPKdisgKgoyh6bedizcKEazpCzT2vEG)YuxeXoi5yfonctDjGGtj)vhMciBhiCb7a6VcO1ahSZEukuzaHu)ft7WJbKnjnGCLZrdiwFCItR)uFUgRVHRjqFs25(yqQcjw2xg1heQ2vEG7dj1frSdsowFPSponctDjG4gohnGyCm(7goh9JtjhqKminCWo0digqYei9aYE4YATR8a)LPUiIDqYXkCAeM6sabNs(RomfqKSZFgKQqILboyN9OhQmGqQ)IPD4XaIB4C0acSJPO08b(klcOaYMKgqUY5Obee2nc7dc7ykkn9Hcaox3hp9vrR6Ba9bOiajR7lEnP9TqmN6sF4jEFOMBYX4y9HNryQl9fnG(8(mo2iIDM29PIWVeWQ(Ef5(EqX6K9biyp1ux6lL9X1uFaskI5(MO(ysYPU0x8KR7Rs7TEOfqmGKjq6beoHP(eqFwV(GSpu77vmkQa7ykkn)4aNRls2nc7dA9vX(SzRVxXOOcSJPO08JdCUUaiypvzFqRVhuSU(qlWb7S3(qLbes9xmTdpgqCdNJgqGDmfLMpWxzrafq2K0aYvohnGiq37KZrDCFqybEFYvs3Y(IxtAFeeZaVpzTd2Y(Ca1NBXtS)IP(CD3hLCnb6dcv7kpW9HK6Ii2bjhRVu2hNgHPUyvFdOpUM6lkxQ5(szFKUtDPeqmGKjq6beu7BpCzT2vEG)YuxeXoi5yfonctDPpB26Jty6ZZFNuFqRpZm49exlR1UYd8xM6Ii2bjhRaiypvzFO1hK9HAFVIrrfyhtrP5hh4CDrYUryFqRVk2NnB9jhr8xw7GDFcOp07dTahSZ(kgQmGqQ)IPD4XaIB4C0aYg4P(LJioGSjPbKRCoAarGU3jNJ64(EyGNAFiJiUpJl5(IxtAFqiK(szFCAeM6saXasMaPhq2dxwRDLh4Vm1frSdsowHtJWuxcCWo7FqOYacP(lM2HhdiUHZrdi(YOXciBsAa5kNJgqGUjEFqG(wb5asowF7H7dqrasw3x8As7dqrasw7VyQeqmGKjq6beafbizT)IPahSZERluzaHu)ft7WJbedizcKEabqrasw7VykG4gohnGiQs2FX03JIWPHZrdCWo7HGHkdiK6VyAhEmGyajtG0diakcqYA)ftbe3W5ObeZaaIRCoAGd2zV1luzaHu)ft7WJbedizcKEaHDmPCrMR1J(Xzevi1FX0Upi7dqrasw7VykG4gohnGiZ16r)4mIcCWo7rHHkdiK6VyAhEmG4gohnGeHjzTb4rCajvMaaXv(NrbKxXOOILb7CIPVCWwiL)1IWUo5UiUgqmGKjq6be5iIFtDxSmyNtm9Ld2cPCHu)ft7aYMKgqUY5ObKhsmjRnapI7JN(G9uzp1(eipyNtm1hYGTqkxcCWo7ficvgqi1FX0o8yaXnCoAaP2fvoGSjPbKRCoAab6M4qGvqoGKJ1xTlQCFakcqY6saXasMaPhq2dxQDrLlac2tv2h06RIboyxfrPqLbes9xmTdpgqCdNJgq2ap1VCeXbKnjnGCLZrdiwFAQmbaIRC(IP(EyK(m1UQeUVmQV4uF1UfQpUM67HFSVxXOOsaXasMaPhqEfJIkBYKWoN6Y)DWCrCnWb7Qi6HkdiK6VyAhEmG4gohnGSbEQF5iIdigqYei9ac7ys5IS23t8pb)cCdvi1FX0Upi7BtVIrrfzTVN4Fc(f4gQaiypvzFqRVk2NnB9TPxXOOIS23t8pb)cCdvKSBe2h06RIbKuzcaex5Fgfq20Ryuurw77j(NGFbUHks2ncfq1kc5MEfJIkYAFpX)e8lWnubqWEQsbuXahSRI2hQmGKktaG4khqqpG4gohnGSbEQF5iIdiK6VyAhEmWb7QyfdvgqCdNJgqK1(EI)Fhmhqi1FX0o8yGdCGdiUixpGacscdrboWHa]] )


end