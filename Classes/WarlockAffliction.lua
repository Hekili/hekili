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


    spec:RegisterPack( "Affliction", 20220221, [[defmFdqicvwebkIhbj0MarFIagfKQtbPSkqa9kvrMfHYTufODjXVuf1WGe5yqslJsvptsOPPkORrOkBdKQ8ncu14Ge05iuvzDqIAEGuUNK0(iqoibQSqvHEiiOjQkGlccv2iia9rqa0ibbGtsGsReK8scuKmtqQCtqOStkv(jiu1qbbAPeQkpfIPkj6QeQQAReOqFfKQASsc2RG)QQgSkhMQfRk9ykMSsDzKnlKpReJwsDArRMaf1RjOzd1Tb1Uj9BfdxjDCibwoWZjA6OUoLSDc57cvJheY5fkRNafmFkL7tGIu7xQdOgQmGSDMc2zpkzV9OK92JAXEufp7r9Hbeo2kfqwDJqFHciQdtbebxueonCoAaz1JHhFhQmGihlGHci1mVkr5NFEj5AR3IzGFwMWwyNZrnapIFwMWMNdiVwjMfSA4nGSDMc2zpkzV9OK92JAXEufp7r1(aICLmb7Sh6jEbK6CVjn8gq2K0eqeCrr40W5O9b9DaEmcBOGasValheRp7rvS(ShLS3(gQgkiS21fsIYnupyFcU9M29HSsyCFq3yewAOEW(eC7nT77birJfOpiMVKMsd1d2NGBVPDFVaYfAQDvjCF4zjn9fnG(EaGNAFiJfU0q9G9vzCYf2heZXuuA6t85RSfG6dplPPpE6l(ae2xg1xSXsaa1hCkLPU0N3h7ys5(sTpU25(at8sd1d2heN6VyQpXNdV6k3NGlkcNgohv2heueeSp2XKYLgQhSVkJtUqzF80NlAYDFV4jEQl99aoq4c2buFP2hSfMZhKDWcX9f)5PVhaIVszFwRLgQhSpiC0nPsQp5at99aoq4c2buFqqaT2NXXyzF80hG2wgQpZaVAXoNJ2hNWuPH6b7dH4(Kdm1NXX4VB4C0poLCFKYGKK9XtFsgKgUpE6Zfn5UptnzeM6sF4uYY(4AN7l(OcW99s9bi3ut7(q3x8ufhALgQhSpiEfhRpeI29nQH6Bfqp4QfgxAOEW(eCBbZwsUpbtETaAFq4di77LIga1hP7(MO(IYLAwWK(WZsA6JN(81vCS(gfhRpE67DKY(IYLAw2h66W9Xaxw33QBekrR0q9G9bbetYAdWJ4NfmoyNtm1hYGfrk3NXvdH)zuFMAxxODF80xQmbawR8pJknupyFcwLPfGZuF2rgW0hed633kihqYX6dNsUeqwbtuIPackII9j4IIWPHZr7d67a8ye2qHIOyFpazi4xc0N9cEX6ZEuYEuBOAOqruSpiS21fsIYnuOik23d2NGBVPDFiReg3h0ngHLgkuef77b7tWT30UVhGenwG(Gy(sAknuOik23d2NGBVPDFVaYfAQDvjCF4zjn9fnG(EaGNAFiJfU0qHIOyFpyFvgNCH9bXCmfLM(eF(kBbO(WZsA6JN(IpaH9Lr9fBSeaq9bNszQl959XoMuUVu7JRDUpWeV0qHIOyFpyFqCQ)IP(eFo8QRCFcUOiCA4CuzFqqrqW(yhtkxAOqruSVhSVkJtUqzF80NlAYDFV4jEQl99aoq4c2buFP2hSfMZhKDWcX9f)5PVhaIVszFwRLgkuef77b7dchDtQK6toWuFpGdeUGDa1heeqR9zCmw2hp9bOTLH6ZmWRwSZ5O9XjmvAOqruSVhSpeI7toWuFghJ)UHZr)4uY9rkdss2hp9jzqA4(4Ppx0K7(m1KryQl9Htjl7JRDUV4Jka33l1hGCtnT7dDFXtvCOvAOqruSVhSpiEfhRpeI29nQH6Bfqp4QfgxAOqruSVhSpb3wWSLK7tWKxlG2he(aY(EPObq9r6UVjQVOCPMfmPp8SKM(4PpFDfhRVrXX6JN(EhPSVOCPML9HUoCFmWL19T6gHs0knuOik23d2heqmjRnapIFwW4GDoXuFidwePCFgxne(Nr9zQDDH29XtFPYeayTY)mQ0qHIOyFpyFcwLPfGZuF2rgW0hed633kihqYX6dNsU0q1q5gohvwwbKzGFDUAeH)7bovNZrflJQYjmjiucsXTsCXXPicsX9Affvwaj8Ka6prFPBazuAOI1AdLB4CuzzfqMb(15NQ(S0cgE0)kXnuUHZrLLvazg4xNFQ6Zws6NmblM6WuvEGP)e9HhvYGXs(nJkzGLHZrLnuUHZrLLvazg4xNFQ6Zws6NmblM6Wuv5GjVw(LKbq8NjtTMOalQHYnCoQSSciZa)68tvFEbKWtcO)e9LUbKrPHelJQYoMuUSas4jb0FI(s3aYO0qfs9xmTBOCdNJklRaYmWVo)u1NJWKS2a8iUHYnCoQSSciZa)68tvFwKds)ftIPomvDpS8diFhtmro2IQ6gofr)9WfZaawRCoQGqjiDdNIO)E4IVmAmbHsq6gofr)9WflvY(lM(EueonCoQGqjirxCSJjLlYCTE0poJOcP(lM22S5gofr)9WfzUwp6hNrKGqj0Ge99WL1Ax5b(ltDXc7GKJv40im1fB2eh7ys5YATR8a)LPUyHDqYXkK6VyAJwdLB4CuzzfqMb(15NQ(SLK(jtWIPomv1fmiRDGl)rJY)j6VoXjqdLB4CuzzfqMb(15NQ(SKO9FI(MbaSw5CuXWPsFZUkQOKyzuv5kHXF2blellsI2)j6BgaWALZr)(qcQAfBOCdNJklRaYmWVo)u1NRDlLBOCdNJklRaYmWVo)u1NTuj7Vy67rr40W5OnunuOik2heherglM29rIiqS(4eM6JRP(CdpG(szFUipX(lMknuUHZrLvLReg)XJrydLB4Cu5tvFEtIglWh2xstdLB4Cu5tvF24y83nCo6hNswm1HPQ(qIjzqA4QOkwgv1nCkI(KsWjjfufBOqX(GqhJ7tsRoWzQp3W5O9Htj3x0a6ZoYag8a29bXG(9LAFivw6dcTaaszCS(gfhRVzLt4uWaT7lAa9zjP(INCDFqqKsdLB4Cu5tvFgyPF3W5OFCkzXuhMQQKbmF44IjzqA4QOkwgv1mIi1vUOKbm4bSHeyPu0awOcSJPO08JdCUgs3WPi6tkbNKSkQqYoMuUSw7kpWFzQlwyhKCSgkuSpbNHZr7dNsw2x0a6JbPkK4(EPAxuoGsFiSZY(Ca1N0fr7(IgqFVu0aO(qglCFIVHFwWcVs6o1L(GqNDjdM1A6ziyTR8a3hsQlwyhKCmX6B4AcepLuFJ2Nzg8EIRLgk3W5OYNQ(SXX4VB4C0poLSyQdtvzqQcj(lxXj)n1KrydLB4Cu5tvF24y83nCo6hNswm1HPQBc7XO9NbPkKyzdLB4Cu5tvF24y83nCo6hNswm1HPQs25pdsviXsXKminCvuflJQI(E4ICSWFWWfonctDXMT9WLeEL0DQlFJZUKbZAn93dx40im1fB22dxwRDLh4Vm1flSdsowHtJWuxqds5yH)YAhSfufTzBpCruIPp7PYfonctDXMn2XKYf5e)Z10xs0w2q5gohv(u1Nnog)DdNJ(XPKftDyQ62H9f6ZGufsSuSmQQzerQRCrZLA(h5eKOloroi9xmvyqQcj(lxXjBZMzg8EIRf5yH)GHlac2tvki7rjB2qxKds)ftfgKQqI)JsqAMbVN4Arow4py4cGG9uLqJbPkK4cQfZm49exlac2tvIMnBOlYbP)IPcdsviXFo(aPzg8EIRf5yH)GHlac2tvcngKQqIl2xmZG3tCTaiypvjAOzZMzerQRCrePCDmaKOloroi9xmvyqQcj(lxXjBZMzg8EIRLeEL0DQlFJZUKbZAnvaeSNQuq2Js2SHUihK(lMkmivHe)hLG0mdEpX1scVs6o1LVXzxYGzTMkac2tvcngKQqIlOwmZG3tCTaiypvjA2SHUihK(lMkmivHe)54dKMzW7jUws4vs3PU8no7sgmR1ubqWEQsOXGufsCX(Izg8EIRfab7PkrdnB2q3mIi1vUOKbm4bSTzZmIi1vUimgiD1MnZiIux5IokHgKOloroi9xmvyqQcj(lxXjBZMzg8EIRL1Ax5b(ltDXc7GKJvaeSNQuq2Js2SHUihK(lMkmivHe)hLG0mdEpX1YATR8a)LPUyHDqYXkac2tvcngKQqIlOwmZG3tCTaiypvjA2SHUihK(lMkmivHe)54dKMzW7jUwwRDLh4Vm1flSdsowbqWEQsOXGufsCX(Izg8EIRfab7PkrdnB2eh7ys5YATR8a)LPUyHDqYXkK6VyAdj6ItKds)ftfgKQqI)YvCY2SzMbVN4ArAbdp6F7aHlyhqfab7PkfK9OKnBOlYbP)IPcdsviX)rjinZG3tCTiTGHh9VDGWfSdOcGG9uLqJbPkK4cQfZm49exlac2tvIMnBOlYbP)IPcdsviXFo(aPzg8EIRfPfm8O)TdeUGDavaeSNQeAmivHexSVyMbVN4AbqWEQs0qRHcf77rlG2NCSW9jRDWw2xg1xuUuZ9LY(Cm8i5(greOHYnCoQ8PQpd7ykknFGVYwasSmQ67iLqgLl18hqWEQsOrqezSy6Zjmbbkhl8xw7GnK7HlwQK9xm99OiCA4C0cNgHPU0qHI9jyJ6ZmIi1vUV9WpdbRDLh4(qsDXc7GKJ1xk7dyPAQlI1NLK67bCGWfSdO(4PpcIys39X1uFglaGuUpjXnuUHZrLpv9zJJXF3W5OFCkzXuhMQUDGWfSdO)kGwflJQIUzerQRCrePCDmaK7Hlj8kP7ux(gNDjdM1A6VhUWPryQlqAMbVN4ArAbdp6F7aHlyhqfab7PkHM9qI(E4YATR8a)LPUyHDqYXkac2tvki7TztCSJjLlR1UYd8xM6If2bjhdn0SzdDZiIux5IMl18pYji3dxKJf(dgUWPryQlqAMbVN4ArAbdp6F7aHlyhqfab7PkHM9qI(E4YATR8a)LPUyHDqYXkac2tvki7TztCSJjLlR1UYd8xM6If2bjhdn0SzdD0nJisDLlkzadEaBB2mJisDLlcJbsxTzZmIi1vUOJsOb5E4YATR8a)LPUyHDqYXkCAeM6cK7HlR1UYd8xM6If2bjhRaiypvj0ShTgkuSpXhfbizDF7HL9roahRVmQVLj1L(sLN(8(K1oy3NCL0DQl9Tw7sQHYnCoQ8PQpBCm(7goh9JtjlM6Wu19W)vaTkwgvfDZiIux5IMl18pYjif3E4ICSWFWWfonctDbsZm49exlYXc)bdxaeSNQeApenB2q3mIi1vUiIuUogasXThUKWRKUtD5BC2LmywRP)E4cNgHPUaPzg8EIRLeEL0DQlFJZUKbZAnvaeSNQeApenB2qhDZiIux5IsgWGhW2MnZiIux5IWyG0vB2mJisDLl6OeAqYoMuUSw7kpWFzQlwyhKCmif3E4YATR8a)LPUyHDqYXkCAeM6cKMzW7jUwwRDLh4Vm1flSdsowbqWEQsO9q0AOqX(eSr9bbRDLh4(qsDXc7GKJ1xk7JtJWuxeRVK7lL9j9iQpE6Zss99aoqyFiJfUHYnCoQ8PQpVDGWVCSWILrv3dxwRDLh4Vm1flSdsowHtJWuxAOCdNJkFQ6ZBhi8lhlSyzuvXXoMuUSw7kpWFzQlwyhKCmirFpCrow4py4cNgHPUyZ2E4scVs6o1LVXzxYGzTM(7HlCAeM6cAnuOyFiXutFqWAx5bUpKuxSWoi5y9fp56(emskxhd8SD5sn3heqN6ZmIi1vUV9WI13W1eiEkP(SKuFJ2Nzg8EIRL(eSr9bXbVgdqoUpiEWwD1q99Aff1xk7lvZaN6Iy9vp4DFwkN4(swazFaY3X6dDurH9jjZOBzFEetG(SKeAnuUHZrLpv951Ax5b(ltDXc7GKJjwgv1mIi1vUO5sn)JCcsoHjbjEqAMbVN4Arow4py4cGG9uLqdvirNbPkK4cbVgdqo(pGT6QHkMzW7jUwaeSNQeAOc9S3MnXrOaRCDL2fcEngGC8FaB1vdHwdLB4Cu5tvFET2vEG)YuxSWoi5yILrvnJisDLlIiLRJbGKtysqIhKMzW7jUws4vs3PU8no7sgmR1ubqWEQsOHkKOZGufsCHGxJbih)hWwD1qfZm49exlac2tvcnuHE2BZM4iuGvUUs7cbVgdqo(pGT6QHqRHcf7ZoYag8a29fp56(GyoMIstFqFGZ19zCjl7BT2vEG7tM6If2bjhRVu7dNk1x8KR77bitc7CQl994G5gk3W5OYNQ(8ATR8a)LPUyHDqYXelJQAgrK6kxuYag8a2qcSukAalub2XuuA(XboxdjNWKGepinZG3tCTSjtc7CQl)3bZfab7PkHwfHeDgKQqIle8Ama54)a2QRgQyMbVN4AbqWEQsOHk0ZEB2ehHcSY1vAxi41yaYX)bSvxneAnuOyFq8Cnb6ZmIi1vw2h6PAWw7ux6th9bHyq)(SJmGbT(mUK7dcI03O9zMbVN4AdLB4Cu5tvFET2vEG)YuxSWoi5yILrvr3mIi1vUimgiD1MnZiIux5IokzZg6MrePUYfLmGbpGnKIdyPu0awOcSJPO08JdCUgn0GeDgKQqIle8Ama54)a2QRgQyMbVN4AbqWEQsOHk0ZEB2ehHcSY1vAxi41yaYX)bSvxneAnuUHZrLpv951Ax5b(ltDXc7GKJjwgv9DKsiJYLA(diypvj0qf61qHI9jyJ6dcw7kpW9HK6If2bjhRVu2hNgHPUiwFjlGSpoHP(4Pplj13W1eOpyxW8a6BpSSHYnCoQ8PQpBCm(7goh9JtjlM6WuvZiIuxzXKminCvuflJQUhUSw7kpWFzQlwyhKCScNgHPUaj6MrePUYfnxQ5FKt2SzgrK6kxerkxhdGwdLB4Cu5tvF2xgnMyMygm9zhSqSSkQILrv3dx8LrJvaeSNQeApSHYnCoQ8PQpx7wk3qHI9HmX7JRP(qiAl7B0(QyFSdwiw2xg1xY9LsvaUpJfaqkJJ1xQ9fHZLAUVb03O9X1uFSdwiU0h0p56(qY16r7d6YiQVKfq2NJLtFVeZeOpE6Zss9Hq0UVreb6d2vlhJJ1NVUIJL6sFvSpiCaaRvohvwAOCdNJkFQ6ZsI2)j6BgaWALZrflJQ6gofrFsj4KKcYEizhtkxKt8pxtFjrBjKIBpCrs0(prFZaawRCoAHtJWuxGuCP(JW5sn3q5gohv(u1NLeT)t03maG1kNJkwgv1nCkI(KsWjjfK9qYoMuUiZ16r)4mIGuC7HlsI2)j6BgaWALZrlCAeM6cKIl1FeoxQzi3dxmdayTY5Ofab7PkH2dBOCdNJkFQ6ZIsm9zpvwSmQk6YXc)L1oyliuTzZnCkI(KsWjjfK9ObPzg8EIRfPfm8O)TdeUGDavaeSNQuqOAFdLB4Cu5tvF2sLS)IPVhfHtdNJkwgv1nCkI(7HlwQK9xm99OiCA4C0QOKnBCAeM6cK7HlwQK9xm99OiCA4C0cGG9uLq7HnuUHZrLpv9zzUwp6hNrKyMygm9zhSqSSkQILrv3dxK5A9OFCgrfab7PkH2dBOCdNJkFQ6ZghJ)UHZr)4uYIPomv1mIi1vwmjdsdxfvXYOQIZmIi1vUOKbm4bSBOqX(eCRR4y9bHdayTY5O9b7QLJXX6B0(q9bTVp2blelfRVb03O9vX(INCDFcUx5GTyQpiCaaRvohTHYnCoQ8PQpBgaWALZrfZeZGPp7GfILvrvSmQQB4ue9jLGtscTh(GOZoMuUiN4FUM(sI2sB2yhtkxK5A9OFCgrOb5E4IzaaRvohTaiypvj0SVHcf7tWfXeOpUM6BwjLaI1NCL0DFEFYAhS7lEnP95CFIxFJ2heZXuuA6t85RSfG6JN(CrtU7BeraJVUM6sdLB4Cu5tvFg2XuuA(aFLTaKyzuv5yH)YAhSf0dHKtysq2JAdfk2h0VM0(0H7tgtnPU0heS2vEG7dj1flSdsowF80NGrs56yGNTlxQ5(Ga6Ky9HybdpAFpGdeUGDa1xg1NJX9Thw2NdO(81vCs7gk3W5OYNQ(SXX4VB4C0poLSyQdtv3oq4c2b0FfqRILrvr3mIi1vUiIuUogasXXoMuUSw7kpWFzQlwyhKCmi3dxs4vs3PU8no7sgmR10FpCHtJWuxG0mdEpX1I0cgE0)2bcxWoGkaY3XqZMn0nJisDLlAUuZ)iNGuCSJjLlR1UYd8xM6If2bjhdY9Wf5yH)GHlCAeM6cKMzW7jUwKwWWJ(3oq4c2bubq(ogA2SHo6MrePUYfLmGbpGTnBMrePUYfHXaPR2SzgrK6kx0rj0G0mdEpX1I0cgE0)2bcxWoGkaY3XqRHcf7t8xs99aoqyFiJfUVmQVhWbcxWoG6l(OcW99s9biFhRpFXtvS(gqFzuFCnbO(INyCFVuFo3hMCj3N99bpaQVhWbcxWoG6ZssYgk3W5OYNQ(82bc)YXclwgv9DKsinZG3tCTiTGHh9VDGWfSdOcGG9uLckkxQ5pGG9uLqIU4yhtkxwRDLh4Vm1flSdsoMnBMzW7jUwwRDLh4Vm1flSdsowbqWEQsbfLl18hqWEQs0AOCdNJkFQ6ZBhi8lhlSyzu13rkHuCSJjLlR1UYd8xM6If2bjhdsZm49exlsly4r)BhiCb7aQaiypv5tMzW7jUwKwWWJ(3oq4c2buzBbCohfAr5sn)beSNQSHcf7dcD2u)Gog3xYeCFwsFH6lAa95AmUo1L(0H7tUsMmkPDFewsXRja1q5gohv(u1Nnog)DdNJ(XPKftDyQAYeCdfkII9j(OiajR7dP23t8(G4GFbUH67LIga1NCL0DQl9jRDWw23O9bXCmfLM(eF(kBbOgk3W5OYNQ(SXX4VB4C0poLSyQdtvLKyzuv2XKYfzTVN4Fc(f4gQqQ)IPnKOVPxROOIS23t8pb)cCdvKSBecn0T)bDdNJwK1(EI)Fhmxs9hHZLAgnB220Rvuurw77j(NGFbUHkac2tvcTkIwdfk2N4VK6dI5ykkn9j(8v2cq9fVM0(GDbZdOV9WY(Ca1N1Qy9nG(YO(4Acq9fpX4(EP(K5IMrPXvUpoHP(SuoX9X1uFkbrCFqWAx5bUpKuxSWoi5yL(eSr9zXjofmK6sFqmhtrPPpOpW5AX6REW7(8(K1oy3hp9bOiajR7JRP(ETIIAOCdNJkFQ6ZWoMIsZh4RSfGelJQI(E4IOetF2tLlCAeM6InB7Hlj8kP7ux(gNDjdM1A6VhUWPryQl2SThUihl8hmCHtJWuxqds0fhWsPObSqfyhtrP5hh4CTnBVwrrfyhtrP5hh4CDrYUri0QOnBYXc)L1oyliurRHcf7t8xs9bXCmfLM(eF(kBbO(4Ppypv2tTpUM6d2XuuA6loW56(ETII6Zs5e3NS2bBzFkr7(4PVxQVfsjGZ0UVOb0hxt9PeeX99AbKCFXtDpX7dD7rP(KKz0TSVu2h8aO(4Ax7tAffLMKuUpE6BHuc4m1xf7tw7GTeTgk3W5OYNQ(mSJPO08b(kBbiXYOQalLIgWcvGDmfLMFCGZ1qAMbVN4Arow4py4cGG9uLcYEucYxROOcSJPO08JdCUUaiypvj0Eydfk2heZtL9u7dI5ykkn9b9box3NZ95yCFCctY(IgqFCn1NDKbm4bS7Ba9jyQyG01(mJisDLBOCdNJkFQ6ZWoMIsZh4RSfGelJQcSukAalub2XuuA(Xboxdj6MrePUYfLmGbpGTnBMrePUYfHXaPROb5Rvuub2XuuA(XboxxaeSNQeApSHcf7t8xs9bXCmfLM(eF(kBbO(gTpiyTR8a3hsQlwyhKCS(mUKLI1hSlm1L(KwaQpE6t6IO(8(K1oy3hp9jz3iSpiMJPO00h0h4CDFzuFwYux6l5gk3W5OYNQ(mSJPO08b(kBbiXYOQSJjLlR1UYd8xM6If2bjhds03dxwRDLh4Vm1flSdsowHtJWuxSzZmdEpX1YATR8a)LPUyHDqYXkac2tvki7fpB2EhPesoHPpp)DsqZmdEpX1YATR8a)LPUyHDqYXkac2tvIgKOloGLsrdyHkWoMIsZpoW5AB2ETIIkWoMIsZpoW56IKDJqOvrB2KJf(lRDWwqOIwdLB4Cu5tvFg2XuuA(aFLTaKyzuv2XKYf5e)Z10xs0w2qHI99aap1(GUmI6lL9nkowFEFpaeePVfp1(INCDFcwLeLS)IP(EacoLuFk5G(GDiQpj7gHYsFc2O(IYLAUVu2N)owCF80hP7(2tF6W9bNszFYvs3PU0hxt9jz3iu2q5gohv(u1N3ap1poJiXYOQVwrrLujrj7Vy6Vj4usfj7gHc6HOKnBVwrrLujrj7Vy6Vj4usfRviFhPeYOCPM)ac2tvcTh2q5gohv(u1Nnog)DdNJ(XPKftDyQQzerQRCdLB4Cu5tvF2xgnMyMygm9zhSqSSkQILrvbueGK1(lMAOCdNJkFQ6ZwQK9xm99OiCA4CuXYOQUHtr0FpCXsLS)IPVhfHtdNJwfLSzJtJWuxGeqrasw7VyQHYnCoQ8PQplZ16r)4mIeZeZGPp7GfILvrvSmQkGIaKS2FXudLB4Cu5tvF2maG1kNJkMjMbtF2blelRIQyzuvafbizT)IjiDdNIOpPeCssO9WheD2XKYf5e)Z10xs0wAZg7ys5ImxRh9JZicTgk3W5OYNQ(CeMK1gGhXILrvLJf(n1Dr0GDoX0xoyrKYILktaG1k)ZOQVwrrfrd25etF5GfrkxSwBOCdNJkFQ6ZBGN6xowyXsLjaWALRIAdLB4Cu5tvFww77j()DWCdvdLB4CuzXhQ6ATR8a)LPUyHDqYXAOCdNJkl(qpv95A3s5gk3W5OYIp0tvF24y83nCo6hNswm1HPQBhiCb7a6VcOvXYOQMrePUYfrKY1XaqUhUKWRKUtD5BC2LmywRP)E4cNgHPUaPzg8EIRfPfm8O)TdeUGDavaKVJbj67HlR1UYd8xM6If2bjhRaiypvPGS3MnXXoMuUSw7kpWFzQlwyhKCm0SzZmIi1vUO5sn)JCcY9Wf5yH)GHlCAeM6cKMzW7jUwKwWWJ(3oq4c2bubq(ogKOVhUSw7kpWFzQlwyhKCScGG9uLcYEB2eh7ys5YATR8a)LPUyHDqYXqZMn0nJisDLlkzadEaBB2mJisDLlcJbsxTzZmIi1vUOJsOb5E4YATR8a)LPUyHDqYXkCAeM6cK7HlR1UYd8xM6If2bjhRaiypvj0SVHYnCoQS4d9u1NLeT)t03maG1kNJkwgvLDmPCroX)Cn9LeTLqAC9ljA3q5gohvw8HEQ6ZsI2)j6BgaWALZrflJQko2XKYf5e)Z10xs0wcP42dxKeT)t03maG1kNJw40im1fifxQ)iCUuZqUhUygaWALZrlakcqYA)ftnuUHZrLfFONQ(SVmAmXmXmy6ZoyHyzvuflJQ6gofr)9WfFz0yq7HqkU9WfFz0yfonctDPHYnCoQS4d9u1N9LrJjMjMbtF2blelRIQyzuv3WPi6VhU4lJgtqvFiKakcqYA)ftqUhU4lJgRWPryQlnuUHZrLfFONQ(SLkz)ftFpkcNgohvSmQQB4ue93dxSuj7Vy67rr40W5OvrjB240im1fibueGK1(lMAOCdNJkl(qpv9zlvY(lM(EueonCoQyMygm9zhSqSSkQILrvfhNgHPUa5QOv2XKYfGdV6k)9OiCA4CuzHu)ftBiDdNIO)E4ILkz)ftFpkcNgohfAvSHYnCoQS4d9u1NfLy6ZEQSyzuv5yH)YAhSfeQnuUHZrLfFONQ(SXX4VB4C0poLSyQdtvnJisDLftYG0WvrvSmQQ4mJisDLlkzadEa7gk3W5OYIp0tvF24y83nCo6hNswm1HPQBhiCb7a6VcOvXYOQOBgrK6kxerkxhdaj6MzW7jUws4vs3PU8no7sgmR1ubq(oMnB7Hlj8kP7ux(gNDjdM1A6VhUWPryQlObPzg8EIRfPfm8O)TdeUGDavaKVJbj67HlR1UYd8xM6If2bjhRaiypvPGS3MnXXoMuUSw7kpWFzQlwyhKCm0qds0r3mIi1vUOKbm4bSTzZmIi1vUimgiD1MnZiIux5IokHgKMzW7jUwKwWWJ(3oq4c2bubqWEQsOzpKOVhUSw7kpWFzQlwyhKCScGG9uLcYEB2eh7ys5YATR8a)LPUyHDqYXqdnB2q3mIi1vUO5sn)JCcs0nZG3tCTihl8hmCbq(oMnB7HlYXc)bdx40im1f0G0mdEpX1I0cgE0)2bcxWoGkac2tvcn7He99WL1Ax5b(ltDXc7GKJvaeSNQuq2BZM4yhtkxwRDLh4Vm1flSdsogAO1q5gohvw8HEQ6ZBhi8lhlSyzu13rkH0mdEpX1I0cgE0)2bcxWoGkac2tvkOOCPM)ac2tvcj6IJDmPCzT2vEG)YuxSWoi5y2SzMbVN4AzT2vEG)YuxSWoi5yfab7PkfuuUuZFab7PkrRHYnCoQS4d9u1N3oq4xowyXYOQVJucPzg8EIRfPfm8O)TdeUGDavaeSNQ8jZm49exlsly4r)BhiCb7aQSTaoNJcTOCPM)ac2tv2q5gohvw8HEQ6ZghJ)UHZr)4uYIPomvnzcUHYnCoQS4d9u1Nnog)DdNJ(XPKftDyQ6MWEmA)zqQcjw2q5gohvw8HEQ6ZghJ)UHZr)4uYIPomvD7W(c9zqQcjw2q5gohvw8HEQ6ZghJ)UHZr)4uYIPomvvYo)zqQcjwkMKbPHRIQyzu19WL1Ax5b(ltDXc7GKJv40im1fB2eh7ys5YATR8a)LPUyHDqYXAOCdNJkl(qpv9zyhtrP5d8v2cqILrv3dxeLy6ZEQCHtJWuxAOCdNJkl(qpv9zyhtrP5d8v2cqILrv3dxKJf(dgUWPryQlqko2XKYf5e)Z10xs0w2q5gohvw8HEQ6ZWoMIsZh4RSfGelJQko2XKYfrjM(SNk3q5gohvw8HEQ6ZWoMIsZh4RSfGelJQkhl8xw7GTGEydLB4CuzXh6PQplZ16r)4mIeZeZGPp7GfILvrvSmQQB4ue93dxK5A9OFCgrqRAfHeqrasw7VycsXThUiZ16r)4mIkCAeM6sdLB4CuzXh6PQpBCm(7goh9JtjlM6WuvZiIuxzXKminCvuflJQAgrK6kxuYag8a2nuUHZrLfFONQ(8g4P(Xzejwgv91kkQKkjkz)ft)nbNsQiz3iuqvfpuYMT3rkH81kkQKkjkz)ft)nbNsQyTczuUuZFab7PkHM4zZ2RvuujvsuY(lM(BcoLurYUrOGQwrXdY9Wf5yH)GHlCAeM6sdLB4CuzXh6PQphHjzTb4rSyzuv5yHFtDxenyNtm9LdwePSyPYeayTY)mQ6Rvuur0GDoX0xoyrKYfR1gk3W5OYIp0tvFEd8u)YXclwQmbawRCvuBOCdNJkl(qpv9zzTVN4)3bZnunuUHZrLfZiIux5Qj8kP7ux(gNDjdM1AsSmQQ4yhtkxwRDLh4Vm1flSdsogKOBMbVN4ArAbdp6F7aHlyhqfab7PkHgQOKnBMzW7jUwKwWWJ(3oq4c2bubqWEQsbjEOKnBMzW7jUwKwWWJ(3oq4c2bubqWEQsbzV4bPz0TvYfZaawRCQlFmra0AOCdNJklMrePUYpv95eEL0DQlFJZUKbZAnjwgvLDmPCzT2vEG)YuxSWoi5yqUhUSw7kpWFzQlwyhKCScNgHPU0q5gohvwmJisDLFQ6ZBYKWoN6Y)DWSyzuvZm49exlsly4r)BhiCb7aQaiypvPGepirFtVwrrLA3s5cGG9uLc6H2Sjo2XKYLA3sz0AOCdNJklMrePUYpv9z5yH)GHflJQko2XKYL1Ax5b(ltDXc7GKJbj6MzW7jUwKwWWJ(3oq4c2bubqWEQsOjE2SzMbVN4ArAbdp6F7aHlyhqfab7PkfK4Hs2SzMbVN4ArAbdp6F7aHlyhqfab7PkfK9IhKMr3wjxmdayTYPU8XebqRHYnCoQSygrK6k)u1NLJf(dgwSmQk7ys5YATR8a)LPUyHDqYXGCpCzT2vEG)YuxSWoi5yfonctDPHYnCoQSygrK6k)u1NLMXcK6YNtUMAOAOCdNJklBh2xOpdsviXYQws6NmblM6Wuv5yH)5IMmbAOCdNJklBh2xOpdsviXYNQ(SLK(jtWIPomvDdiFhLa6lIKsc3q5gohvw2oSVqFgKQqILpv9zlj9tMGftDyQ6co2A9FI(UuMWj25C0gk3W5OYY2H9f6ZGufsS8PQpBjPFYeSyQdtvTutTNkT)lyFNopa5xw7gHys2q5gohvw2oSVqFgKQqILpv9zlj9tMGftDyQk9oQCSWFrPHAOAOCdNJklBhiCb7a6VcO1QIsm9zpvUHYnCoQSSDGWfSdO)kGwFQ6ZBhi8lhlCdLB4Cuzz7aHlyhq)vaT(u1NxhohTHYnCoQSSDGWfSdO)kGwFQ6ZrjGEXZSBOCdNJklBhiCb7a6VcO1NQ(8lEM9pYceRHYnCoQSSDGWfSdO)kGwFQ6ZVeqsaHPU0q5gohvw2oq4c2b0FfqRpv9zJJXF3W5OFCkzXuhMQAgrK6klMKbPHRIQyzuvXzgrK6kxuYag8a2nuUHZrLLTdeUGDa9xb06tvFwAbdp6F7aHlyhqnunuUHZrLLnH9y0(ZGufsSSQLK(jtWIPomvLGxJbih)hWwD1qILrvr3mIi1vUO5sn)JCcsZm49exlYXc)bdxaeSNQeA2JsOzZg6MrePUYfrKY1XaqAMbVN4AjHxjDN6Y34SlzWSwtfab7PkHM9OeA2SHUzerQRCrjdyWdyBZMzerQRCrymq6QnBMrePUYfDucTgk3W5OYYMWEmA)zqQcjw(u1NTK0pzcwm1HPQsl9fpZ(7WexhtYILrvr3mIi1vUO5sn)JCcsZm49exlYXc)bdxaeSNQeAqp0SzdDZiIux5Iis56yainZG3tCTKWRKUtD5BC2LmywRPcGG9uLqd6HMnBOBgrK6kxuYag8a22SzgrK6kxegdKUAZMzerQRCrhLqRHYnCoQSSjShJ2FgKQqILpv9zlj9tMGftDyQQCSWyI5ux(aR3yILrvr3mIi1vUO5sn)JCcsZm49exlYXc)bdxaeSNQeAOq0SzdDZiIux5Iis56yainZG3tCTKWRKUtD5BC2LmywRPcGG9uLqdfIMnBOBgrK6kxuYag8a22SzgrK6kxegdKUAZMzerQRCrhLqRHYnCoQSSjShJ2FgKQqILpv9zlj9tMGftDyQQS23tCA)hW7FI(8aGjLflJQIUzerQRCrZLA(h5eKMzW7jUwKJf(dgUaiypvj0EiA2SHUzerQRCrePCDmaKMzW7jUws4vs3PU8no7sgmR1ubqWEQsO9q0SzdDZiIux5IsgWGhW2MnZiIux5IWyG0vB2mJisDLl6OeAnunuUHZrLL9W)vaTw1xgnMyzu19WfFz0yfab7PkHgkesZm49exlsly4r)BhiCb7aQaiypvPG2dx8LrJvaeSNQSHYnCoQSSh(VcO1NQ(SmxRh9JZisSmQ6E4ImxRh9JZiQaiypvj0qHqAMbVN4ArAbdp6F7aHlyhqfab7Pkf0E4ImxRh9JZiQaiypvzdLB4Cuzzp8FfqRpv9zlvY(lM(EueonCoQyzu19WflvY(lM(EueonCoAbqWEQsOHcH0mdEpX1I0cgE0)2bcxWoGkac2tvkO9WflvY(lM(EueonCoAbqWEQYgk3W5OYYE4)kGwFQ6ZMbaSw5CuXYOQ7HlMbaSw5C0cGG9uLqdfcPzg8EIRfPfm8O)TdeUGDavaeSNQuq7HlMbaSw5C0cGG9uLnunuUHZrLLKj4Qws6NmblBOAOCdNJklkzaZhoEvroi9xmjM6Wu19WYpNgHPUiMihBrv3dxmdayTY5Ofab7PkfK9qUhU4lJgRaiypvPGShY9WflvY(lM(EueonCoAbqWEQsbzpKOlo2XKYfzUwp6hNrKnB7HlYCTE0poJOcGG9uLcYE0AOqX(QeKQqIL954Cr7lEY19bbr6lAa9Hu77jEFqCWVa3qI13d8yFrdOpiaClLlnuUHZrLfLmG5dh)PQplYbP)IjXuhMQYGufs8FtypMyICSfv1mdEpX1YATR8a)LPUyHDqYXkac2tvkMihBrFclPQMzW7jUw2KjHDo1L)7G5cGG9uLInRvLeNrIzgDNCoAv2XKYfzTVN4Fc(f4gsSmQQzerQRCrjdyWdy3qHI99Ofq7tow4(K1oyl7lJ6JRP(IYLAUV4jg33l1hP7ux6toJwAOCdNJklkzaZho(tvFg2XuuA(aFLTaKyzuvoHPpp)DsqJGiYyX0Ntyccuow4VS2bBi3dxSuj7Vy67rr40W5OfonctDPHcf7dcDj3xTBPCF80hGIaKSUVxkAauFrogprrLgk3W5OYIsgW8HJ)u1NRDlLflJQUhUu7wkxaeSNQeA2)ebrKXIPpNWudfk2hea5sDFpyFRGCajhRpig0VpafbizDFzuFYvs3PU03OuFl451X9fFSW7(mULK6Zs2hp9bNszFCn13SUoa2stowF80hGIaKSUpig0V0xdLB4Cuzrjdy(WXFQ6ZWoMIsZh4RSfGelJQYjmjibpKVwrrfyhtrP5hh4CDbqWEQsOTy2fyhIEIGiYyX0NtyQHcf7dcycO(2e2Jr7(yqQcjw2xQ95kNMC15C0(MO(EaYKWoN6sFpoyU0q5gohvwuYaMpC8NQ(SLK(jtWIPomvLGxJbih)hWwD1qILrvf5G0FXuHbPkK4)MWEmOzpk1q5gohvwuYaMpC8NQ(SLK(jtWIPomvvAPV4z2FhM46yswSmQQihK(lMkmivHe)3e2JbnOxdLB4Cuzrjdy(WXFQ6Zws6NmblM6Wuv5yHXeZPU8bwVXelJQkYbP)IPcdsviX)nH9yqdf2q5gohvwuYaMpC8NQ(SLK(jtWIPomvvDyQQS23tCA)hW7FI(8aGjLflJQkYbP)IPcdsviX)nH9yq7HnuOyFc2O(4AQVvShJa9LY(SKPU0heaULYI1xucO(GGi9nAFMzW7jU2hxtAFrdgpX7lEY199ap2q5gohvwuYaMpC8NQ(8ATR8a)LPUyHDqYXelJQYoMuUu7wkdPihK(lMk7HLFonctDPHYnCoQSOKbmF44pv95nzsyNtD5)oywSmQk7ys5sTBPmKMzW7jUwwRDLh4Vm1flSdsowbqWEQsbHsnuOyFc2O(4AQVvShJa9LY(SKPU0hceNy9fLaQVh4X(gTpZm49ex7JRjTVObJN4PU0x8KR7dcI0q5gohvwuYaMpC8NQ(8MmjSZPU8FhmlwgvLDmPCrw77j(NGFbUHGuKds)ftL9WYpNgHPU0q5gohvwuYaMpC8NQ(8ATR8a)LPUyHDqYXelJQYoMuUiR99e)tWVa3qqAMbVN4AztMe25ux(VdMlac2tvkiuQHYnCoQSOKbmF44pv9zlvY(lM(EueonCoQyzu19WflvY(lM(EueonCoAbqWEQsOb9AOCdNJklkzaZho(tvF2xgnMyzu19WfFz0yfab7PkH2dBOCdNJklkzaZho(tvFwMR1J(XzejwgvDpCrMR1J(XzevaeSNQeApSHYnCoQSOKbmF44pv9zZaawRCoQyzu19WfZaawRCoAbqWEQsO9WgkuSpXhfbizDFqmOFFEetG(4AQVzLuc0xg132bcxWoG(RaATV4JfE3NXTKuFwY(4Pp4uk7Z7dIb97dqrasw3q5gohvwuYaMpC8NQ(mSJPO08b(kBbiXYOQCctcsWd5Rvuub2XuuA(XboxxaeSNQeA2dbUy2fyhIEIGiYyX0NtyQHcf7dcDmUVTdeUGDa9xb0AFzuFqWAx5bUpKuxSWoi5y9LY(mwaaPmowFCAeM6sdLB4Cuzrjdy(WXFQ6ZghJ)UHZr)4uYIPomvD7aHlyhq)vaTkMKbPHRIQyzu19WL1Ax5b(ltDXc7GKJv40im1LgkuSpXFoXPGbQpxJ13W1eOpj7CFmivHel7lJ6dcw7kpW9HK6If2bjhRVu2hNgHPU0q5gohvwuYaMpC8NQ(SXX4VB4C0poLSyQdtvLSZFgKQqILIjzqA4QOkwgvDpCzT2vEG)YuxSWoi5yfonctDPHcf7dHDJW(GyoMIstFqFGZ19XtFvuS(gqFakcqY6(IxtAFleZPU0hEI3h65MCmowF4zeM6sFrdOpVpJJnwyNPDFQf8lbeRVxlUVhwepzFac2tn1L(szFCn1hGKwyUVjQpMKCQl9fp56(Q0EbpAnuUHZrLfLmG5dh)PQpd7ykknFGVYwasSmQkNWKGe8qI(Rvuub2XuuA(XboxxKSBecTkAZ2Rvuub2XuuA(XboxxaeSNQeApSiEO1qHI9j427KZrDCFqmXxFYvs3Y(IxtAFeeXaVpzTd2Y(Ca1NlYtS)IP(CD3hLCnb6dcw7kpW9HK6If2bjhRVu2hNgHPUiwFdOpUM6lkxQ5(szFKUtDP0q5gohvwuYaMpC8NQ(mSJPO08b(kBbiXYOQOVhUSw7kpWFzQlwyhKCScNgHPUyZgNW0NN)ojOzMbVN4AzT2vEG)YuxSWoi5yfab7Pkrds0FTIIkWoMIsZpoW56IKDJqOvrB2KJf(lRDWwqOIwdfk2NGBVtoh1X99aap1(qglCFgxY9fVM0(GGi9LY(40im1Lgk3W5OYIsgW8HJ)u1N3ap1VCSWILrv3dxwRDLh4Vm1flSdsowHtJWuxAOqX(GUjEFpyFRGCajhRV9W9bOiajR7lEnP9bOiajR9xmvAOCdNJklkzaZho(tvF2xgnMyzuvafbizT)IPgk3W5OYIsgW8HJ)u1NTuj7Vy67rr40W5OILrvbueGK1(lMAOCdNJklkzaZho(tvF2maG1kNJkwgvfqrasw7VyQHYnCoQSOKbmF44pv9zzUwp6hNrKyzuv2XKYfzUwp6hNreKakcqYA)ftnuOyFqaXKS2a8iUpE6d2tL9u7tW4GDoXuFidwePCPHYnCoQSOKbmF44pv95imjRnapIflJQkhl8BQ7IOb7CIPVCWIiLfZ4QHW)mQ6Rvuur0GDoX0xoyrKY)AlyxNCxSwBOqX(GUj(dUcYbKCS(QDlL7dqraswxAOCdNJklkzaZho(tvFU2TuwSmQ6E4sTBPCbqWEQsOvXgkuSpXFnvMaaRvoFXuFpasFMAxvc3xg1xCQVAxe1hxt99ap23RvuuPHYnCoQSOKbmF44pv95nWt9lhlSyzu1xROOYMmjSZPU8FhmxSwBOCdNJklkzaZho(tvFEd8u)YXclwgvLDmPCrw77j(NGFbUHGCtVwrrfzTVN4Fc(f4gQaiypvj0QOnBB61kkQiR99e)tWVa3qfj7gHqRIILktaG1k)ZOQB61kkQiR99e)tWVa3qfj7gHcQAfHCtVwrrfzTVN4Fc(f4gQaiypvPGQydLB4Cuzrjdy(WXFQ6ZBGN6xowyXsLjaWALRIAdLB4Cuzrjdy(WXFQ6ZYAFpX)VdMBOAOCdNJklsQATBPCdLB4Cuzrspv95nWt9lhlSyPYeayTY)f8864QOkwQmbawR8pJQUPxROOIS23t8pb)cCdvKSBekOQvSHYnCoQSiPNQ(SS23t8)7G5gQgk3W5OYIKD(ZGufsSSQLK(jtWIPomvnvPbyX(lM(Oalxzl4)MeLgQHYnCoQSizN)mivHelFQ6Zws6NmblM6Wu1uLmWYWdq(3POuP)lHXnuUHZrLfj78NbPkKy5tvF2ss)KjyXuhMQoIiqeEIN6Y31e2)gFHAOCdNJkls25pdsviXYNQ(SLK(jtWIPomvD7aHWZO)nze(xTyajnKAOgk3W5OYIKD(ZGufsS8PQpBjPFYeSyQdtvHDJ)cOVSMi(dBjttdLB4CuzrYo)zqQcjw(u1NTK0pzcwm1HPQryhM(t0)1zgtnuUHZrLfj78NbPkKy5tvF2ss)KjyXuhMQg3fskbK)iWO7gk3W5OYIKD(ZGufsS8PQpBjPFYeSyQdtvz)ft8FI(BsU6jOHYnCoQSizN)mivHelFQ6Zws6NmblM6WuvzQrw4VlxtGRS8)67f6pr)icmMKJ1q5gohvwKSZFgKQqILpv9zlj9tMGftDyQQm1il8Fb7705bi)V(EH(t0pIaJj5ynuUHZrLfj78NbPkKy5tvF(fpZ(hzbI1q5gohvwKSZFgKQqILpv95OeqV4z2nuUHZrLfj78NbPkKy5tvF(Lascim1LgQgkuSpOp13Eub4(KwRRdG7RfmDFUSVkaXl(6l1(GolxS(KtFcwber9zgvebyA3hxNY(4PphKCnmXPP0q5gohvwyqQcj(lxXj)n1Kryvroi9xmjM6Wuv5kzsh)juGvUUsBXe5ylQk6OJkeiHcSY1vAxi41yaYX)bSvxneApHoQqGekWkxxPDjvPbyX(lM(Oalxzl4)MeLgcTNqhviqcfyLRR0UihlmMyo1LpW6ngApHoQqGekWkxxPDrAPV4z2FhM46ysgn0QIAdLB4CuzHbPkK4VCfN83utgHpv9zroi9xmjM6WuvgKQqI)JsIjYXwuv0zqQcjUGAP2L)vWyGKbPkK4cQLAx(nZG3tCfTgk3W5OYcdsviXF5ko5VPMmcFQ6ZICq6Vysm1HPQmivHe)54JyICSfvfDgKQqIl2xQD5FfmgizqQcjUyFP2LFZm49exrRHYnCoQSWGufs8xUIt(BQjJWNQ(SihK(lMetDyQ62H9f6ZGufsSyICSfvfDXHodsviXful1U8VcgdKmivHexqTu7YVzg8EIROHMnBOlo0zqQcjUyFP2L)vWyGKbPkK4I9LAx(nZG3tCfn0SzJqbw56kTll4yR1)j67szcNyNZrBOCdNJklmivHe)LR4K)MAYi8PQplYbP)IjXuhMQYGufs8xUItwmro2IQIUihK(lMkmivHe)hLGuKds)ftLTd7l0NbPkKy0SzdDroi9xmvyqQcj(ZXhif5G0FXuz7W(c9zqQcjgnB2qhviqroi9xmvyqQcj(pkH2tOJkeOihK(lMkYvYKo(tOaRCDL2OvfvB2qhviqroi9xmvyqQcj(ZXh0EcDuHaf5G0FXurUsM0XFcfyLRR0gTQOgqerazoAWo7rj7rfv7TxWhqI7an1fzab6l4eF2jyTdcquUV(QSM6lHxha3x0a6tagKQqI)YvCYFtnzekqFacfyLaA3NCGP(ClEGDM29zQDDHKLgkOlvQp7r5(GWrfraM29jadsviXfulvqG(4PpbyqQcjUWOwQGa9HU9qeALgkOlvQVkIY9bHJkIamT7tagKQqIl2xQGa9XtFcWGufsCHTVubb6dD7Hi0knuqxQuFpeL7dchvebyA3NamivHexqTubb6JN(eGbPkK4cJAPcc0h62drOvAOGUuP(Eik3heoQicW0UpbyqQcjUyFPcc0hp9jadsviXf2(sfeOp0ThIqR0q1qb9fCIp7eS2bbik3xFvwt9LWRdG7lAa9jGzerQRSa9biuGvcODFYbM6ZT4b2zA3NP21fswAOGUuP(qfL7dchvebyA3NaSJjLlvqG(4PpbyhtkxQqHu)ftBb6dDuHi0knuqxQuFOIY9bHJkIamT7taZOBRKlvqG(4PpbmJUTsUuHcP(lM2c0h6OcrOvAOGUuP(ShL7dchvebyA3NaSJjLlvqG(4PpbyhtkxQqHu)ftBb6dDuHi0knuqxQuFveL7dchvebyA3NaSJjLlvqG(4PpbyhtkxQqHu)ftBb6dDuHi0knuqxQuFpeL7dchvebyA3NaSJjLlvqG(4PpbyhtkxQqHu)ftBb6dDuHi0knuqxQuFpeL7dchvebyA3NaMr3wjxQGa9XtFcygDBLCPcfs9xmTfOp0rfIqR0qbDPs9jEOCFq4OIiat7(eGDmPCPcc0hp9ja7ys5sfkK6VyAlqFOJkeHwPHQHc6l4eF2jyTdcquUV(QSM6lHxha3x0a6tGnf5wywG(aekWkb0Up5at95w8a7mT7Zu76cjlnuqxQuFpeL7dchvebyA3NaSJjLlvqG(4PpbyhtkxQqHu)ftBb6Z5(G4G4HU(qhvicTsdf0Lk13dr5(GWrfraM29jaWsPObSqLkiqF80NaalLIgWcvQqHu)ftBb6dDuHi0knuqxQuFcEuUpiCureGPDFcWoMuUubb6JN(eGDmPCPcfs9xmTfOpN7dIdIh66dDuHi0knuqxQuFOquUpiCureGPDFcWGufsCb1sfeOpE6tagKQqIlmQLkiqFO)qicTsdf0Lk1hkeL7dchvebyA3NamivHexSVubb6JN(eGbPkK4cBFPcc0h6peIqR0qbDPs9HkkHY9bHJkIamT7ta2XKYLkiqF80NaSJjLlvOqQ)IPTa9HU9qeALgkOlvQpurfL7dchvebyA3NaSJjLlvqG(4PpbyhtkxQqHu)ftBb6dDuHi0knuqxQuFOwruUpiCureGPDFcWoMuUubb6JN(eGDmPCPcfs9xmTfOp0rfIqR0qbDPs9H6dr5(GWrfraM29jadsviXf)1umZG3tCvG(4PpbmZG3tCT4Vgb6dDuHi0knuqxQuFOkEOCFq4OIiat7(eGbPkK4I)AkMzW7jUkqF80NaMzW7jUw8xJa9HoQqeALgkOlvQpuHEOCFq4OIiat7(eayPu0awOsfeOpE6taGLsrdyHkvOqQ)IPTa9HoQqeALgkOlvQpuHEOCFq4OIiat7(eGbPkK4I)AkMzW7jUkqF80NaMzW7jUw8xJa9HoQqeALgkOlvQpuf8OCFq4OIiat7(eayPu0awOsfeOpE6taGLsrdyHkvOqQ)IPTa9HoQqeALgkOlvQpuf8OCFq4OIiat7(eGbPkK4I)AkMzW7jUkqF80NaMzW7jUw8xJa9HoQqeALgkOlvQp7ThL7dchvebyA3NaSJjLlvqG(4PpbyhtkxQqHu)ftBb6dDuHi0knuqxQuF2xruUpiCureGPDFcWoMuUubb6JN(eGDmPCPcfs9xmTfOp0rfIqR0qbDPs9zpkeL7dchvebyA3NaSJjLlvqG(4PpbyhtkxQqHu)ftBb6dD7Hi0knuqxQuFveLq5(GWrfraM29ja7ys5sfeOpE6ta2XKYLkui1FX0wG(q3EicTsdf0Lk1xfrfL7dchvebyA3NaSJjLlvqG(4PpbyhtkxQqHu)ftBb6dDuHi0knuqxQuFv0EuUpiCureGPDFcWoMuUubb6JN(eGDmPCPcfs9xmTfOp0rfIqR0qbDPs9vrXdL7dchvebyA3NaalLIgWcvQGa9XtFcaSukAaluPcfs9xmTfOp0rfIqR0qbDPs9vrOhk3heoQicW0UpbawkfnGfQubb6JN(eayPu0awOsfkK6VyAlqFOJkeHwPHc6sL6RIcEuUpiCureGPDFcaSukAaluPcc0hp9jaWsPObSqLkui1FX0wG(qhvicTsdf0Lk1xfrHOCFq4OIiat7(eGDmPCPcc0hp9ja7ys5sfkK6VyAlqFOJkeHwPHc6sL6RIOquUpiCureGPDFcaSukAaluPcc0hp9jaWsPObSqLkui1FX0wG(qhvicTsdf0Lk1xff)q5(GWrfraM29ja7ys5sfeOpE6ta2XKYLkui1FX0wG(CUpioiEORp0rfIqR0qbDPs99qXdL7dchvebyA3NaSJjLlvqG(4PpbyhtkxQqHu)ftBb6dD7Hi0knuqxQuFpe6HY9bHJkIamT7ta5yHFtDxQGa9XtFcihl8BQ7sfkK6VyAlqFo3hehep01h6OcrOvAOAOG(coXNDcw7GaeL7RVkRP(s41bW9fnG(eWhsG(aekWkb0Up5at95w8a7mT7Zu76cjlnuqxQuFveL7dchvebyA3NaSJjLlvqG(4PpbyhtkxQqHu)ftBb6dD7Hi0knuqxQuFpeL7dchvebyA3NaSJjLlvqG(4PpbyhtkxQqHu)ftBb6dDuHi0knuqxQuFIhk3heoQicW0UpbyhtkxQGa9XtFcWoMuUuHcP(lM2c0h6OcrOvAOGUuP(q1EuUpiCureGPDFcWoMuUubb6JN(eGDmPCPcfs9xmTfOp0RieHwPHc6sL6d1kIY9bHJkIamT7ta2XKYLkiqF80NaSJjLlvOqQ)IPTa9HoQqeALgkOlvQpurHOCFq4OIiat7(eGDmPCPcc0hp9ja7ys5sfkK6VyAlqFo3hehep01h6OcrOvAOGUuP(ShLq5(GWrfraM29ja7ys5sfeOpE6ta2XKYLkui1FX0wG(CUpioiEORp0rfIqR0qbDPs9zpQOCFq4OIiat7(eGDmPCPcc0hp9ja7ys5sfkK6VyAlqFo3hehep01h6OcrOvAOGUuP(Sh6HY9bHJkIamT7ta5yHFtDxQGa9XtFcihl8BQ7sfkK6VyAlqFo3hehep01h6OcrOvAOAOG(coXNDcw7GaeL7RVkRP(s41bW9fnG(eqjdy(WXfOpaHcSsaT7toWuFUfpWot7(m1UUqYsdf0Lk1hQOCFq4OIiat7(eGDmPCPcc0hp9ja7ys5sfkK6VyAlqFOJkeHwPHc6sL6ZEuUpiCureGPDFcWoMuUubb6JN(eGDmPCPcfs9xmTfOpN7dIdIh66dDuHi0knuqxQuFOIsOCFq4OIiat7(eGDmPCPcc0hp9ja7ys5sfkK6VyAlqFOJkeHwPHc6sL6dvur5(GWrfraM29ja7ys5sfeOpE6ta2XKYLkui1FX0wG(qhvicTsdf0Lk1hQ2JY9bHJkIamT7ta2XKYLkiqF80NaSJjLlvOqQ)IPTa9HoQqeALgkOlvQpuRik3heoQicW0UpbyhtkxQGa9XtFcWoMuUuHcP(lM2c0h6OcrOvAOGUuP(SxWJY9bHJkIamT7ta2XKYLkiqF80NaSJjLlvOqQ)IPTa9HoQqeALgkOlvQp7rHOCFq4OIiat7(eqow43u3LkiqF80NaYXc)M6UuHcP(lM2c0NZ9bXbXdD9HoQqeALgkOlvQVkIkk3heoQicW0UpbyhtkxQGa9XtFcWoMuUuHcP(lM2c0h6OcrOvAOAOeSWRdGPDFOwX(CdNJ2hoLSS0qfqWPKLHkdis25pdsviXYqLb7qnuzaHu)ft7WJbe1HPasQsdWI9xm9rbwUYwW)njknuaXnCoAajvPbyX(lM(Oalxzl4)MeLgkWb7SpuzaHu)ft7WJbe1HPasQsgyz4bi)7uuQ0)LW4aIB4C0asQsgyz4bi)7uuQ0)LW4ahSRIHkdiK6VyAhEmGOomfqgreicpXtD57Ac7FJVqbe3W5ObKrebIWt8ux(UMW(34luGd29WqLbes9xmTdpgquhMciBhieEg9VjJW)QfdiPHudfqCdNJgq2oqi8m6FtgH)vlgqsdPgkWb7eVqLbes9xmTdpgquhMciWUXFb0xwte)HTKPjG4gohnGa7g)fqFznr8h2sMMahSd6fQmGqQ)IPD4XaI6Wuajc7W0FI(VoZykG4gohnGeHDy6pr)xNzmf4GDc(qLbes9xmTdpgquhMciXDHKsa5pcm6oG4gohnGe3fskbK)iWO7ahSdfgQmGqQ)IPD4XaI6WuaH9xmX)j6Vj5QNGaIB4C0ac7VyI)t0FtYvpbboyN4xOYacP(lM2HhdiQdtbezQrw4VlxtGRS8)67f6pr)icmMKJfqCdNJgqKPgzH)UCnbUYY)RVxO)e9JiWysowGd2HkkfQmGqQ)IPD4XaI6WuarMAKf(VG9D68aK)xFVq)j6hrGXKCSaIB4C0aIm1il8Fb7705bi)V(EH(t0pIaJj5yboyhQOgQmG4gohnG8INz)JSaXciK6VyAhEmWb7q1(qLbe3W5ObKOeqV4z2bes9xmTdpg4GDOwXqLbe3W5ObKxcijGWuxciK6VyAhEmWboGWGufs8xUIt(BQjJWqLb7qnuzaHu)ft7WJbKznGijoG4gohnGiYbP)IPaIihBrbe07d9(qTpiW(iuGvUUs7cbVgdqo(pGT6QH6dT(EQp07d1(Ga7Jqbw56kTlPknal2FX0hfy5kBb)3KO0q9HwFp1h69HAFqG9rOaRCDL2f5yHXeZPU8bwVX6dT(EQp07d1(Ga7Jqbw56kTlsl9fpZ(7WexhtY9HwFO1x1(qnGSjPbKRCoAab6t9ThvaUpP166a4(ciICWxDykGixjt64pHcSY1vAh4GD2hQmGqQ)IPD4XaYSgqKehqCdNJgqe5G0FXuarKJTOac69XGufsCHrTu7Y)kym9bzFmivHexyul1U8BMbVN4AFOfqe5GV6WuaHbPkK4)OuGd2vXqLbes9xmTdpgqM1aIK4aIB4C0aIihK(lMciICSffqqVpgKQqIlS9LAx(xbJPpi7JbPkK4cBFP2LFZm49ex7dTaIih8vhMcimivHe)54tGd29WqLbes9xmTdpgqM1aIK4aIB4C0aIihK(lMciICSffqqVpX1h69XGufsCHrTu7Y)kym9bzFmivHexyul1U8BMbVN4AFO1hA9zZwFO3N46d9(yqQcjUW2xQD5FfmM(GSpgKQqIlS9LAx(nZG3tCTp06dT(SzRpcfyLRR0USGJTw)NOVlLjCIDohnGiYbF1HPaY2H9f6ZGufsCGd2jEHkdiK6VyAhEmGmRbejXbe3W5Oberoi9xmfqe5ylkGGEFICq6VyQWGufs8FuQpi7tKds)ftLTd7l0NbPkK4(qRpB26d9(e5G0FXuHbPkK4phF6dY(e5G0FXuz7W(c9zqQcjUp06ZMT(qVpu7dcSproi9xmvyqQcj(pk1hA99uFO3hQ9bb2NihK(lMkYvYKo(tOaRCDL29HwFv7d1(SzRp07d1(Ga7tKds)ftfgKQqI)C8Pp067P(qVpu7dcSproi9xmvKRKjD8Nqbw56kT7dT(Q2hQbero4RomfqyqQcj(lxXjh4ahq2oSVqFgKQqILHkd2HAOYacP(lM2HhdiQdtbe5yH)5IMmbciUHZrdiYXc)Zfnzce4GD2hQmGqQ)IPD4XaI6WuazdiFhLa6lIKschqCdNJgq2aY3rjG(IiPKWboyxfdvgqi1FX0o8yarDykGSGJTw)NOVlLjCIDohnG4gohnGSGJTw)NOVlLjCIDohnWb7EyOYacP(lM2HhdiQdtbel1u7Ps7)c23PZdq(L1UriMKbe3W5Obel1u7Ps7)c23PZdq(L1UriMKboyN4fQmGqQ)IPD4XaI6WuaHEhvow4VO0qbe3W5Obe6Du5yH)Isdf4ahq2e2Jr7pdsviXYqLb7qnuzaHu)ft7WJbe3W5ObecEngGC8FaB1vdfqmGKjq6be07ZmIi1vUO5sn)JCQpi7ZmdEpX1ICSWFWWfab7Pk7dA9zpk1hA9zZwFO3NzerQRCrePCDmqFq2Nzg8EIRLeEL0DQlFJZUKbZAnvaeSNQSpO1N9OuFO1NnB9HEFMrePUYfLmGbpGDF2S1NzerQRCrymq6AF2S1NzerQRCrhL6dTaI6WuaHGxJbih)hWwD1qboyN9HkdiK6VyAhEmG4gohnGiT0x8m7VdtCDmjhqmGKjq6be07ZmIi1vUO5sn)JCQpi7ZmdEpX1ICSWFWWfab7Pk7dA9b96dT(SzRp07ZmIi1vUiIuUogOpi7ZmdEpX1scVs6o1LVXzxYGzTMkac2tv2h06d61hA9zZwFO3NzerQRCrjdyWdy3NnB9zgrK6kxegdKU2NnB9zgrK6kx0rP(qlGOomfqKw6lEM93HjUoMKdCWUkgQmGqQ)IPD4XaIB4C0aICSWyI5ux(aR3ybedizcKEab9(mJisDLlAUuZ)iN6dY(mZG3tCTihl8hmCbqWEQY(GwFOW(qRpB26d9(mJisDLlIiLRJb6dY(mZG3tCTKWRKUtD5BC2LmywRPcGG9uL9bT(qH9HwF2S1h69zgrK6kxuYag8a29zZwFMrePUYfHXaPR9zZwFMrePUYfDuQp0ciQdtbe5yHXeZPU8bwVXcCWUhgQmGqQ)IPD4XaIB4C0aIS23tCA)hW7FI(8aGjLdigqYei9ac69zgrK6kx0CPM)ro1hK9zMbVN4Arow4py4cGG9uL9bT(EyFO1NnB9HEFMrePUYfrKY1Xa9bzFMzW7jUws4vs3PU8no7sgmR1ubqWEQY(GwFpSp06ZMT(qVpZiIux5IsgWGhWUpB26ZmIi1vUimgiDTpB26ZmIi1vUOJs9HwarDykGiR99eN2)b8(NOppays5ah4aY2bcxWoG(RaAnuzWoudvgqCdNJgqeLy6ZEQCaHu)ft7WJboyN9HkdiUHZrdiBhi8lhlCaHu)ft7WJboyxfdvgqCdNJgqwhohnGqQ)IPD4XahS7HHkdiUHZrdirjGEXZSdiK6VyAhEmWb7eVqLbe3W5ObKx8m7FKfiwaHu)ft7WJboyh0luzaXnCoAa5Lascim1LacP(lM2HhdCWobFOYacP(lM2HhdigqYei9aI46ZmIi1vUOKbm4bSdisgKgoyhQbe3W5ObeJJXF3W5OFCk5acoL8xDykGygrK6kh4GDOWqLbe3W5ObePfm8O)TdeUGDafqi1FX0o8yGdCaXmIi1vouzWoudvgqi1FX0o8yaXasMaPhqexFSJjLlR1UYd8xM6If2bjhRqQ)IPDFq2h69zMbVN4ArAbdp6F7aHlyhqfab7Pk7dA9Hkk1NnB9zMbVN4ArAbdp6F7aHlyhqfab7Pk7tq9jEOuF2S1Nzg8EIRfPfm8O)TdeUGDavaeSNQSpb1N9IxFq2Nz0TvYfZaawRCQlFmrGcP(lM29HwaXnCoAajHxjDN6Y34SlzWSwtboyN9HkdiK6VyAhEmGyajtG0diSJjLlR1UYd8xM6If2bjhRqQ)IPDFq23E4YATR8a)LPUyHDqYXkCAeM6saXnCoAajHxjDN6Y34SlzWSwtboyxfdvgqi1FX0o8yaXasMaPhqmZG3tCTiTGHh9VDGWfSdOcGG9uL9jO(eV(GSp07BtVwrrLA3s5cGG9uL9jO(EyF2S1N46JDmPCP2TuUqQ)IPDFOfqCdNJgq2KjHDo1L)7G5ahS7HHkdiK6VyAhEmGyajtG0diIRp2XKYL1Ax5b(ltDXc7GKJvi1FX0Upi7d9(mZG3tCTiTGHh9VDGWfSdOcGG9uL9bT(eV(SzRpZm49exlsly4r)BhiCb7aQaiypvzFcQpXdL6ZMT(mZG3tCTiTGHh9VDGWfSdOcGG9uL9jO(Sx86dY(mJUTsUygaWALtD5Jjcui1FX0Up0ciUHZrdiYXc)bdh4GDIxOYacP(lM2HhdigqYei9ac7ys5YATR8a)LPUyHDqYXkK6VyA3hK9ThUSw7kpWFzQlwyhKCScNgHPUeqCdNJgqKJf(dgoWb7GEHkdiUHZrdisZybsD5Zjxtbes9xmTdpg4ahq2d)xb0AOYGDOgQmGqQ)IPD4XaIbKmbspGShU4lJgRaiypvzFqRpuyFq2Nzg8EIRfPfm8O)TdeUGDavaeSNQSpb13E4IVmAScGG9uLbe3W5ObeFz0yboyN9HkdiK6VyAhEmGyajtG0di7HlYCTE0poJOcGG9uL9bT(qH9bzFMzW7jUwKwWWJ(3oq4c2bubqWEQY(euF7HlYCTE0poJOcGG9uLbe3W5ObezUwp6hNruGd2vXqLbes9xmTdpgqmGKjq6bK9WflvY(lM(EueonCoAbqWEQY(GwFOW(GSpZm49exlsly4r)BhiCb7aQaiypvzFcQV9WflvY(lM(EueonCoAbqWEQYaIB4C0aILkz)ftFpkcNgohnWb7EyOYacP(lM2HhdigqYei9aYE4IzaaRvohTaiypvzFqRpuyFq2Nzg8EIRfPfm8O)TdeUGDavaeSNQSpb13E4IzaaRvohTaiypvzaXnCoAaXmaG1kNJg4ahq2uKBH5qLb7qnuzaXnCoAarUsy8hpgHbes9xmTdpg4GD2hQmG4gohnGSjrJf4d7lPjGqQ)IPD4XahSRIHkdiK6VyAhEmGyajtG0diUHtr0NucojzFcQVkgqKminCWoudiUHZrdighJ)UHZr)4uYbeCk5V6WuaXhkWb7EyOYacP(lM2HhdiBsAa5kNJgqGqhJ7tsRoWzQp3W5O9Htj3x0a6ZoYag8a29bXG(9LAFivw6dcTaaszCS(gfhRVzLt4uWaT7lAa9zjP(INCDFqqKsaXnCoAabyPF3W5OFCk5aIKbPHd2HAaXasMaPhqmJisDLlkzadEa7(GSpGLsrdyHkWoMIsZpoW56cP(lM29bzFUHtr0NucojzFv7d1(GSp2XKYL1Ax5b(ltDXc7GKJvi1FX0oGGtj)vhMcikzaZhoEGd2jEHkdiK6VyAhEmGSjPbKRCoAarWz4C0(WPKL9fnG(yqQcjUVxQ2fLdO0hc7SSphq9jDr0UVOb03lfnaQpKXc3N4B4NfSWRKUtDPpi0zxYGzTMEgcw7kpW9HK6If2bjhtS(gUMaXtj13O9zMbVN4AjG4gohnGyCm(7goh9JtjhqWPK)QdtbegKQqI)YvCYFtnzeg4GDqVqLbes9xmTdpgqCdNJgqmog)DdNJ(XPKdi4uYF1HPaYMWEmA)zqQcjwg4GDc(qLbes9xmTdpgqmGKjq6be07BpCrow4py4cNgHPU0NnB9ThUKWRKUtD5BC2LmywRP)E4cNgHPU0NnB9ThUSw7kpWFzQlwyhKCScNgHPU0hA9bzFYXc)L1oy3NG6RI9zZwF7HlIsm9zpvUWPryQl9zZwFSJjLlYj(NRPVKOTSqQ)IPDarYG0Wb7qnG4gohnGyCm(7goh9JtjhqWPK)Qdtbej78NbPkKyzGd2Hcdvgqi1FX0o8yaXasMaPhqmJisDLlAUuZ)iN6dY(qVpX1NihK(lMkmivHe)LR4K7ZMT(mZG3tCTihl8hmCbqWEQY(euF2Js9zZwFO3NihK(lMkmivHe)hL6dY(mZG3tCTihl8hmCbqWEQY(GwFmivHexyulMzW7jUwaeSNQSp06ZMT(qVproi9xmvyqQcj(ZXN(GSpZm49exlYXc)bdxaeSNQSpO1hdsviXf2(Izg8EIRfab7Pk7dT(qRpB26ZmIi1vUiIuUogOpi7d9(exFICq6VyQWGufs8xUItUpB26ZmdEpX1scVs6o1LVXzxYGzTMkac2tv2NG6ZEuQpB26d9(e5G0FXuHbPkK4)OuFq2Nzg8EIRLeEL0DQlFJZUKbZAnvaeSNQSpO1hdsviXfg1Izg8EIRfab7Pk7dT(SzRp07tKds)ftfgKQqI)C8Ppi7ZmdEpX1scVs6o1LVXzxYGzTMkac2tv2h06JbPkK4cBFXmdEpX1cGG9uL9HwFO1NnB9HEFMrePUYfLmGbpGDF2S1NzerQRCrymq6AF2S1NzerQRCrhL6dT(GSp07tC9jYbP)IPcdsviXF5ko5(SzRpZm49exlR1UYd8xM6If2bjhRaiypvzFcQp7rP(SzRp07tKds)ftfgKQqI)Js9bzFMzW7jUwwRDLh4Vm1flSdsowbqWEQY(GwFmivHexyulMzW7jUwaeSNQSp06ZMT(qVproi9xmvyqQcj(ZXN(GSpZm49exlR1UYd8xM6If2bjhRaiypvzFqRpgKQqIlS9fZm49exlac2tv2hA9HwF2S1N46JDmPCzT2vEG)YuxSWoi5yfs9xmT7dY(qVpX1NihK(lMkmivHe)LR4K7ZMT(mZG3tCTiTGHh9VDGWfSdOcGG9uL9jO(ShL6ZMT(qVproi9xmvyqQcj(pk1hK9zMbVN4ArAbdp6F7aHlyhqfab7Pk7dA9XGufsCHrTyMbVN4AbqWEQY(qRpB26d9(e5G0FXuHbPkK4phF6dY(mZG3tCTiTGHh9VDGWfSdOcGG9uL9bT(yqQcjUW2xmZG3tCTaiypvzFO1hAbe3W5ObeJJXF3W5OFCk5acoL8xDykGSDyFH(mivHeldCWoXVqLbes9xmTdpgqCdNJgqGDmfLMpWxzlafq2K0aYvohnG8Ofq7tow4(K1oyl7lJ6lkxQ5(szFogEKCFJiceqmGKjq6bK3rk7dY(IYLA(diypvzFqRpcIiJftFoHP(Ga7tow4VS2b7(GSV9WflvY(lM(EueonCoAHtJWuxcCWourPqLbes9xmTdpgq2K0aYvohnGiyJ6ZmIi1vUV9WpdbRDLh4(qsDXc7GKJ1xk7dyPAQlI1NLK67bCGWfSdO(4PpcIys39X1uFglaGuUpjXbe3W5ObeJJXF3W5OFCk5aIbKmbspGGEFMrePUYfrKY1Xa9bzF7Hlj8kP7ux(gNDjdM1A6VhUWPryQl9bzFMzW7jUwKwWWJ(3oq4c2bubqWEQY(GwF23hK9HEF7HlR1UYd8xM6If2bjhRaiypvzFcQp77ZMT(exFSJjLlR1UYd8xM6If2bjhRqQ)IPDFO1hA9zZwFO3NzerQRCrZLA(h5uFq23E4ICSWFWWfonctDPpi7ZmdEpX1I0cgE0)2bcxWoGkac2tv2h06Z((GSp07BpCzT2vEG)YuxSWoi5yfab7Pk7tq9zFF2S1N46JDmPCzT2vEG)YuxSWoi5yfs9xmT7dT(qRpB26d9(qVpZiIux5IsgWGhWUpB26ZmIi1vUimgiDTpB26ZmIi1vUOJs9HwFq23E4YATR8a)LPUyHDqYXkCAeM6sFq23E4YATR8a)LPUyHDqYXkac2tv2h06Z((qlGGtj)vhMciBhiCb7a6VcO1ahSdvudvgqi1FX0o8yaztsdix5C0aI4JIaKSUV9WY(ihGJ1xg13YK6sFPYtFEFYAhS7tUs6o1L(wRDjfqCdNJgqmog)DdNJ(XPKdigqYei9ac69zgrK6kx0CPM)ro1hK9jU(2dxKJf(dgUWPryQl9bzFMzW7jUwKJf(dgUaiypvzFqRVh2hA9zZwFO3NzerQRCrePCDmqFq2N46BpCjHxjDN6Y34SlzWSwt)9WfonctDPpi7ZmdEpX1scVs6o1LVXzxYGzTMkac2tv2h067H9HwF2S1h69HEFMrePUYfLmGbpGDF2S1NzerQRCrymq6AF2S1NzerQRCrhL6dT(GSp2XKYL1Ax5b(ltDXc7GKJvi1FX0Upi7tC9ThUSw7kpWFzQlwyhKCScNgHPU0hK9zMbVN4AzT2vEG)YuxSWoi5yfab7Pk7dA99W(qlGGtj)vhMci7H)RaAnWb7q1(qLbes9xmTdpgqCdNJgq2oq4xow4aYMKgqUY5ObebBuFqWAx5bUpKuxSWoi5y9LY(40im1fX6l5(szFspI6JN(SKuFpGde2hYyHdigqYei9aYE4YATR8a)LPUyHDqYXkCAeM6sGd2HAfdvgqi1FX0o8yaXasMaPhqexFSJjLlR1UYd8xM6If2bjhRqQ)IPDFq2h69ThUihl8hmCHtJWux6ZMT(2dxs4vs3PU8no7sgmR10FpCHtJWux6dTaIB4C0aY2bc)YXch4GDO(WqLbes9xmTdpgqCdNJgqwRDLh4Vm1flSdsowaztsdix5C0acsm10heS2vEG7dj1flSdsowFXtUUpbJKY1XapBxUuZ9bb0P(mJisDL7BpSy9nCnbINsQplj13O9zMbVN4APpbBuFqCWRXaKJ7dIhSvxnuFVwrr9LY(s1mWPUiwF1dE3NLYjUVKfq2hG8DS(qhvuyFsYm6w2NhXeOpljHwaXasMaPhqmJisDLlAUuZ)iN6dY(4eM6tq9jE9bzFMzW7jUwKJf(dgUaiypvzFqRpu7dY(qVpZm49exle8Ama54)a2QRgQaiypvzFqRpuHE23NnB9jU(iuGvUUs7cbVgdqo(pGT6QH6dTahSdvXluzaHu)ft7WJbedizcKEaXmIi1vUiIuUogOpi7JtyQpb1N41hK9zMbVN4AjHxjDN6Y34SlzWSwtfab7Pk7dA9HAFq2h69zMbVN4AHGxJbih)hWwD1qfab7Pk7dA9Hk0Z((SzRpX1hHcSY1vAxi41yaYX)bSvxnuFOfqCdNJgqwRDLh4Vm1flSdsowGd2Hk0luzaHu)ft7WJbe3W5ObK1Ax5b(ltDXc7GKJfq2K0aYvohnGyhzadEa7(INCDFqmhtrPPpOpW56(mUKL9Tw7kpW9jtDXc7GKJ1xQ9HtL6lEY199aKjHDo1L(ECWCaXasMaPhqmJisDLlkzadEa7(GSpGLsrdyHkWoMIsZpoW56cP(lM29bzFCct9jO(eV(GSpZm49exlBYKWoN6Y)DWCbqWEQY(GwFvSpi7d9(mZG3tCTqWRXaKJ)dyRUAOcGG9uL9bT(qf6zFF2S1N46Jqbw56kTle8Ama54)a2QRgQp0cCWouf8HkdiK6VyAhEmG4gohnGSw7kpWFzQlwyhKCSaYMKgqUY5ObeiEUMa9zgrK6kl7d9unyRDQl9PJ(GqmOFF2rgWGwFgxY9bbr6B0(mZG3tCnGyajtG0diO3NzerQRCrymq6AF2S1NzerQRCrhL6ZMT(qVpZiIux5IsgWGhWUpi7tC9bSukAalub2XuuA(Xboxxi1FX0Up06dT(GSp07ZmdEpX1cbVgdqo(pGT6QHkac2tv2h06dvON99zZwFIRpcfyLRR0UqWRXaKJ)dyRUAO(qlWb7qffgQmGqQ)IPD4XaIbKmbspG8oszFq2xuUuZFab7Pk7dA9Hk0lG4gohnGSw7kpWFzQlwyhKCSahSdvXVqLbes9xmTdpgq2K0aYvohnGiyJ6dcw7kpW9HK6If2bjhRVu2hNgHPUiwFjlGSpoHP(4Pplj13W1eOpyxW8a6BpSmG4gohnGyCm(7goh9JtjhqKminCWoudigqYei9aYE4YATR8a)LPUyHDqYXkCAeM6sFq2h69zgrK6kx0CPM)ro1NnB9zgrK6kxerkxhd0hAbeCk5V6WuaXmIi1voWb7ShLcvgqi1FX0o8yaXnCoAaXxgnwaXasMaPhq2dx8LrJvaeSNQSpO13ddiMygm9zhSqSmyhQboyN9OgQmG4gohnGu7wkhqi1FX0o8yGd2zV9HkdiK6VyAhEmG4gohnGijA)NOVzaaRvohnGSjPbKRCoAabzI3hxt9Hq0w23O9vX(yhSqSSVmQVK7lLQaCFglaGughRVu7lcNl1CFdOVr7JRP(yhSqCPpOFY19HKR1J2h0LruFjlGSphlN(EjMjqF80NLK6dHODFJic0hSRwoghRpFDfhl1L(QyFq4aawRCoQSeqmGKjq6be3WPi6tkbNKSpb1N99bzFSJjLlYj(NRPVKOTSqQ)IPDFq2N46BpCrs0(prFZaawRCoAHtJWux6dY(exFP(JW5snh4GD2xXqLbes9xmTdpgqmGKjq6be3WPi6tkbNKSpb1N99bzFSJjLlYCTE0poJOcP(lM29bzFIRV9Wfjr7)e9ndayTY5OfonctDPpi7tC9L6pcNl1CFq23E4IzaaRvohTaiypvzFqRVhgqCdNJgqKeT)t03maG1kNJg4GD2)WqLbes9xmTdpgqmGKjq6be07tow4VS2b7(euFO2NnB95gofrFsj4KK9jO(SVp06dY(mZG3tCTiTGHh9VDGWfSdOcGG9uL9jO(q1(aIB4C0aIOetF2tLdCWo7fVqLbes9xmTdpgqmGKjq6be3WPi6VhUyPs2FX03JIWPHZr7RAFOuF2S1hNgHPU0hK9ThUyPs2FX03JIWPHZrlac2tv2h067Hbe3W5ObelvY(lM(EueonCoAGd2zp0luzaHu)ft7WJbe3W5ObezUwp6hNruaXasMaPhq2dxK5A9OFCgrfab7Pk7dA99WaIjMbtF2bleld2HAGd2zVGpuzaHu)ft7WJbedizcKEarC9zgrK6kxuYag8a2bejdsdhSd1aIB4C0aIXX4VB4C0poLCabNs(RomfqmJisDLdCWo7rHHkdiK6VyAhEmG4gohnGygaWALZrdiMygm9zhSqSmyhQbedizcKEaXnCkI(KsWjj7dA99W(EW(qVp2XKYf5e)Z10xs0wwi1FX0UpB26JDmPCrMR1J(Xzevi1FX0Up06dY(2dxmdayTY5Ofab7Pk7dA9zFaztsdix5C0aIGBDfhRpiCaaRvohTpyxTCmowFJ2hQpO99XoyHyPy9nG(gTVk2x8KR7tW9khSft9bHdayTY5OboyN9IFHkdiK6VyAhEmG4gohnGa7ykknFGVYwakGSjPbKRCoAarWfXeOpUM6BwjLaI1NCL0DFEFYAhS7lEnP95CFIxFJ2heZXuuA6t85RSfG6JN(CrtU7BeraJVUM6saXasMaPhqKJf(lRDWUpb13d7dY(4eM6tq9zpQboyxfrPqLbes9xmTdpgq2K0aYvohnGa9RjTpD4(KXutQl9bbRDLh4(qsDXc7GKJ1hp9jyKuUog4z7YLAUpiGojwFiwWWJ23d4aHlyhq9Lr95yCF7HL95aQpFDfN0oG4gohnGyCm(7goh9JtjhqmGKjq6be07ZmIi1vUiIuUogOpi7tC9XoMuUSw7kpWFzQlwyhKCScP(lM29bzF7Hlj8kP7ux(gNDjdM1A6VhUWPryQl9bzFMzW7jUwKwWWJ(3oq4c2bubq(owFO1NnB9HEFMrePUYfnxQ5FKt9bzFIRp2XKYL1Ax5b(ltDXc7GKJvi1FX0Upi7BpCrow4py4cNgHPU0hK9zMbVN4ArAbdp6F7aHlyhqfa57y9HwF2S1h69HEFMrePUYfLmGbpGDF2S1NzerQRCrymq6AF2S1NzerQRCrhL6dT(GSpZm49exlsly4r)BhiCb7aQaiFhRp0ci4uYF1HPaY2bcxWoG(RaAnWb7QiQHkdiK6VyAhEmG4gohnGSDGWVCSWbKnjnGCLZrdiI)sQVhWbc7dzSW9Lr99aoq4c2buFXhvaUVxQpa57y95lEQI13a6lJ6JRja1x8eJ77L6Z5(WKl5(SVp4bq99aoq4c2buFwssgqmGKjq6bK3rk7dY(mZG3tCTiTGHh9VDGWfSdOcGG9uL9jO(IYLA(diypvzFq2h69jU(yhtkxwRDLh4Vm1flSdsowHu)ft7(SzRpZm49exlR1UYd8xM6If2bjhRaiypvzFcQVOCPM)ac2tv2hAboyxfTpuzaHu)ft7WJbedizcKEa5DKY(GSpX1h7ys5YATR8a)LPUyHDqYXkK6VyA3hK9zMbVN4ArAbdp6F7aHlyhqfab7Pk77P(mZG3tCTiTGHh9VDGWfSdOY2c4CoAFqRVOCPM)ac2tvgqCdNJgq2oq4xow4ahSRIvmuzaHu)ft7WJbKnjnGCLZrdiqOZM6h0X4(sMG7Zs6luFrdOpxJX1PU0NoCFYvYKrjT7JWskEnbOaIB4C0aIXX4VB4C0poLCabNs(RomfqsMGdCWUk(WqLbes9xmTdpgqmGKjq6be2XKYfzTVN4Fc(f4gQqQ)IPDFq2h69TPxROOIS23t8pb)cCdvKSBe2h06d9(SVVhSp3W5OfzTVN4)3bZLu)r4CPM7dT(SzRVn9AffvK1(EI)j4xGBOcGG9uL9bT(QyFOfqCdNJgqmog)DdNJ(XPKdi4uYF1HPaIKcCWUkkEHkdiK6VyAhEmG4gohnGa7ykknFGVYwakGSjPbKRCoAar8xs9bXCmfLM(eF(kBbO(IxtAFWUG5b03EyzFoG6ZAvS(gqFzuFCnbO(INyCFVuFYCrZO04k3hNWuFwkN4(4AQpLGiUpiyTR8a3hsQlwyhKCSsFc2O(S4eNcgsDPpiMJPO00h0h4CTy9vp4DFEFYAhS7JN(aueGK19X1uFVwrrbedizcKEab9(2dxeLy6ZEQCHtJWux6ZMT(2dxs4vs3PU8no7sgmR10FpCHtJWux6ZMT(2dxKJf(dgUWPryQl9HwFq2h69jU(awkfnGfQa7ykkn)4aNRlK6VyA3NnB99AffvGDmfLMFCGZ1fj7gH9bT(QyF2S1NCSWFzTd29jO(qTp0cCWUkc9cvgqi1FX0o8yaXnCoAab2XuuA(aFLTauaztsdix5C0aI4VK6dI5ykkn9j(8v2cq9XtFWEQSNAFCn1hSJPO00xCGZ199Aff1NLYjUpzTd2Y(uI29XtFVuFlKsaNPDFrdOpUM6tjiI771ci5(IN6EI3h62Js9jjZOBzFPSp4bq9X1U2N0kkknjPCF803cPeWzQVk2NS2bBjAbedizcKEabyPu0awOcSJPO08JdCUUqQ)IPDFq2Nzg8EIRf5yH)GHlac2tv2NG6ZEuQpi771kkQa7ykkn)4aNRlac2tv2h067Hboyxff8HkdiK6VyAhEmG4gohnGa7ykknFGVYwakGSjPbKRCoAabI5PYEQ9bXCmfLM(G(aNR7Z5(CmUpoHjzFrdOpUM6ZoYag8a29nG(emvmq6AFMrePUYbedizcKEabyPu0awOcSJPO08JdCUUqQ)IPDFq2h69zgrK6kxuYag8a29zZwFMrePUYfHXaPR9HwFq23Rvuub2XuuA(XboxxaeSNQSpO13ddCWUkIcdvgqi1FX0o8yaXnCoAab2XuuA(aFLTauaztsdix5C0aI4VK6dI5ykkn9j(8v2cq9nAFqWAx5bUpKuxSWoi5y9zCjlfRpyxyQl9jTauF80N0fr959jRDWUpE6tYUryFqmhtrPPpOpW56(YO(SKPU0xYbedizcKEaHDmPCzT2vEG)YuxSWoi5yfs9xmT7dY(qVV9WL1Ax5b(ltDXc7GKJv40im1L(SzRpZm49exlR1UYd8xM6If2bjhRaiypvzFcQp7fV(SzRV3rk7dY(4eM(883j1h06ZmdEpX1YATR8a)LPUyHDqYXkac2tv2hA9bzFO3N46dyPu0awOcSJPO08JdCUUqQ)IPDF2S13Rvuub2XuuA(XboxxKSBe2h06RI9zZwFYXc)L1oy3NG6d1(qlWb7QO4xOYacP(lM2HhdigqYei9ac7ys5ICI)5A6ljAllK6VyAhqCdNJgqGDmfLMpWxzlaf4GDpeLcvgqi1FX0o8yaXnCoAazd8u)4mIciBsAa5kNJgqEaGNAFqxgr9LY(gfhRpVVhacI03INAFXtUUpbRsIs2FXuFpabNsQpLCqFWoe1NKDJqzPpbBuFr5sn3xk7ZFhlUpE6J0DF7PpD4(GtPSp5kP7ux6JRP(KSBekdigqYei9aYRvuujvsuY(lM(BcoLurYUryFcQVhIs9zZwFVwrrLujrj7Vy6Vj4usfR1(GSV3rk7dY(IYLA(diypvzFqRVhg4GDpe1qLbes9xmTdpgqCdNJgqmog)DdNJ(XPKdi4uYF1HPaIzerQRCGd29q7dvgqi1FX0o8yaXnCoAaXxgnwaXasMaPhqaueGK1(lMciMygm9zhSqSmyhQboy3dRyOYacP(lM2HhdigqYei9aIB4ue93dxSuj7Vy67rr40W5O9vTpuQpB26JtJWux6dY(aueGK1(lMciUHZrdiwQK9xm99OiCA4C0ahS7HpmuzaHu)ft7WJbe3W5ObezUwp6hNruaXasMaPhqaueGK1(lMciMygm9zhSqSmyhQboy3dfVqLbes9xmTdpgqCdNJgqmdayTY5ObedizcKEabqrasw7VyQpi7ZnCkI(KsWjj7dA99W(EW(qVp2XKYf5e)Z10xs0wwi1FX0UpB26JDmPCrMR1J(Xzevi1FX0Up0ciMygm9zhSqSmyhQboy3dHEHkdiK6VyAhEmG4gohnGeHjzTb4rCaXasMaPhqKJf(n1Dr0GDoX0xoyrKYfs9xmTdiPYeayTY)mkG8AffvenyNtm9LdwePCXAnWb7EOGpuzajvMaaRvoGGAaXnCoAazd8u)YXchqi1FX0o8yGd29quyOYaIB4C0aIS23t8)7G5acP(lM2HhdCGdiRaYmWVohQmyhQHkdiK6VyAhEmGyajtG0diCct9jO(qP(GSpX13kXfhNIO(GSpX13RvuuzbKWtcO)e9LUbKrPHkwRbe3W5ObKic)3dCQoNJg4GD2hQmG4gohnGiTGHh9hr4AlLjqaHu)ft7WJboyxfdvgqi1FX0o8yarDykGWdm9NOp8OsgmwYVzujdSmCoQmG4gohnGWdm9NOp8OsgmwYVzujdSmCoQmWb7EyOYacP(lM2HhdiQdtbe5GjVw(LKbq8NjtTMOalkG4gohnGihm51YVKmaI)mzQ1efyrboyN4fQmGqQ)IPD4XaIbKmbspGWoMuUSas4jb0FI(s3aYO0qfs9xmTdiUHZrdilGeEsa9NOV0nGmknuGd2b9cvgqCdNJgqIWKS2a8ioGqQ)IPD4XahStWhQmGqQ)IPD4XaYSgqKehqCdNJgqe5G0FXuarKJTOaIB4ue93dxmdayTY5O9jO(qP(GSp3WPi6VhU4lJgRpb1hk1hK95gofr)9WflvY(lM(EueonCoAFcQpuQpi7d9(exFSJjLlYCTE0poJOcP(lM29zZwFUHtr0FpCrMR1J(Xze1NG6dL6dT(GSp07BpCzT2vEG)YuxSWoi5yfonctDPpB26tC9XoMuUSw7kpWFzQlwyhKCScP(lM29HwarKd(QdtbK9WYpG8DSahSdfgQmGqQ)IPD4XaI6WuaXfmiRDGl)rJY)j6VoXjqaXnCoAaXfmiRDGl)rJY)j6VoXjqGd2j(fQmGqQ)IPD4XaIB4C0aIKO9FI(MbaSw5C0aIbKmbspGixjm(ZoyHyzrs0(prFZaawRCo63hQpbvTVkgqWPsFZoGGkkf4GDOIsHkdiUHZrdi1ULYbes9xmTdpg4GDOIAOYaIB4C0aILkz)ftFpkcNgohnGqQ)IPD4Xah4aIpuOYGDOgQmG4gohnGSw7kpWFzQlwyhKCSacP(lM2HhdCWo7dvgqCdNJgqQDlLdiK6VyAhEmWb7QyOYacP(lM2HhdigqYei9aIzerQRCrePCDmqFq23E4scVs6o1LVXzxYGzTM(7HlCAeM6sFq2Nzg8EIRfPfm8O)TdeUGDavaKVJ1hK9HEF7HlR1UYd8xM6If2bjhRaiypvzFcQp77ZMT(exFSJjLlR1UYd8xM6If2bjhRqQ)IPDFO1NnB9zgrK6kx0CPM)ro1hK9ThUihl8hmCHtJWux6dY(mZG3tCTiTGHh9VDGWfSdOcG8DS(GSp07BpCzT2vEG)YuxSWoi5yfab7Pk7tq9zFF2S1N46JDmPCzT2vEG)YuxSWoi5yfs9xmT7dT(SzRp07ZmIi1vUOKbm4bS7ZMT(mJisDLlcJbsx7ZMT(mJisDLl6OuFO1hK9ThUSw7kpWFzQlwyhKCScNgHPU0hK9ThUSw7kpWFzQlwyhKCScGG9uL9bT(SpG4gohnGyCm(7goh9JtjhqWPK)QdtbKTdeUGDa9xb0AGd29WqLbes9xmTdpgqmGKjq6be2XKYf5e)Z10xs0wwi1FX0Upi7Z46xs0oG4gohnGijA)NOVzaaRvohnWb7eVqLbes9xmTdpgqmGKjq6beX1h7ys5ICI)5A6ljAllK6VyA3hK9jU(2dxKeT)t03maG1kNJw40im1L(GSpX1xQ)iCUuZ9bzF7HlMbaSw5C0cGIaKS2FXuaXnCoAars0(prFZaawRCoAGd2b9cvgqi1FX0o8yaXnCoAaXxgnwaXasMaPhqCdNIO)E4IVmAS(GwFpSpi7tC9ThU4lJgRWPryQlbetmdM(SdwiwgSd1ahStWhQmGqQ)IPD4XaIB4C0aIVmASaIbKmbspG4gofr)9WfFz0y9jOQ99W(GSpafbizT)IP(GSV9WfFz0yfonctDjGyIzW0NDWcXYGDOg4GDOWqLbes9xmTdpgqmGKjq6be3WPi6VhUyPs2FX03JIWPHZr7RAFOuF2S1hNgHPU0hK9bOiajR9xmfqCdNJgqSuj7Vy67rr40W5OboyN4xOYacP(lM2HhdiUHZrdiwQK9xm99OiCA4C0aIbKmbspGiU(40im1L(GSVvrRSJjLlahE1v(7rr40W5OYcP(lM29bzFUHtr0FpCXsLS)IPVhfHtdNJ2h06RIbetmdM(SdwiwgSd1ahSdvukuzaHu)ft7WJbedizcKEarow4VS2b7(euFOgqCdNJgqeLy6ZEQCGd2HkQHkdiK6VyAhEmGyajtG0diIRpZiIux5IsgWGhWoGizqA4GDOgqCdNJgqmog)DdNJ(XPKdi4uYF1HPaIzerQRCGd2HQ9HkdiK6VyAhEmGyajtG0diO3NzerQRCrePCDmqFq2h69zMbVN4AjHxjDN6Y34SlzWSwtfa57y9zZwF7Hlj8kP7ux(gNDjdM1A6VhUWPryQl9HwFq2Nzg8EIRfPfm8O)TdeUGDavaKVJ1hK9HEF7HlR1UYd8xM6If2bjhRaiypvzFcQp77ZMT(exFSJjLlR1UYd8xM6If2bjhRqQ)IPDFO1hA9bzFO3h69zgrK6kxuYag8a29zZwFMrePUYfHXaPR9zZwFMrePUYfDuQp06dY(mZG3tCTiTGHh9VDGWfSdOcGG9uL9bT(SVpi7d9(2dxwRDLh4Vm1flSdsowbqWEQY(euF23NnB9jU(yhtkxwRDLh4Vm1flSdsowHu)ft7(qRp06ZMT(qVpZiIux5IMl18pYP(GSp07ZmdEpX1ICSWFWWfa57y9zZwF7HlYXc)bdx40im1L(qRpi7ZmdEpX1I0cgE0)2bcxWoGkac2tv2h06Z((GSp07BpCzT2vEG)YuxSWoi5yfab7Pk7tq9zFF2S1N46JDmPCzT2vEG)YuxSWoi5yfs9xmT7dT(qlG4gohnGyCm(7goh9JtjhqWPK)QdtbKTdeUGDa9xb0AGd2HAfdvgqi1FX0o8yaXasMaPhqEhPSpi7ZmdEpX1I0cgE0)2bcxWoGkac2tv2NG6lkxQ5pGG9uL9bzFO3N46JDmPCzT2vEG)YuxSWoi5yfs9xmT7ZMT(mZG3tCTSw7kpWFzQlwyhKCScGG9uL9jO(IYLA(diypvzFOfqCdNJgq2oq4xow4ahSd1hgQmGqQ)IPD4XaIbKmbspG8oszFq2Nzg8EIRfPfm8O)TdeUGDavaeSNQSVN6ZmdEpX1I0cgE0)2bcxWoGkBlGZ5O9bT(IYLA(diypvzaXnCoAaz7aHF5yHdCWoufVqLbes9xmTdpgqCdNJgqmog)DdNJ(XPKdi4uYF1HPasYeCGd2Hk0luzaHu)ft7WJbe3W5ObeJJXF3W5OFCk5acoL8xDykGSjShJ2FgKQqILboyhQc(qLbes9xmTdpgqCdNJgqmog)DdNJ(XPKdi4uYF1HPaY2H9f6ZGufsSmWb7qffgQmGqQ)IPD4XaIbKmbspGShUSw7kpWFzQlwyhKCScNgHPU0NnB9jU(yhtkxwRDLh4Vm1flSdsowHu)ft7aIKbPHd2HAaXnCoAaX4y83nCo6hNsoGGtj)vhMcis25pdsviXYahSdvXVqLbes9xmTdpgqmGKjq6bK9WfrjM(SNkx40im1LaIB4C0acSJPO08b(kBbOahSZEukuzaHu)ft7WJbedizcKEazpCrow4py4cNgHPU0hK9jU(yhtkxKt8pxtFjrBzHu)ft7aIB4C0acSJPO08b(kBbOahSZEudvgqi1FX0o8yaXasMaPhqexFSJjLlIsm9zpvUqQ)IPDaXnCoAab2XuuA(aFLTauGd2zV9HkdiK6VyAhEmGyajtG0diYXc)L1oy3NG67Hbe3W5ObeyhtrP5d8v2cqboyN9vmuzaHu)ft7WJbe3W5ObezUwp6hNruaXasMaPhqCdNIO)E4ImxRh9JZiQpOvTVk2hK9bOiajR9xm1hK9jU(2dxK5A9OFCgrfonctDjGyIzW0NDWcXYGDOg4GD2)WqLbes9xmTdpgqmGKjq6beZiIux5IsgWGhWoGizqA4GDOgqCdNJgqmog)DdNJ(XPKdi4uYF1HPaIzerQRCGd2zV4fQmGqQ)IPD4XaIbKmbspG8AffvsLeLS)IP)MGtjvKSBe2NGQ2N4Hs9zZwFVJu2hK99AffvsLeLS)IP)MGtjvSw7dY(IYLA(diypvzFqRpXRpB2671kkQKkjkz)ft)nbNsQiz3iSpbvTVkkE9bzF7HlYXc)bdx40im1LaIB4C0aYg4P(Xzef4GD2d9cvgqi1FX0o8yaXnCoAajctYAdWJ4aIbKmbspGihl8BQ7IOb7CIPVCWIiLlK6VyAhqsLjaWAL)zua51kkQiAWoNy6lhSis5I1AGd2zVGpuzajvMaaRvoGGAaXnCoAazd8u)YXchqi1FX0o8yGd2zpkmuzaXnCoAarw77j()DWCaHu)ft7WJboWbKKj4qLb7qnuzaXnCoAaXss)KjyzaHu)ft7WJboWbejfQmyhQHkdiUHZrdi1ULYbes9xmTdpg4GD2hQmGqQ)IPD4XasQmbawR8pJciB61kkQiR99e)tWVa3qfj7gHcQAfdiUHZrdiBGN6xow4asQmbawR8FbpVooGGAGd2vXqLbe3W5ObezTVN4)3bZbes9xmTdpg4ahquYaMpC8qLb7qnuzaHu)ft7WJbKznGijoG4gohnGiYbP)IPaIihBrbK9WfZaawRCoAbqWEQY(euF23hK9ThU4lJgRaiypvzFcQp77dY(2dxSuj7Vy67rr40W5Ofab7Pk7tq9zFFq2h69jU(yhtkxK5A9OFCgrfs9xmT7ZMT(2dxK5A9OFCgrfab7Pk7tq9zFFOfqe5GV6WuazpS8ZPryQlboyN9HkdiK6VyAhEmGmRbejXzuaXasMaPhqmJisDLlkzadEa7aYMKgqUY5ObKkbPkKyzFoox0(INCDFqqK(IgqFi1(EI3heh8lWnKy99ap2x0a6dca3s5sarKd(QdtbegKQqI)Bc7XciUHZrdiICq6VykGiYXw0NWskGyMbVN4AztMe25ux(VdMlac2tvgqe5ylkGyMbVN4AzT2vEG)YuxSWoi5yfab7PkdCWUkgQmGqQ)IPD4XaIB4C0acSJPO08b(kBbOaYMKgqUY5ObKhTaAFYXc3NS2bBzFzuFCn1xuUuZ9fpX4(EP(iDN6sFYz0saXasMaPhq4eM(883j1h06JGiYyX0NtyQpiW(KJf(lRDWUpi7BpCXsLS)IPVhfHtdNJw40im1LahS7HHkdiK6VyAhEmG4gohnGu7wkhq2K0aYvohnGaHUK7R2TuUpE6dqrasw33lfnaQVihJNOOsaXasMaPhq2dxQDlLlac2tv2h06Z((EQpcIiJftFoHPahSt8cvgqi1FX0o8yaXnCoAab2XuuA(aFLTauaztsdix5C0acea5sDFpyFRGCajhRpig0VpafbizDFzuFYvs3PU03OuFl451X9fFSW7(mULK6Zs2hp9bNszFCn13SUoa2stowF80hGIaKSUpig0V0xaXasMaPhq4eM6tq9j47dY(ETIIkWoMIsZpoW56cGG9uL9bT(wm7cSdr99uFeerglM(Cctboyh0luzaHu)ft7WJbKnjnGCLZrdiqata13MWEmA3hdsviXY(sTpx50KRoNJ23e13dqMe25ux67XbZLaI6WuaHGxJbih)hWwD1qbedizcKEarKds)ftfgKQqI)Bc7X6dA9zpkfqCdNJgqi41yaYX)bSvxnuGd2j4dvgqi1FX0o8yaXnCoAarAPV4z2FhM46ysoGyajtG0diICq6VyQWGufs8FtypwFqRpOxarDykGiT0x8m7VdtCDmjh4GDOWqLbes9xmTdpgqCdNJgqKJfgtmN6Yhy9glGyajtG0diICq6VyQWGufs8FtypwFqRpuyarDykGihlmMyo1LpW6nwGd2j(fQmGqQ)IPD4XaIB4C0aILK(jtWbedizcKEarKds)ftfgKQqI)Bc7X6dA99WaI6WuarDyQQS23tCA)hW7FI(8aGjLdCWourPqLbes9xmTdpgqCdNJgqwRDLh4Vm1flSdsowaztsdix5C0aIGnQpUM6Bf7XiqFPSplzQl9bbGBPSy9fLaQpiisFJ2Nzg8EIR9X1K2x0GXt8(INCDFpWJbedizcKEaHDmPCP2TuUqQ)IPDFq2NihK(lMk7HLFonctDjWb7qf1qLbes9xmTdpgqmGKjq6be2XKYLA3s5cP(lM29bzFMzW7jUwwRDLh4Vm1flSdsowbqWEQY(euFOuaXnCoAaztMe25ux(VdMdCWouTpuzaHu)ft7WJbe3W5ObKnzsyNtD5)oyoGSjPbKRCoAarWg1hxt9TI9yeOVu2NLm1L(qG4eRVOeq99ap23O9zMbVN4AFCnP9fny8ep1L(INCDFqqKaIbKmbspGWoMuUiR99e)tWVa3qfs9xmT7dY(e5G0FXuzpS8ZPryQlboyhQvmuzaHu)ft7WJbedizcKEaHDmPCrw77j(NGFbUHkK6VyA3hK9zMbVN4AztMe25ux(VdMlac2tv2NG6dLciUHZrdiR1UYd8xM6If2bjhlWb7q9HHkdiK6VyAhEmGyajtG0di7HlwQK9xm99OiCA4C0cGG9uL9bT(GEbe3W5ObelvY(lM(EueonCoAGd2HQ4fQmGqQ)IPD4XaIbKmbspGShU4lJgRaiypvzFqRVhgqCdNJgq8LrJf4GDOc9cvgqi1FX0o8yaXasMaPhq2dxK5A9OFCgrfab7Pk7dA99WaIB4C0aImxRh9JZikWb7qvWhQmGqQ)IPD4XaIbKmbspGShUygaWALZrlac2tv2h067Hbe3W5ObeZaawRCoAGd2HkkmuzaHu)ft7WJbe3W5ObeyhtrP5d8v2cqbKnjnGCLZrdiIpkcqY6(Gyq)(8iMa9X1uFZkPeOVmQVTdeUGDa9xb0AFXhl8UpJBjP(SK9XtFWPu2N3hed63hGIaKSoGyajtG0diCct9jO(e89bzFVwrrfyhtrP5hh4CDbqWEQY(GwF23heyFlMDb2HO(EQpcIiJftFoHPahSdvXVqLbes9xmTdpgq2K0aYvohnGaHog332bcxWoG(RaATVmQpiyTR8a3hsQlwyhKCS(szFglaGughRponctDjG4gohnGyCm(7goh9JtjhqKminCWoudigqYei9aYE4YATR8a)LPUyHDqYXkCAeM6sabNs(Romfq2oq4c2b0FfqRboyN9OuOYacP(lM2HhdiBsAa5kNJgqe)5eNcgO(CnwFdxtG(KSZ9XGufsSSVmQpiyTR8a3hsQlwyhKCS(szFCAeM6saXnCoAaX4y83nCo6hNsoGizqA4GDOgqmGKjq6bK9WL1Ax5b(ltDXc7GKJv40im1LacoL8xDykGizN)mivHeldCWo7rnuzaHu)ft7WJbe3W5ObeyhtrP5d8v2cqbKnjnGCLZrdiiSBe2heZXuuA6d6dCUUpE6RII13a6dqrasw3x8As7BHyo1L(Wt8(qp3KJXX6dpJWux6lAa959zCSXc7mT7tTGFjGy99AX99WI4j7dqWEQPU0xk7JRP(aK0cZ9nr9XKKtDPV4jx3xL2l4rlGyajtG0diCct9jO(e89bzFO33Rvuub2XuuA(XboxxKSBe2h06RI9zZwFVwrrfyhtrP5hh4CDbqWEQY(GwFpSiE9HwGd2zV9HkdiK6VyAhEmG4gohnGa7ykknFGVYwakGSjPbKRCoAarWT3jNJ64(GyIV(KRKUL9fVM0(iiIbEFYAhSL95aQpxKNy)ft956Upk5Ac0heS2vEG7dj1flSdsowFPSponctDrS(gqFCn1xuUuZ9LY(iDN6sjGyajtG0diO33E4YATR8a)LPUyHDqYXkCAeM6sF2S1hNW0NN)oP(GwFMzW7jUwwRDLh4Vm1flSdsowbqWEQY(qRpi7d9(ETIIkWoMIsZpoW56IKDJW(GwFvSpB26tow4VS2b7(euFO2hAboyN9vmuzaHu)ft7WJbe3W5ObKnWt9lhlCaztsdix5C0aIGBVtoh1X99aap1(qglCFgxY9fVM0(GGi9LY(40im1LaIbKmbspGShUSw7kpWFzQlwyhKCScNgHPUe4GD2)WqLbes9xmTdpgqCdNJgq8LrJfq2K0aYvohnGaDt8(EW(wb5asowF7H7dqrasw3x8As7dqrasw7VyQeqmGKjq6beafbizT)IPahSZEXluzaHu)ft7WJbedizcKEabqrasw7VykG4gohnGyPs2FX03JIWPHZrdCWo7HEHkdiK6VyAhEmGyajtG0diakcqYA)ftbe3W5ObeZaawRCoAGd2zVGpuzaHu)ft7WJbedizcKEaHDmPCrMR1J(Xzevi1FX0Upi7dqrasw7VykG4gohnGiZ16r)4mIcCWo7rHHkdiK6VyAhEmG4gohnGeHjzTb4rCajvMaaRv(NrbKxROOIOb7CIPVCWIiL)1wWUo5UyTgqmGKjq6be5yHFtDxenyNtm9LdwePCHu)ft7aYMKgqUY5ObeiGyswBaEe3hp9b7PYEQ9jyCWoNyQpKblIuUe4GD2l(fQmGqQ)IPD4XaIB4C0asTBPCaztsdix5C0ac0nXFWvqoGKJ1xTBPCFakcqY6saXasMaPhq2dxQDlLlac2tv2h06RIboyxfrPqLbes9xmTdpgqCdNJgq2ap1VCSWbKnjnGCLZrdiI)AQmbawRC(IP(EaK(m1UQeUVmQV4uF1UiQpUM67bESVxROOsaXasMaPhqETIIkBYKWoN6Y)DWCXAnWb7QiQHkdiK6VyAhEmG4gohnGSbEQF5yHdigqYei9ac7ys5IS23t8pb)cCdvi1FX0Upi7BtVwrrfzTVN4Fc(f4gQaiypvzFqRVk2NnB9TPxROOIS23t8pb)cCdvKSBe2h06RIbKuzcaSw5Fgfq20Rvuurw77j(NGFbUHks2ncfu1kc5METIIkYAFpX)e8lWnubqWEQsbvXahSRI2hQmGKktaG1khqqnG4gohnGSbEQF5yHdiK6VyAhEmWb7QyfdvgqCdNJgqK1(EI)Fhmhqi1FX0o8yGdCGdiUfxpGacscdHboWHa]] )


end